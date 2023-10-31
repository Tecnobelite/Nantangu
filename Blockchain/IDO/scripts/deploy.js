
const hre = require("hardhat");

async function main() {


    // Deploying the sale contract
    const PreSaleFactory = await ethers.getContractFactory('Sale')
    const PreSale = await PreSaleFactory.deploy()

 
    console.log(PreSale.target);

    // Deploying the manager contract
    const PreSaleManagerFactory = await ethers.getContractFactory('SaleManager')
    const PreSaleManager = await upgrades.deployProxy(
      PreSaleManagerFactory,
      [PreSale.target],
      {
        initializer: 'initialize'
      }
    )

    await PreSaleManager.waitForDeployment();

    console.log(PreSaleManager.target);


}


main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
