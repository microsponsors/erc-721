const Microsponsors = artifacts.require("./Microsponsors.sol");

module.exports = function(deployer) {

  deployer.deploy(
    Microsponsors,
    "Microsponsors Time Slots", // Name
    "MSPT", // Symbol
    // Kovan: Microsponsors Registry v0.2 address:
    "0xcac14f367a032c14563a5ade63e33f00fe0f4c89"
   );

};
