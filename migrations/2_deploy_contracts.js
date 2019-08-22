const Microsponsors = artifacts.require("./Microsponsors.sol");

module.exports = function(deployer) {

  deployer.deploy(
    Microsponsors,
    "MicrosponsorsTest", // Name
    "MSPTest", // Symbol
    "0xea442e73c98197954d38a02540204cb1a424a405" // Microsponsors Registry address
   );

};
