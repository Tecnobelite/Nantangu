const {
  time,
  loadFixture,
} = require ('@nomicfoundation/hardhat-toolbox/network-helpers');
const {anyValue} = require ('@nomicfoundation/hardhat-chai-matchers/withArgs');
const {expect} = require ('chai');

describe ('__ IDO_Manager_Testing__', () => {

 
  let PreSaleManager;
  let presaleToken;

  before (async () => {
    const testTokenFactory = await ethers.getContractFactory("TestToken");
    PreSaleToken = await testTokenFactory.deploy(
      "PreSale Token",
      "PST",
      18,
      ethers.parseUnits("10000000", 18)
    );

    console.log(testTokenFactory);
    console.log(PreSaleManager);
    // console.log(PreSaleManager.target);
    // console.log(await PreSaleManager.symbol());
  });

  it ('Should', async () => {
    console.log ('Hello');
  });
});
