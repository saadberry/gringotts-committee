/* 
    Tests related to the contract: Committee.sol
    We will be testing the following cases:
        1- User added to session
        2- Get users for session
        3- Add balance for a user
        -- more --
*/
const {
  time,
  loadFixture,
} = require("@nomicfoundation/hardhat-toolbox/network-helpers");
const { anyValue } = require("@nomicfoundation/hardhat-chai-matchers/withArgs");
const { expect } = require("chai");

describe("Committee", function () {

  let Committee;
  let committee;
  let owner;
  let addr1;
  let addr2;
  let addrs;
  const MAX_USERS_PER_SESSION = 5;

  beforeEach(async function () {
    Committee = await ethers.getContractFactory("Committee");
    [owner, addr1, addr2, ...addrs] = await ethers.getSigners();
    committee = await Committee.deploy();
  });

  async function deployCommitteeFixture() {
        // Contracts are deployed using the first signer/account by default
        const [owner, otherAccount] = await ethers.getSigners();

        const Committee = await ethers.getContractFactory("Committee");
        const committee = await Committee.deploy()

        return { committee, owner, otherAccount }
  }

  describe("Deployment", function () {
    
    it("Should set the right owner", async function () {
      const { committee, owner } = await loadFixture(deployCommitteeFixture);
      expect(await committee.owner()).to.equal(owner.address);
    });
  })

  describe("createNewSession", function () {
    it("Should create a new session and return the correct ID", async function () {
      // Creating first session
      const tx = await committee.createNewSession();
      await tx.wait();
      const sessionId1 = (await committee.sessionId()) - BigInt(1);  
      expect(sessionId1).to.equal(0);
      // Creating second session
      const tx2 = await committee.createNewSession();
      await tx2.wait();
      const sessionId2 = (await committee.sessionId()) - BigInt(1);  
      expect(sessionId2).to.equal(1);
      });
  });

  describe("addUserToSession", function () {
    it("Should add a user to an existing session", async function () {
      const tx = await committee.createNewSession();
      await tx.wait();
      const sessionId = (await committee.sessionId()) - BigInt(1);  
      await committee.addUserToSession(addr1.address, sessionId);
      const users = await committee.getUsersInSession(sessionId);
      expect(users).to.include(addr1.address);
    });

    it("Should fail when adding to a non-existent session", async function () {
      await expect(committee.addUserToSession(addr1.address, 999))
        .to.be.revertedWith("Session does not exist or is not active");
    });

    it("Should fail when adding an existing user", async function () {
      await committee.createNewSession();
      const sessionId = (await committee.sessionId()) - BigInt(1);
      await committee.addUserToSession(addr1.address, sessionId);
      await expect(committee.addUserToSession(addr1.address, sessionId))
        .to.be.revertedWith("User already exists");
    });

    it("Should fail when session is full", async function () {
      await committee.createNewSession();
      const sessionId = (await committee.sessionId()) - BigInt(1);
      for (let i = 0; i < MAX_USERS_PER_SESSION; i++) {  
        await committee.addUserToSession(addrs[i].address, sessionId);
      }
      await expect(committee.addUserToSession(addr1.address, sessionId))
        .to.be.revertedWith("Session is full");
    });
  });

  describe("getUsersInSession", function () {
    it("Should return correct users in a session", async function () {
      await committee.createNewSession();
      const sessionId = (await committee.sessionId()) - BigInt(1);
      await committee.addUserToSession(addr1.address, sessionId);
      await committee.addUserToSession(addr2.address, sessionId);
      const users = await committee.getUsersInSession(sessionId);
      expect(users).to.include(addr1.address, addr2.address);
    });

    it("Should fail for non-existent session", async function () {
      await expect(committee.getUsersInSession(999))
        .to.be.revertedWith("Session does not exist or is not active");
    });
  });

  describe("AddMoney", function () {
    it("Should add money to user balance and session total", async function () {
      await committee.createNewSession();
      const sessionId = (await committee.sessionId()) - BigInt(1);
      await committee.addUserToSession(addr1.address, sessionId);
      await committee.AddMoney(addr1.address, 100);
      expect(await committee.CheckBalance(addr1.address)).to.equal(100);
      const session = await committee.sessions(sessionId);
      expect(session.totalBalance).to.equal(100);
    });

    it("Should fail for non-existent user", async function () {
      await expect(committee.AddMoney(addr1.address, 100))
        .to.be.revertedWith("User does not exist");
    });
  });
  
})


