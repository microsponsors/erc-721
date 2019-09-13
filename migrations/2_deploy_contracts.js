const Microsponsors = artifacts.require("./Microsponsors.sol");

module.exports = function(deployer) {

  deployer.deploy(
    Microsponsors,
    "Microsponsors", // Name
    "MSP", // Symbol
    // Kovan: Microsponsors Registry v0.2 address:
    "0xcac14f367a032c14563a5ade63e33f00fe0f4c89"
   );

};

// Kovan: Microsponsors Registry v0.1
// "0xd668f99c616eb657df5c45673d6897dd29b069c9"

