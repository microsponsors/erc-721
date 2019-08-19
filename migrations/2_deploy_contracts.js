const Microsponsors = artifacts.require("./Microsponsors.sol");

module.exports = function(deployer) {
  deployer.deploy(Microsponsors);
};
