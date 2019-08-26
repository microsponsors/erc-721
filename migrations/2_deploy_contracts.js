const Microsponsors = artifacts.require("./Microsponsors.sol");

module.exports = function(deployer) {

  deployer.deploy(
    Microsponsors,
    "MicrosponsorsTest", // Name
    "MSPTest", // Symbol
    // Microsponsors Registry address on Kovan:
    "0xd668f99c616eb657df5c45673d6897dd29b069c9"
   );

};
