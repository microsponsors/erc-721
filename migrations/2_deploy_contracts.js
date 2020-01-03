const Microsponsors = artifacts.require("./Microsponsors.sol");

module.exports = function(deployer) {

  deployer.deploy(
    Microsponsors,
    // Token name:
    "Microsponsors Time Slots",
    // Token symbol:
    "MSPT",
    // Microsponsors Registry address:
    "0xb6A30fdc3e3f11b20af1670550083AA06eb0479A"
   );

};
