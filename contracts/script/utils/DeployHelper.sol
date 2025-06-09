// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

// import { Script } from "forge-std/Script.sol";
// import { ICreate3Deployer } from "@create3-deployer/contracts/ICreate3Deployer.sol";
// import { JsonDeploymentHandler } from "@storyprotocol/periphery/script/utils/JsonDeploymentHandler.s.sol";
// import { BroadcastManager } from "./BroadcastManager.sol";

// contract DeployerHelper is Script, BroadcastManager {
//     // PROXY 1967 IMPLEMENTATION STORAGE SLOTS
//     bytes32 internal constant IMPLEMENTATION_SLOT = 0x360894a13ba1a3210667c828492db98dca3e2076cc3735a920a3ca505d382bbc;

//     AsclepiusIPVaultFactory public asclepiusIPVaultFactory;
//     AsclepiusIPVault public asclepiusIPVaultTemplate;
//     AsclepiusIPDistributionContract public asclepiusIPDistributionContractTemplate;

//     constructor(
//         address create3Deployer_
//     ) JsonDeploymentHandler("main") {
//         create3Deployer = ICreate3Deployer(create3Deployer_);
//     }

//     function run(
//         uint256 create3SaltSeed_,
//         bool runStorageLayoutCheck,
//         bool writeDeploys_,
//         bool isTest
//     ) public virtual {
//         create3SaltSeed = create3SaltSeed_;
//         writeDeploys = writeDeploys_;

//         // This will run OZ storage layout check for all contracts. Requires --ffi flag.
//         if (runStorageLayoutCheck) _validate(); // StorageLayoutChecker.s.sol

//         if (isTest) {
//             // local test deployment
//             _deployAsclepiusContracts();
//         } else {
//             // production deployment
//             _beginBroadcast();
//             _deployAsclepiusContracts();
//             _endBroadcast();
//         }
//     }

//     function _deployAsclepiusContracts() internal {

//     }
// }
