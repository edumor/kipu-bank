#!/usr/bin/env node
const fs = require('fs');
const path = require('path');
const solc = require('solc');

// Read the contract file
const contractPath = path.resolve(__dirname, '../contracts/KipuBank.sol');
const source = fs.readFileSync(contractPath, 'utf8');

// Compile contract
const input = {
  language: 'Solidity',
  sources: {
    'KipuBank.sol': {
      content: source
    }
  },
  settings: {
    optimizer: {
      enabled: true,
      runs: 200
    },
    outputSelection: {
      '*': {
        '*': ['abi', 'evm.bytecode', 'evm.deployedBytecode', 'evm.methodIdentifiers'],
        '': ['ast']
      }
    }
  }
};

console.log('Compiling contract with solc...');

let output;
try {
  output = JSON.parse(solc.compile(JSON.stringify(input)));
} catch (error) {
  console.error('Failed to compile contract:', error.message);
  process.exit(1);
}

// Check for errors
if (output.errors) {
  const hasErrors = output.errors.some(error => error.severity === 'error');
  output.errors.forEach(error => {
    console.log(`${error.severity}: ${error.message}`);
  });
  if (hasErrors) {
    process.exit(1);
  }
}

// Create artifacts directory
const artifactsDir = path.resolve(__dirname, '../artifacts/contracts/KipuBank.sol');
const buildInfoDir = path.resolve(__dirname, '../artifacts/build-info');
const cacheDir = path.resolve(__dirname, '../cache');

fs.mkdirSync(artifactsDir, { recursive: true });
fs.mkdirSync(buildInfoDir, { recursive: true });
fs.mkdirSync(cacheDir, { recursive: true });

// Get contract output
const contract = output.contracts['KipuBank.sol'].KipuBank;

// Create build info
const buildInfoId = 'manual-build-' + Date.now();
const buildInfo = {
  id: buildInfoId,
  _format: 'hh-sol-build-info-1',
  solcVersion: '0.8.20',
  solcLongVersion: '0.8.20+commit.a1b79de6',
  input: input,
  output: output
};

const buildInfoPath = path.join(buildInfoDir, `${buildInfoId}.json`);
fs.writeFileSync(buildInfoPath, JSON.stringify(buildInfo, null, 2));

// Create Hardhat-compatible artifact
const artifact = {
  _format: 'hh-sol-artifact-1',
  contractName: 'KipuBank',
  sourceName: 'contracts/KipuBank.sol',
  abi: contract.abi,
  bytecode: '0x' + contract.evm.bytecode.object,
  deployedBytecode: '0x' + contract.evm.deployedBytecode.object,
  linkReferences: contract.evm.bytecode.linkReferences || {},
  deployedLinkReferences: contract.evm.deployedBytecode.linkReferences || {}
};

// Write artifact
const artifactPath = path.join(artifactsDir, 'KipuBank.json');
fs.writeFileSync(artifactPath, JSON.stringify(artifact, null, 2));

// Write debug artifact with correct path
const debugArtifactPath = path.join(artifactsDir, 'KipuBank.dbg.json');
fs.writeFileSync(debugArtifactPath, JSON.stringify({
  _format: 'hh-sol-dbg-1',
  buildInfo: `../../build-info/${buildInfoId}.json`
}, null, 2));

console.log('✓ Contract compiled successfully!');
console.log(`Artifacts saved to: ${artifactsDir}`);
console.log(`Build info saved to: ${buildInfoPath}`);
