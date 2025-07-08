// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

import { console2 } from "forge-std/console2.sol";
import { Script } from "forge-std/Script.sol";
import { IERC721 } from "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import { MockIPGraph } from "@storyprotocol/test/mocks/MockIPGraph.sol";
import { ICreate3Deployer } from "@storyprotocol/script/utils/ICreate3Deployer.sol";
import { IRegistrationWorkflows } from "@storyprotocol/periphery/contracts/interfaces/workflows/IRegistrationWorkflows.sol";
import { ILicenseAttachmentWorkflows } from "@storyprotocol/periphery/contracts/interfaces/workflows/ILicenseAttachmentWorkflows.sol";
import { ISPGNFT } from "@storyprotocol/periphery/contracts/interfaces/ISPGNFT.sol";
import { WorkflowStructs } from "@storyprotocol/periphery/contracts/lib/WorkflowStructs.sol";
import { PILFlavors } from "@storyprotocol/core/lib/PILFlavors.sol";
import { Licensing } from "@storyprotocol/core/lib/Licensing.sol";
import { IERC20 } from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import { LicensingModule } from "@storyprotocol/core/modules/licensing/LicensingModule.sol";

import { IAscCurate } from "../contracts/interfaces/IAscCurate.sol";
import { AscCurateFactory } from "../contracts/AscCurateFactory.sol";

contract LaunchCurateWithIpRegistration is Script {
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
    address internal constant ascCurateFactory = 0xd85BF1961AC862D14F10fC7430eC28881536EB75;
    address internal constant ASC_CURATE_TEMPLATE = 0x85E1074D96662Db83a2Eb49e1f1f355fFD3B9436;
    address internal constant LICENSE_MODULE = 0x04fbd8a2e56dd85CFD5500A4A4DfA955B9f1dE6f;
    address payable internal constant WIP_TOKEN = payable(0x1514000000000000000000000000000000000000);

    address internal ADMIN = vm.envAddress("ADMIN");

    function run() public virtual {
        vm.etch(address(0x0101), address(new MockIPGraph()).code);
        vm.startBroadcast(vm.envUint("PK"));
        _registerIpAndLaunchCurate();
        vm.stopBroadcast();
    }

    function _registerIpAndLaunchCurate() internal {
        // Create collection
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

        console2.log("Collection created at:", collection);

        // Register IP
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

        uint256[] memory licenseTermsIds;
        address ipId;
        uint256 ipNftTokenId;
        (ipId, ipNftTokenId, licenseTermsIds) = LICENSE_ATTACHMENT_WORKFLOWS.mintAndRegisterIpAndAttachPILTerms({
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

        console2.log("IP registered with ID:", ipId);
        console2.log("IP NFT Token ID:", ipNftTokenId);

        // Get some WIP tokens
        (bool success, ) = WIP_TOKEN.call{ value: 1 ether }(abi.encodeWithSignature("deposit()"));
        require(success, "Failed to deposit to WIP token");

        // Approve 1 WIP to royalty module
        IERC20(WIP_TOKEN).approve(ROYALTY_MODULE, 1 ether);

        // Mint license tokens
        LicensingModule(LICENSE_MODULE).mintLicenseTokens({
            licensorIpId: ipId,
            licenseTemplate: 0x2E896b0b2Fdb7457499B56AAaA4AE55BCB4Cd316,
            licenseTermsId: licenseTermsIds[0],
            amount: 1,
            receiver: ADMIN,
            royaltyContext: "",
            maxMintingFee: 1 ether,
            maxRevenueShare: 1e7
        });

        console2.log("License tokens minted");

        // Approve the NFT for the factory
        IERC721(collection).approve(ascCurateFactory, ipNftTokenId);

        // Launch curate
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

        console2.log("Curate launched successfully!");
        console2.log("IP ID:", ipId);
        console2.log("Collection:", collection);
        console2.log("IP NFT Token ID:", ipNftTokenId);
    }
}
