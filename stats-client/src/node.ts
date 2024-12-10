/* eslint-disable @typescript-eslint/ban-ts-comment */
// @ts-nocheck

import WebSocket from 'ws';
import Docker from 'dockerode';
import { Web3 } from 'web3';
import os from 'os';
import { config } from './app/config.js';  // Use relative path

// Import `node-fetch` dynamically to support ES Modules
const fetch = (await import('node-fetch')).default;

// Environment variables and config
const clientId = process.argv[2] || 'test-client-1';
const wsPath = process.env.WS_PATH || config.server.wsPath;
const wsUrl =
  process.env.NEXT_PUBLIC_WS_URL ||
  `ws://${process.env.HOST || '172.17.0.1'}:${process.env.PORT || '3000'}${wsPath}`;

console.log("URL: " + wsUrl);

const EXECUTION_WS_ENDPOINT = process.env.EXECUTION_WS_ENDPOINT || 'ws://geth:8546';
const BEACON_RPC_PROVIDER = process.env.BEACON_RPC_PROVIDER || 'http://beacon:3500';
const PUBLIC_KEY = process.env.VALIDATOR_PUBLIC_KEY || process.env.PUBLIC_KEY;

const docker = new Docker();
const web3 = new Web3(new Web3.providers.WebsocketProvider(EXECUTION_WS_ENDPOINT));
const ws = new WebSocket(wsUrl);

const stats = {
  active: false,
  peers: 0,
  pending: 0,
  gasPrice: 0,
  block: {
    number: 0,
    difficulty: 0,
    gasUsed: 0,
    hash: '',
    totalDifficulty: 0,
    transactions: [],
    uncles: [],
    blockTransactionCount: 0,
  },
  syncing: false,
  uptime: 0,
  latency: 0,
  beacon: {
    headSlot: 0,
    finalizedEpoch: 0,
    currentEpoch: 0,
  },
  containers: {
    geth: { cpuPercentage: 0, memoryUsage: '0MB', memoryLimit: '0MB', osPlatform: '', osVersion: '' },
 // TODO
 //   validator: { cpuPercentage: 0, memoryUsage: '0MB', memoryLimit: '0MB', osPlatform: '', osVersion: '' },
    beacon: { cpuPercentage: 0, memoryUsage: '0MB', memoryLimit: '0MB', osPlatform: '', osVersion: '' },
  },
};

// Function to convert BigInts to strings
function convertBigIntsToStrings(obj: any): any {
  if (typeof obj === 'bigint') {
    return obj.toString();
  } else if (Array.isArray(obj)) {
    return obj.map((item) => convertBigIntsToStrings(item));
  } else if (obj && typeof obj === 'object') {
    const converted: any = {};
    for (const key in obj) {
      converted[key] = convertBigIntsToStrings(obj[key]);
    }
    return converted;
  }
  return obj;
}

// Function to fetch container stats
async function getContainerStats(containerName: string) {
  try {
    const container = docker.getContainer(containerName);
    const statsData = await container.stats({ stream: false });

    const cpuDelta = statsData.cpu_stats.cpu_usage.total_usage - statsData.precpu_stats.cpu_usage.total_usage;
    const systemDelta = statsData.cpu_stats.system_cpu_usage - statsData.precpu_stats.system_cpu_usage;
    const cpuPercentage = (cpuDelta / systemDelta) * statsData.cpu_stats.online_cpus * 100;

    const memoryUsage = (statsData.memory_stats.usage / (1024 * 1024)).toFixed(2);
    const memoryLimit = (statsData.memory_stats.limit / (1024 * 1024)).toFixed(2);

    return {
      cpuPercentage: Number(cpuPercentage.toFixed(2)),
      memoryUsage: `${memoryUsage}MB`,
      memoryLimit: `${memoryLimit}MB`,
    };
  } catch (err) {
    console.error(`Error fetching stats for container ${containerName}:`, err);
    return null;
  }
}

// Function to fetch beacon node stats
async function getBeaconNodeStats() {
  try {
    const response = await fetch(`${BEACON_RPC_PROVIDER}/eth/v1/node/syncing`);
    if (!response.ok) throw new Error(`Beacon node API request failed with status ${response.status}`);
    const data = await response.json();

    return {
      headSlot: parseInt(data.data.head_slot),
      finalizedEpoch: parseInt(data.data.finalized_epoch),
      currentEpoch: parseInt(data.data.current_epoch),
    };
  } catch (err) {
    console.error('Error fetching beacon node stats:', err);
    return null;
  }
}

// Function to update stats
async function updateStats() {
  try {
    stats.peers = await web3.eth.net.getPeerCount();
    stats.gasPrice = Number(await web3.eth.getGasPrice());
    const latestBlock = await web3.eth.getBlock('latest');

    stats.block = {
      number: latestBlock.number,
      difficulty: latestBlock.difficulty,
      gasUsed: latestBlock.gasUsed,
      hash: latestBlock.hash,
      totalDifficulty: latestBlock.totalDifficulty,
      transactions: latestBlock.transactions,
      uncles: latestBlock.uncles,
      blockTransactionCount: latestBlock.transactions.length,
    };

    stats.uptime = process.uptime();

    // Fetch container stats
    const gethStats = await getContainerStats('geth');
    const beaconStats = await getContainerStats('beacon');
 // TODO
 //   const validatorStats = await getContainerStats('validator');

    if (gethStats) stats.containers.geth = gethStats;
    if (beaconStats) stats.containers.beacon = beaconStats;
    // TODO
    // if (validatorStats) stats.containers.validator = validatorStats;

    // Fetch beacon node stats
    const beaconNodeStats = await getBeaconNodeStats();
    if (beaconNodeStats) stats.beacon = beaconNodeStats;
  } catch (err) {
    console.error('Error updating stats:', err);
  }
}

// WebSocket event handlers
let statsInterval: NodeJS.Timeout;

ws.on('open', () => {
  console.log(`Connected to WebSocket server as ${clientId}`);

  // Send initial hello message
  ws.send(
    JSON.stringify({
      emit: ['hello', { id: clientId, name: `Test Client ${clientId}` }],
    })
  );

  // Periodically send updated stats
  statsInterval = setInterval(async () => {
    await updateStats();
    const safeStats = convertBigIntsToStrings(stats);
    ws.send(JSON.stringify({ emit: ['stats', safeStats] }));
  }, config.client.updateInterval);
});

ws.on('message', (data) => {
  console.log('Received:', data.toString());
});

ws.on('error', console.error);
ws.on('close', () => {
  console.log('Disconnected from server');
  clearInterval(statsInterval);
});

process.on('SIGINT', () => {
  ws.close();
  process.exit(0);
});
