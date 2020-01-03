const Microsponsors = artifacts.require("./Microsponsors.sol");

module.exports = function(deployer) {

  deployer.deploy(
    Microsponsors,
    // Token name:
    "Microsponsors Time Slots",
    // Token symbol:
    "MSPT",
    // Microsponsors Registry address:
    "0x0B9941080af398d9D20064B3232d1F45907899D9"
   );

};
