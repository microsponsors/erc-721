const Microsponsors = artifacts.require("./Microsponsors.sol");

module.exports = function(deployer) {

  deployer.deploy(
    Microsponsors,
    // Token name:
    "Microsponsors Time Slots",
    // Token symbol:
    "MSPT",
    // Microsponsors Registry address:
    "0x8A67513f3Ad5Ae49b550CEE04d41729564c3cc93"
   );

};
