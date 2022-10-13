import { ethers } from "hardhat";

async function main() {
  const BaseERC20 = await ethers.getContractFactory("BaseERC20");
  const BaseERC20_contract = await BaseERC20.deploy("name", "symbol", "amount");

  await BaseERC20_contract.deployed();

  console.log(`BaseERC20 deployed to ${BaseERC20_contract.address}`);
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
