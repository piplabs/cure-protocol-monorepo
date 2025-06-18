// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.26;

import { Test } from "forge-std/Test.sol";
import { IERC20 } from "@openzeppelin/contracts/interfaces/IERC20.sol";
import { BeaconProxy } from "@openzeppelin/contracts/proxy/beacon/BeaconProxy.sol";
import { UpgradeableBeacon } from "@openzeppelin/contracts/proxy/beacon/UpgradeableBeacon.sol";
import { BaseTest as PeripheryBaseTest } from "@storyprotocol/periphery/test/utils/BaseTest.t.sol";
import { TestProxyHelper } from "@storyprotocol/test/utils/TestProxyHelper.sol";
import { WorkflowStructs } from "@storyprotocol/periphery/contracts/lib/WorkflowStructs.sol";
import { PILFlavors } from "@storyprotocol/core/lib/PILFlavors.sol";
import { Licensing } from "@storyprotocol/core/lib/Licensing.sol";
import { MockERC20 } from "@storyprotocol/periphery/test/mocks/MockERC20.sol";
import { OwnableERC20 } from "@storyprotocol/periphery/contracts/modules/tokenizer/OwnableERC20.sol";

import { AscCurate } from "../../contracts/AscCurate.sol";
import { AscCurateFactory } from "../../contracts/AscCurateFactory.sol";
import { AscStaking } from "../../contracts/AscStaking.sol";
import { IAscCurate } from "../../contracts/interfaces/IAscCurate.sol";
import { IAscStaking } from "../../contracts/interfaces/IAscStaking.sol";

