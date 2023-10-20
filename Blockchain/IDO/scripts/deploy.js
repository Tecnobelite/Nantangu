
const hre = require("hardhat");

async function main() {


  // const lock = await hre.ethers.deployContract("Lock", [unlockTime], {
  //   value: lockedAmount,
  // });

  // await lock.waitForDeployment();


}


main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
