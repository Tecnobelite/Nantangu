const {
  time,
  loadFixture
} = require('@nomicfoundation/hardhat-toolbox/network-helpers')
const { anyValue } = require('@nomicfoundation/hardhat-chai-matchers/withArgs')
const { expect } = require('chai')
const { upgrades } = require('hardhat')

const ZERO_ADDRESS = '0x0000000000000000000000000000000000000000'
const ProjectDetails = {
  logoUrl: 'logoUrl',
  bannerUrl: 'bannerUrl',
  websiteUrl: 'websiteUrl',
  telegramUrl: 'telegramUrl',
  githubUrl: 'githubUrl',
  twitterUrl: 'twitterUrl',
  discordUrl: 'discordUrl',
  youtubePresentationVideoUrl: 'youtubePresentationVideoUrl',
  whitelistContestUrl: 'whitelistContestUrl',
  redditUrl: 'redditUrl',
  projectDescription: 'projectDescription'
}

describe('__IDO_Manager_Testing__', () => {
  let PreSaleManager
  let presaleToken
  let Presale
  let owner
  let addresses

  before(async () => {
    // Deploying the presale token
    const testTokenFactory = await ethers.getContractFactory('TestToken')
    presaleToken = await testTokenFactory.deploy(
      'PreSale Token',
      'PST',
      18,
      ethers.parseUnits('10000000', 18)
    )

    // accounts for testing
    ;[owner, ...addresses] = await ethers.getSigners()

    // Deploying the sale contract
    const PreSaleFactory = await ethers.getContractFactory('Sale')
    PreSale = await PreSaleFactory.deploy()

    // Deploying the manager contract
    const PreSaleManagerFactory = await ethers.getContractFactory('SaleManager')
    PreSaleManager = await upgrades.deployProxy(
      PreSaleManagerFactory,
      [PreSale.target],
      {
        initializer: 'initialize'
      }
    )
  })

  describe('updateNormalPreSale function checks', () => {
    describe('__Success__', () => {
      it('Should update the address of the clonable sale of the contract', async () => {
        await PreSaleManager.updateNormalPreSale(owner.address)
        expect(await PreSaleManager.cloneableNormalFairSale()).to.be.equal(
          owner.address
        )

        // Setting back again the original one
        await PreSaleManager.updateNormalPreSale(PreSale.target)
        expect(await PreSaleManager.cloneableNormalFairSale()).to.be.equal(
          PreSale.target
        )
      })
    })

    describe('__Failures__', () => {
      it('Should fail when other than owner try to update the sale address', async () => {
        await expect(
          PreSaleManager.connect(addresses[0]).updateNormalPreSale(ZERO_ADDRESS)
        ).to.be.revertedWith('Ownable: caller is not the owner')
      })
      it('Should fail update the address of the cloneable sales with zero address', async () => {
        await expect(
          PreSaleManager.updateNormalPreSale(ZERO_ADDRESS)
        ).to.be.revertedWith('ERR_ZERO_ADDRESS')
      })
    })
  })

  describe('createPreSale function checks', () => {
    describe('__Success__', () => {
      it('Should create a sale', async () => {
        const presaleTokenDecimals = await presaleToken.decimals()
        const exchangeRate = ethers.parseUnits('100', presaleTokenDecimals)
        const hardcap = ethers.parseEther('5')
        const saleToken = presaleToken.target

        const totalSupply = await presaleToken.totalSupply()

        presaleToken.approve(PreSaleManager.target, totalSupply)

        await PreSaleManager.createPreSale(
          exchangeRate,
          hardcap,
          saleToken,
          ProjectDetails
        )

        // console.log(await PreSaleManager.totalNumberOfPreSale());
        // console.log(await PreSaleManager.totalPreSaleCreatedBy(owner.address));
        const _sale = await PreSaleManager.preSaleAddressByOwnerAndId(
          owner.address,
          0
        )
        // console.log(await PreSaleManager.projectDetailsOf(_sale));

        await PreSaleManager.investIntoPreSale(_sale, {
          value: ethers.parseEther('1')
        })
        await PreSaleManager.connect(addresses[0]).investIntoPreSale(_sale, {
          value: ethers.parseEther('1')
        })
        // console.log(await presaleToken.balanceOf(addresses[0].address));
        await PreSaleManager.claimTokensFromPreSale(_sale)
        await PreSaleManager.connect(addresses[0]).claimTokensFromPreSale(_sale)
        // console.log(await presaleToken.balanceOf(addresses[0].address));
        await PreSaleManager.withdrawFundRaised(_sale)
      })
      it('Should crerate multiple sales', async () => {
        const presaleTokenDecimals = await presaleToken.decimals()
        const exchangeRate = ethers.parseUnits('100', presaleTokenDecimals)
        const hardcap = ethers.parseEther('5')
        const saleToken = presaleToken.target

        const totalSupply = await presaleToken.totalSupply()

        presaleToken.approve(PreSaleManager.target, totalSupply)

        const presaleCreatedEarlier =
          await PreSaleManager.totalNumberOfPreSale()

        for (let i = 1; i <= 10; i++) {
          await PreSaleManager.createPreSale(
            exchangeRate,
            hardcap,
            saleToken,
            ProjectDetails
          )
        }
        const presaleCreatedAfter = await PreSaleManager.totalNumberOfPreSale()
        expect(presaleCreatedEarlier + 10n).to.be.equal(presaleCreatedAfter)
      })
    })

    describe('__Failures__', () => {})
  })

  describe('investIntoPreSale function checks', () => {

    describe('__Success__', () => {
          it("Should allow any investor to invest into the active presales" , async ()=>{
             const activeSale = await PreSaleManager.preSaleAddressByOwnerAndId(owner.address , 0);
             expect(await PreSaleManager.investIntoPreSale(activeSale , {value : ethers.parseEther("2")}));
          })
          it("Should allow any investor to invest into the multiple active presales" , async ()=>{
                 const totalActiveSales = await PreSaleManager.totalNumberOfPreSale();
                 for(let i=1 ; i < totalActiveSales ; i++){
                  const activeSale = await PreSaleManager.preSaleAddressByOwnerAndId(owner.address , i);
                  expect(await PreSaleManager.investIntoPreSale(activeSale , {value : ethers.parseEther("2")}));
                 }
         })
    })
    describe('__Failures__', async () => {
      it("Should fail if the presale address entered is invalid"  , async ()=>{
          await expect(PreSaleManager.investIntoPreSale(addresses[1].address , {value : ethers.parseEther("1")})).to.be.revertedWith("ERR_SALE_NOT_VALID");
      })
      it("Should fail if the invested amount is 0" , async ()=>{
          const activePresale = await PreSaleManager.preSaleAddressByOwnerAndId(owner.address , 0);
          await expect(PreSaleManager.investIntoPreSale(activePresale , {value : 0})).to.be.revertedWith("ERR_0_BUY_AMOUNT");
      })
      it("Should fail if someone tries to invest and the hardcap is reached" , async ()=>{
        const activePresale = await PreSaleManager.preSaleAddressByOwnerAndId(owner.address , 0);
        await expect(PreSaleManager.investIntoPreSale(activePresale , {value : ethers.parseEther("3")})).to.be.revertedWith("ERR_HARD_CAP_EXCEEDED");
      })
      
  })
  })

  describe("Claim function Testing" , ()=>{
         describe("__Failures__" , ()=>{
              it("Should fail if someone who have not invested tries to claim tokens" , async()=>{
                const activePresale = await PreSaleManager.preSaleAddressByOwnerAndId(owner.address , 0);
                await expect(PreSaleManager.connect(addresses[1]).claimTokensFromPreSale(activePresale)).to.be.revertedWith("ERR_NO_TOKENS_TO_CLAIM")
              })
         })

         describe("__Success__" , ()=>{
         it("Should allow the investor to claim the sale tokens according to the presale tokens exchange rate" , async ()=>{
          const activePresale = await PreSaleManager.preSaleAddressByOwnerAndId(owner.address , 0);
              expect(await PreSaleManager.claimTokensFromPreSale(activePresale));
           })
         })
  })

  describe("withdrawFundRaised function testing" , ()=>{
       describe("__Failures__" , ()=>{
       it("Should revert if the an address that is not owner tries to withdraw fund raised from the active sale" , async ()=>{
         const activePresale = await PreSaleManager.preSaleAddressByOwnerAndId(owner.address , 0);
             await expect(PreSaleManager.connect(addresses[3]).withdrawFundRaised(activePresale)).to.be.revertedWith("ERR_CALLER_NOT_OWNER");  
        })
       })

       describe("__Success__" , ()=>{
    it("Should allow the owner of the sale to withdraw funds from the sale" , async ()=>{
      const activePresale = await PreSaleManager.preSaleAddressByOwnerAndId(owner.address , 1);
      expect(await PreSaleManager.withdrawFundRaised(activePresale));
    })
       })
  })


})
