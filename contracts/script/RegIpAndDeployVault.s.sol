// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

import { console2 } from "forge-std/console2.sol";
import { Script } from "forge-std/Script.sol";
import { ICreate3Deployer } from "@storyprotocol/script/utils/ICreate3Deployer.sol";
import { ILicenseAttachmentWorkflows } from "@storyprotocol/periphery/contracts/workflows/LicenseAttachmentWorkflows.sol";
import { WorkflowStructs } from "@storyprotocol/periphery/contracts/lib/WorkflowStructs.sol";
import { PILFlavors } from "@storyprotocol/core/lib/PILFlavors.sol";
import { Licensing } from "@storyprotocol/core/lib/Licensing.sol";
import { IERC20 } from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import { LicensingModule } from "@storyprotocol/core/modules/licensing/LicensingModule.sol";
import { MockIPGraph } from "@storyprotocol/test/mocks/MockIPGraph.sol";

contract RegIpAndDeployVault is Script {
    // PROXY 1967 IMPLEMENTATION STORAGE SLOTS
    bytes32 internal constant IMPLEMENTATION_SLOT = 0x360894a13ba1a3210667c828492db98dca3e2076cc3735a920a3ca505d382bbc;
    ICreate3Deployer internal create3Deployer = ICreate3Deployer(0x9fBB3DF7C40Da2e5A0dE984fFE2CCB7C47cd0ABf);
    uint256 internal create3SaltSeed;
    ILicenseAttachmentWorkflows internal constant LICENSE_ATTACHMENT_WORKFLOWS =
        ILicenseAttachmentWorkflows(0xcC2E862bCee5B6036Db0de6E06Ae87e524a79fd8);
    address internal constant ROYALTY_MODULE = 0xD2f60c40fEbccf6311f8B47c4f2Ec6b040400086;
    address internal constant TOKENIZER_MODULE = 0xAC937CeEf893986A026f701580144D9289adAC4C;
    address internal constant IP_ASSET_REGISTRY = 0x77319B4031e6eF1250907aa00018B8B1c67a244b;
    address internal constant NFT_CONTRACT = 0xb3DC3f0928db553FAf461090cC4c051C07a08baE;
    address payable internal constant WIP_TOKEN = payable(0x1514000000000000000000000000000000000000);
    address internal constant LICENSE_MODULE = 0x04fbd8a2e56dd85CFD5500A4A4DfA955B9f1dE6f;

    address internal ADMIN = vm.envAddress("ADMIN");

    function run() public virtual {
        vm.etch(address(0x0101), address(new MockIPGraph()).code);
        vm.startBroadcast(vm.envUint("PK"));
        _registerIpAndDeployVault();
        vm.stopBroadcast();
    }

    function _registerIpAndDeployVault() internal {
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
        uint256[] memory licenseTermsIds;
        address ipId;
        uint256 ipNftTokenId;
        (ipId, ipNftTokenId, licenseTermsIds) = LICENSE_ATTACHMENT_WORKFLOWS.mintAndRegisterIpAndAttachPILTerms({
            spgNftContract: NFT_CONTRACT,
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

        // get some wip
        (bool success, ) = WIP_TOKEN.call{ value: 1 ether }(abi.encodeWithSignature("deposit()"));
        require(success, "Failed to deposit to WIP token");

        // approve 1 WIP to royalty module
        IERC20(WIP_TOKEN).approve(ROYALTY_MODULE, 1 ether);

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

        console2.log("ipId", ipId);
    }
}
