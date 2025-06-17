// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

import { console2 } from "forge-std/console2.sol";
import { Script } from "forge-std/Script.sol";
import { IERC721 } from "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import { MockIPGraph } from "@storyprotocol/test/mocks/MockIPGraph.sol";
import { UpgradeableBeacon } from "@openzeppelin/contracts/proxy/beacon/UpgradeableBeacon.sol";
import { ICreate3Deployer } from "@storyprotocol/script/utils/ICreate3Deployer.sol";
import { TestProxyHelper } from "@storyprotocol/test/utils/TestProxyHelper.sol";
import { IRegistrationWorkflows } from "@storyprotocol/periphery/contracts/interfaces/workflows/IRegistrationWorkflows.sol";
import { ILicenseAttachmentWorkflows } from "@storyprotocol/periphery/contracts/interfaces/workflows/ILicenseAttachmentWorkflows.sol";
import { ISPGNFT } from "@storyprotocol/periphery/contracts/interfaces/ISPGNFT.sol";
import { WorkflowStructs } from "@storyprotocol/periphery/contracts/lib/WorkflowStructs.sol";
import { PILFlavors } from "@storyprotocol/core/lib/PILFlavors.sol";
import { Licensing } from "@storyprotocol/core/lib/Licensing.sol";

import { IAscCurate } from "../../contracts/interfaces/IAscCurate.sol";
import { AscCurate } from "../../contracts/AscCurate.sol";
import { AscCurateFactory } from "../../contracts/AscCurateFactory.sol";

