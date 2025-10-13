const { buildModule } = require("@nomicfoundation/hardhat-ignition/modules");

module.exports = buildModule("KipuBankModule", (m) => {
  const kipuBank = m.contract("KipuBank");

  return { kipuBank };
});
