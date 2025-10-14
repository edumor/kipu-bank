#!/usr/bin/env node
const fs = require('fs');
const path = require('path');
const crypto = require('crypto');

// Paths
const contractPath = path.resolve(__dirname, '../contracts/KipuBank.sol');
const artifactPath = path.resolve(__dirname, '../artifacts/contracts/KipuBank.sol/KipuBank.json');
const checksumPath = path.resolve(__dirname, '../cache/contract-checksum.txt');
const cacheDir = path.resolve(__dirname, '../cache');

// Ensure cache directory exists
if (!fs.existsSync(cacheDir)) {
  fs.mkdirSync(cacheDir, { recursive: true });
}

// Calculate checksum of contract
const contractSource = fs.readFileSync(contractPath, 'utf8');
const currentChecksum = crypto.createHash('md5').update(contractSource).digest('hex');

// Check if artifact exists and is up to date
let needsCompilation = true;

if (fs.existsSync(artifactPath) && fs.existsSync(checksumPath)) {
  const savedChecksum = fs.readFileSync(checksumPath, 'utf8').trim();
  if (savedChecksum === currentChecksum) {
    console.log('✓ Contract unchanged, skipping compilation');
    needsCompilation = false;
  }
}

if (needsCompilation) {
  console.log('Contract changed or not compiled, compiling...');
  
  // Run the compilation script
  const { execSync } = require('child_process');
  try {
    execSync('node scripts/compile-manual.js', { 
      stdio: 'inherit',
      cwd: path.resolve(__dirname, '..')
    });
    
    // Save checksum
    fs.writeFileSync(checksumPath, currentChecksum);
  } catch (error) {
    console.error('Compilation failed');
    process.exit(1);
  }
}
