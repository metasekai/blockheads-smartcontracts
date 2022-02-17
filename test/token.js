const { expect } = require("chai");
const {  utils } = require("ethers");

// describe("BlockHeadToken", function () {
//   it("Deployment should assign the total supply of tokens to the owner", async function () {
//     const [owner] = await ethers.getSigners();

//     const Token = await ethers.getContractFactory("BlockHeadToken");

//     const hardhatToken = await Token.deploy();

//     const ownerBalance = await hardhatToken.balanceOf(owner.address);
//     console.log("owner balance", ownerBalance);
//     expect(await hardhatToken.totalSupply()).to.equal(ownerBalance);
//   });
// });

describe("Token", function() {
    // it("Should transfer with max cap", async function() {
    //     const totalSupply = 100000000;
    //     const maxCap = totalSupply * 0.001;
        
    //     const AccessControl = await ethers.getContractFactory("BlockHeadAccessControl");

    //     const accessControlToken = await AccessControl.deploy();

    //     //convert from wei
    //   const contractParams = [utils.parseEther(maxCap.toString()), accessControlToken.address];
    //   const [owner, addr1, addr2] = await ethers.getSigners();
  
    //   const Token = await ethers.getContractFactory("BlockHeadToken");
  
    //   const hardhatToken = await Token.deploy(
    //     ...contractParams
    //   );

    //   console.log("Owner Address", addr1.address)
    //   console.log("Contract Address 1", addr1.address)
    //   console.log("Contract Address 2", addr2.address)
    //   console.log("Total Supply", await hardhatToken.totalSupply())
  
    //   // Transfer 50 tokens from owner to addr1
    //   const trans = await hardhatToken.transfer(addr1.address, utils.parseEther("10000"));

    //   console.log("Balance of address 1", await hardhatToken.balanceOf(addr1.address));

    //   console.log("Address 1 after balance", trans)
    //   expect(await hardhatToken.balanceOf(addr1.address)).to.equal(utils.parseEther("10000"));
    // });

    it("Should transfer with role", async function() {
        const AccessControl = await ethers.getContractFactory("BlockHeadAccessControl");
  
        const accessControlToken = await AccessControl.deploy();

        //convert from wei
      const contractParams = [accessControlToken.address];
      const [owner, addr1, addr2] = await ethers.getSigners();
  
      const Token = await ethers.getContractFactory("VirtualBlockHeadToken");
  
      const hardhatToken = await Token.deploy(
        ...contractParams
      );

      console.log("Owner Address", addr1.address)
      console.log("Contract Address 1", addr1.address)
      console.log("Contract Address 2", addr2.address)
      console.log("Total Supply", await hardhatToken.totalSupply())

        // Transfer 50 tokens from owner to addr1
      const trans = await hardhatToken.transfer(addr1.address, utils.parseEther("10000"));

      console.log("Balance of address 1", await hardhatToken.balanceOf(addr1.address));

      console.log("Address 1 after balance", trans)
      expect(await hardhatToken.balanceOf(addr1.address)).to.equal(utils.parseEther("10000"));
    });
  });