contract BaseTest is Test, PeripheryBaseTest {
    UpgradeableBeacon internal ascCurateBeacon;
    AscCurateFactory internal ascCurateFactory;
    AscCurate internal ascCurateTemplate;
    UpgradeableBeacon internal ascStakingBeacon;
    AscStaking internal ascStakingTemplate;
    
    // Bio token template
    OwnableERC20 internal bioTokenTemplate;

    /// @dev Staking contract test params
    address internal testIpId;
    uint256 internal testIpNftTokenId;
    MockERC20 internal rewardToken;
    uint256 internal testRewardDistributionPeriod;
    uint256 internal testBioTokenAllocPoints;

    /// @dev AscCurate test params
    uint256 internal testExpirationTime;
    address internal testFundReceiver;
    string internal testBioName;
    string internal testBioTokenName;
    string internal testBioTokenSymbol;
    uint256 internal testMinimalIpTokenForLaunch;
    uint256 internal testTotalBioTokenSupply;
    WorkflowStructs.LicenseTermsData[] internal licenseTerms;
    uint256[] internal licenseTermsIds;

    function setUp() public virtual override {
        super.setUp();
        _setUpTestParams();
        _deployAsclepiusContracts();
    }

    function _setUpTestParams() internal virtual {
        rewardToken = mockToken;
        vm.label(address(rewardToken), "RewardToken");
        testRewardDistributionPeriod = 1_000_000; // 1 million blocks
        testBioTokenAllocPoints = 100;

        licenseTerms.push(
            WorkflowStructs.LicenseTermsData({
                terms: PILFlavors.commercialRemix({
                    mintingFee: 100 * 10 ** MockERC20(rewardToken).decimals(), // 100 reward tokens
                    commercialRevShare: 10 * 10 ** 6, // 10%
                    royaltyPolicy: royaltyPolicyLAPAddr,
                    currencyToken: address(rewardToken)
                }),
                licensingConfig: Licensing.LicensingConfig({
                    isSet: false,
                    mintingFee: 0,
                    licensingHook: address(0),
                    hookData: "",
                    commercialRevShare: 0,
                    disabled: false,
                    expectMinimumGroupRewardShare: 0,
                    expectGroupRewardPool: address(0)
                })
            })
        );

        vm.startPrank(u.admin);
        mockToken.mint(u.admin, 1000 * 10 ** mockToken.decimals());
        mockToken.approve(address(spgNftPublic), 1 * 10 ** mockToken.decimals());
        (testIpId, testIpNftTokenId, licenseTermsIds) = licenseAttachmentWorkflows
            .mintAndRegisterIpAndAttachPILTerms({
                spgNftContract: address(spgNftPublic),
                recipient: u.admin,
                ipMetadata: ipMetadataDefault,
                licenseTermsData: licenseTerms,
                allowDuplicates: true
            });
        vm.label(testIpId, "IpId");
        uint256 licenseTermsId = licenseTermsIds[0];
        (address defaultLicenseTemplate, ) = licenseRegistry.getDefaultLicenseTerms();
        
        mockToken.approve(address(royaltyModule), 100 * 10 ** mockToken.decimals());
        
        licensingModule.mintLicenseTokens({
            licensorIpId: testIpId,
            licenseTemplate: defaultLicenseTemplate,
            licenseTermsId: licenseTermsId,
            amount: 1,
            receiver: testIpId,
            royaltyContext: "",
            maxMintingFee: 0,
            maxRevenueShare: 0
        });
        
        vm.stopPrank();

        vm.label(testIpId, "IpId");
        vm.label(address(rewardToken), "RewardToken");
        vm.label(u.admin, "Admin");

        testExpirationTime = block.timestamp + 30 days;
        testFundReceiver = u.dan;
        testBioName = "Test Bio Project";
        testBioTokenName = "Test Bio Token";
        testBioTokenSymbol = "TBT";
        testMinimalIpTokenForLaunch = 1 ether; // 1 ETH minimum
        testTotalBioTokenSupply = 1_000_000_000 * 10 ** 18; // 1 billion tokens
    }

    function _deployAsclepiusContracts() internal virtual {
        // Deploy bio token implementation
        OwnableERC20 bioTokenImpl = new OwnableERC20(address(0));
        vm.label(address(bioTokenImpl), "BioTokenImpl");
        
        // Deploy bio token beacon
        UpgradeableBeacon bioTokenBeacon = new UpgradeableBeacon(address(bioTokenImpl), address(this));
        vm.label(address(bioTokenBeacon), "BioTokenBeacon");
        
        // Deploy bio token template (which is now a beacon proxy template)
        bioTokenTemplate = new OwnableERC20(address(bioTokenBeacon));
        vm.label(address(bioTokenTemplate), "BioTokenTemplate");
        
        // Whitelist the bio token template in the tokenizer module
        vm.prank(u.admin);
        tokenizerModule.whitelistTokenTemplate(address(bioTokenTemplate), true);

        // Deploy AscStaking template and beacon
        // First deploy a placeholder beacon to get the address
        ascStakingBeacon = new UpgradeableBeacon(address(this), address(this));
        
        // Now deploy the template with the correct beacon address
        ascStakingTemplate = new AscStaking(
            address(royaltyModule),
            address(ascStakingBeacon)
        );
        vm.label(address(ascStakingTemplate), "AscStakingTemplate");

        // Update the beacon to point to the actual template
        ascStakingBeacon.upgradeTo(address(ascStakingTemplate));
        vm.label(address(ascStakingBeacon), "AscStakingBeacon");

        // Deploy AscCurate template and beacon
        // First deploy a placeholder beacon to get the address
        ascCurateBeacon = new UpgradeableBeacon(address(this), address(this));
        
        // Now deploy the template with the correct beacon address
        ascCurateTemplate = new AscCurate(
            address(royaltyModule),
            address(tokenizerModule),
            address(ascCurateBeacon),
            address(ipAssetRegistry)
        );
        vm.label(address(ascCurateTemplate), "AscCurateTemplate");

        // Update the beacon to point to the actual template
        ascCurateBeacon.upgradeTo(address(ascCurateTemplate));
        vm.label(address(ascCurateBeacon), "AscCurateBeacon");

        // Deploy AscCurateFactory
        address factoryImpl = address(new AscCurateFactory());
        ascCurateFactory = AscCurateFactory(
            TestProxyHelper.deployUUPSProxy(
                create3Deployer,
                _getSalt("AscCurateFactory"),
                factoryImpl,
                abi.encodeCall(AscCurateFactory.initialize, (u.admin, address(ascCurateTemplate)))
            )
        );
        vm.label(address(ascCurateFactory), "AscCurateFactory");
    }

    /// @dev Helper function to create AscStaking InitData
    function _createStakingInitData(address ipId) internal view returns (IAscStaking.InitData memory) {
        return IAscStaking.InitData({
            admin: u.admin,
            ipId: ipId,
            rewardDistributionPeriod: testRewardDistributionPeriod,
            rewardToken: address(rewardToken),
            bioTokenAllocPoints: testBioTokenAllocPoints
        });
    }

    /// @dev Helper function to create AscCurate InitData
    function _createCurateInitData(
        address ipId,
        address ipNft,
        uint256 ipNftTokenId
    ) internal view returns (IAscCurate.CurateInitData memory) {
        return IAscCurate.CurateInitData({
            admin: u.admin,
            ipId: ipId,
            ipNft: ipNft,
            ipNftTokenId: ipNftTokenId,
            expirationTime: testExpirationTime,
            fundReceiver: testFundReceiver,
            bioName: testBioName,
            bioTokenName: testBioTokenName,
            bioTokenSymbol: testBioTokenSymbol,
            minimalIpTokenForLaunch: testMinimalIpTokenForLaunch,
            rewardToken: address(rewardToken)
        });
    }
}