contract DeployerHelper is Script {
    // PROXY 1967 IMPLEMENTATION STORAGE SLOTS
    bytes32 internal constant IMPLEMENTATION_SLOT = 0x360894a13ba1a3210667c828492db98dca3e2076cc3735a920a3ca505d382bbc;
    ICreate3Deployer internal create3Deployer = ICreate3Deployer(0x9fBB3DF7C40Da2e5A0dE984fFE2CCB7C47cd0ABf);
    uint256 internal create3SaltSeed;

    IRegistrationWorkflows internal constant REGISTRATION_WORKFLOWS =
        IRegistrationWorkflows(0xbe39E1C756e921BD25DF86e7AAa31106d1eb0424);
    ILicenseAttachmentWorkflows internal constant LICENSE_ATTACHMENT_WORKFLOWS =
        ILicenseAttachmentWorkflows(0xcC2E862bCee5B6036Db0de6E06Ae87e524a79fd8);
    address internal constant ROYALTY_MODULE = 0xD2f60c40fEbccf6311f8B47c4f2Ec6b040400086;
    address internal constant TOKENIZER_MODULE = 0xAC937CeEf893986A026f701580144D9289adAC4C;
    address internal constant IP_ASSET_REGISTRY = 0x77319B4031e6eF1250907aa00018B8B1c67a244b;

    address internal ADMIN = vm.envAddress("ADMIN");

    function run(uint256 create3SaltSeed_, bool isTest) public virtual {
        create3SaltSeed = create3SaltSeed_;

        vm.etch(address(0x0101), address(new MockIPGraph()).code);

        if (isTest) {
            // local test deployment
            _deployAsclepiusContracts();
        } else {
            // production deployment
            vm.startBroadcast(vm.envUint("PK"));
            _deployAsclepiusContracts();
            vm.stopBroadcast();
        }
    }

    function _deployAsclepiusContracts() internal {
        // create collection
        address collection = REGISTRATION_WORKFLOWS.createCollection(
            ISPGNFT.InitParams({
                name: "AscCurate_TEST",
                symbol: "ASC_TEST",
                baseURI: "https://asc.storyprotocol.io/ip/",
                contractURI: "https://asc.storyprotocol.io/ip/",
                maxSupply: 10000,
                mintFee: 0,
                mintFeeToken: address(0),
                mintFeeRecipient: ADMIN,
                owner: ADMIN,
                mintOpen: true,
                isPublicMinting: true
            })
        );

        // register IP
        WorkflowStructs.LicenseTermsData[] memory licenseTermsData = new WorkflowStructs.LicenseTermsData[](1);
        licenseTermsData[0] = WorkflowStructs.LicenseTermsData({
            terms: PILFlavors.commercialRemix({
                mintingFee: 1 ether,
                commercialRevShare: 1e7, // 10%
                royaltyPolicy: 0x9156e603C949481883B1d3355c6f1132D191fC41, // LRP
                currencyToken: 0x1514000000000000000000000000000000000000 // WIP
            }),
            licensingConfig: Licensing.LicensingConfig({
                isSet: false,
                mintingFee: 1 ether,
                licensingHook: address(0),
                hookData: "",
                commercialRevShare: 1e7, // 10%
                disabled: false,
                expectMinimumGroupRewardShare: 0,
                expectGroupRewardPool: address(0)
            })
        });
        (address ipId, uint256 ipNftTokenId, ) = LICENSE_ATTACHMENT_WORKFLOWS.mintAndRegisterIpAndAttachPILTerms({
            spgNftContract: collection,
            recipient: ADMIN,
            ipMetadata: WorkflowStructs.IPMetadata({
                ipMetadataURI: "TEST",
                ipMetadataHash: bytes32(0),
                nftMetadataURI: "TEST",
                nftMetadataHash: bytes32(0)
            }),
            licenseTermsData: licenseTermsData,
            allowDuplicates: true
        });

        // deploy template
        // OwnableERC20 template
        _predeploy("AscCurateTemplate");
        address ascCurateTemplate = address(
            create3Deployer.deployDeterministic(
                abi.encodePacked(
                    type(AscCurate).creationCode,
                    abi.encode(
                        ROYALTY_MODULE,
                        TOKENIZER_MODULE,
                        _getDeployedAddress("AscCurateBeacon"),
                        IP_ASSET_REGISTRY
                    )
                ),
                _getSalt(string.concat(type(AscCurate).name))
            )
        );
        _postdeploy("AscCurateTemplate", ascCurateTemplate);

        // Upgradeable Beacon for OwnableERC20Template
        _predeploy("AscCurateBeacon");
        address ascCurateBeacon = address(
            create3Deployer.deployDeterministic(
                abi.encodePacked(type(UpgradeableBeacon).creationCode, abi.encode(ascCurateTemplate, ADMIN)),
                _getSalt("AscCurateBeacon")
            )
        );
        _postdeploy("AscCurateBeacon", ascCurateBeacon);
        require(
            UpgradeableBeacon(ascCurateBeacon).implementation() == address(ascCurateTemplate),
            "DeployHelper: Invalid beacon implementation"
        );
        require(
            AscCurate(ascCurateTemplate).getUpgradeableBeacon() == address(ascCurateBeacon),
            "DeployHelper: Invalid beacon address in template"
        );

        // deploy factory
        address impl = address(new AscCurateFactory());
        address ascCurateFactory = TestProxyHelper.deployUUPSProxy(
            create3Deployer,
            _getSalt(type(AscCurateFactory).name),
            impl,
            abi.encodeCall(AscCurateFactory.initialize, (ADMIN, ascCurateTemplate))
        );
        _postdeploy("AscCurateFactory", ascCurateFactory);

        // launch curate
        IERC721(collection).approve(ascCurateFactory, 1);
        AscCurateFactory(ascCurateFactory).launchCurate(
            IAscCurate.CurateInitData({
                admin: ADMIN,
                ipId: ipId,
                ipNft: collection,
                ipNftTokenId: ipNftTokenId,
                expirationTime: 2034216000, // in 10 years
                fundReceiver: ADMIN,
                bioName: "AscCurate_TEST",
                bioTokenName: "ASC_TEST",
                bioTokenSymbol: "ASC_TEST",
                minimalIpTokenForLaunch: 1,
                rewardToken: 0x1514000000000000000000000000000000000000
            })
        );
    }

    /// @dev get the salt for the contract deployment with CREATE3
    function _getSalt(string memory name) internal view returns (bytes32 salt) {
        salt = keccak256(abi.encode(name, create3SaltSeed));
    }

    /// @dev Get the deterministic deployed address of a contract with CREATE3
    function _getDeployedAddress(string memory name) internal view returns (address) {
        return create3Deployer.predictDeterministicAddress(_getSalt(name));
    }

    /// @dev Load the implementation address from the proxy contract
    function _loadProxyImpl(address proxy) internal view returns (address) {
        return address(uint160(uint256(vm.load(proxy, IMPLEMENTATION_SLOT))));
    }

    function _predeploy(string memory contractKey) internal pure {
        console2.log(string.concat("Deploying ", contractKey, "..."));
    }

    function _postdeploy(string memory contractKey, address newAddress) internal pure {
        console2.log(string.concat(contractKey, " deployed to:"), newAddress);
    }
}
