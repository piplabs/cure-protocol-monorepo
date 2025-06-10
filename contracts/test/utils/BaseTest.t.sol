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

import { AsclepiusIPVault } from "../../contracts/AsclepiusIPVault.sol";
import { AsclepiusIPVaultFactory } from "../../contracts/AsclepiusIPVaultFactory.sol";
import { AsclepiusIPDistributionContract } from "../../contracts/AsclepiusIPDistributionContract.sol";
import { IAsclepiusIPDistributionContract } from "../../contracts/interfaces/IAsclepiusIPDistributionContract.sol";

contract BaseTest is Test, PeripheryBaseTest {
    UpgradeableBeacon internal asclepiusIPVaultBeacon;
    AsclepiusIPVaultFactory internal asclepiusIPVaultFactory;
    AsclepiusIPVault internal asclepiusIPVaultTemplate;
    AsclepiusIPVault internal asclepiusIPVaultInstance;
    UpgradeableBeacon internal asclepiusIPDistributionBeacon;
    AsclepiusIPDistributionContract internal asclepiusIPDistributionContractTemplate;
    AsclepiusIPDistributionContract internal asclepiusIPDistributionContract;

    /// @dev Distribution contract test params
    address internal testIpId;
    MockERC20 internal rewardToken;
    MockERC20 internal stakingTokenA;
    MockERC20 internal stakingTokenB;
    address[] internal stakingTokens;
    uint256 internal allocPointsA;
    uint256 internal allocPointsB;
    uint256[] internal allocPoints;
    address internal testProtocolTreasury;
    uint32 internal testProtocolTaxRate;
    uint256 internal testRewardDistributionPeriod;

    /// @dev AsclepiusIPVault test params
    uint256 internal testExpiredTime;
    address internal testFundReceiver;
    string internal testRwipName;
    string internal testFractionalTokenName;
    string internal testFractionalTokenSymbol;
    uint256 internal testTotalSupplyOfFractionalToken;
    MockERC20 internal mockUsdc;
    WorkflowStructs.LicenseTermsData[] internal licenseTerms;

    function setUp() public virtual override {
        super.setUp();
        _setUpTestParams();
        _deployAsclepiusContracts();
        _createAsclepiusIPVaultInstance();
    }

    function _setUpTestParams() internal virtual {
        stakingTokenA = new MockERC20("StakingTokenA", "STAKINGA");
        stakingTokenB = new MockERC20("StakingTokenB", "STAKINGB");
        rewardToken = mockToken;
        allocPointsA = 80;
        allocPointsB = 20;
        testProtocolTreasury = address(0x1234567890);
        testProtocolTaxRate = 2_000_000; // 2%
        testRewardDistributionPeriod = 1_000_000; // 1 million blocks

        licenseTerms.push(
            WorkflowStructs.LicenseTermsData({
                terms: PILFlavors.commercialRemix({
                    mintingFee: 100 * 10 ** MockERC20(rewardToken).decimals(), // 100 reward tokens
                    commercialRevShare: 10_000_000, // 10%
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

        WorkflowStructs.RoyaltyShare[] memory royaltyShares = new WorkflowStructs.RoyaltyShare[](1);
        royaltyShares[0] = WorkflowStructs.RoyaltyShare({
            recipient: u.admin,
            percentage: 100_000_000 // 100%
        });

        vm.startPrank(u.admin);
        mockToken.mint(u.admin, 1 * 10 ** mockToken.decimals());
        mockToken.approve(address(spgNftPublic), 1 * 10 ** mockToken.decimals());
        (testIpId, , ) = royaltyTokenDistributionWorkflows
            .mintAndRegisterIpAndAttachPILTermsAndDistributeRoyaltyTokens({
                spgNftContract: address(spgNftPublic),
                recipient: u.admin,
                ipMetadata: ipMetadataDefault,
                licenseTermsData: licenseTerms,
                royaltyShares: royaltyShares,
                allowDuplicates: true
            });
        vm.stopPrank();

        vm.label(testIpId, "IpId");
        vm.label(address(stakingTokenA), "StakingTokenA");
        vm.label(address(stakingTokenB), "StakingTokenB");
        vm.label(address(rewardToken), "RewardToken");
        vm.label(testProtocolTreasury, "ProtocolTreasury");

        testExpiredTime = block.timestamp + 30 days;
        testFundReceiver = u.dan;
        testRwipName = "TEST RWIP";
        testFractionalTokenName = "TEST FRACTIONAL TOKEN";
        testFractionalTokenSymbol = "TFT";
        testTotalSupplyOfFractionalToken = 1_000_000_000 * 10 ** 18; // 1 billion
        mockUsdc = new MockERC20("MockUSDC", "USDC");
        vm.label(address(mockUsdc), "MockUSDC");
    }

    function _deployAsclepiusContracts() internal virtual {
        address impl;

        asclepiusIPVaultTemplate = new AsclepiusIPVault(
            address(royaltyTokenDistributionWorkflows),
            address(royaltyModule),
            address(tokenizerModule),
            _getDeployedAddress("AsclepiusIPVaultBeacon")
        );
        vm.label(address(asclepiusIPVaultTemplate), "AsclepiusIPVaultTemplate");

        asclepiusIPVaultBeacon = new UpgradeableBeacon(
            create3Deployer.deployDeterministic(
                abi.encodePacked(type(UpgradeableBeacon).creationCode, abi.encode(asclepiusIPVaultTemplate, u.admin)),
                _getSalt("AsclepiusIPVaultBeacon")
            ),
            address(this)
        );
        vm.label(address(asclepiusIPVaultBeacon), "AsclepiusIPVaultBeacon");

        impl = address(new AsclepiusIPVaultFactory());
        asclepiusIPVaultFactory = AsclepiusIPVaultFactory(
            TestProxyHelper.deployUUPSProxy(
                create3Deployer,
                _getSalt("AsclepiusIPVaultFactory"),
                impl,
                abi.encodeCall(AsclepiusIPVaultFactory.initialize, (u.admin, address(asclepiusIPVaultTemplate)))
            )
        );
        vm.label(address(asclepiusIPVaultFactory), "AsclepiusIPVaultFactory");

        stakingTokens = new address[](2);
        stakingTokens[0] = address(stakingTokenA);
        stakingTokens[1] = address(stakingTokenB);

        allocPoints = new uint256[](2);
        allocPoints[0] = allocPointsA;
        allocPoints[1] = allocPointsB;

        asclepiusIPDistributionContractTemplate = new AsclepiusIPDistributionContract(
            address(royaltyModule),
            _getDeployedAddress("AsclepiusIPDistributionBeacon")
        );
        vm.label(address(asclepiusIPDistributionContractTemplate), "AsclepiusIPDistributionContractTemplate");

        asclepiusIPDistributionBeacon = new UpgradeableBeacon(
            create3Deployer.deployDeterministic(
                abi.encodePacked(
                    type(UpgradeableBeacon).creationCode,
                    abi.encode(asclepiusIPDistributionContractTemplate, u.admin)
                ),
                _getSalt("AsclepiusIPDistributionBeacon")
            ),
            address(this)
        );
        vm.label(address(asclepiusIPDistributionBeacon), "AsclepiusIPDistributionBeacon");

        IAsclepiusIPDistributionContract.InitData memory initData = IAsclepiusIPDistributionContract.InitData({
            admin: u.admin,
            ipId: testIpId,
            protocolTreasury: testProtocolTreasury,
            protocolTaxRate: testProtocolTaxRate,
            rewardDistributionPeriod: testRewardDistributionPeriod,
            rewardToken: address(rewardToken),
            fractionalTokenAllocPoints: allocPointsA
        });

        asclepiusIPDistributionContract = AsclepiusIPDistributionContract(
            address(
                new BeaconProxy(
                    asclepiusIPDistributionContractTemplate.getUpgradeableBeacon(),
                    abi.encodeCall(AsclepiusIPDistributionContract.initialize, (address(stakingTokenA), initData))
                )
            )
        );
        vm.label(address(asclepiusIPDistributionContract), "AsclepiusIPDistributionContract");

        vm.startPrank(u.admin);
        IERC20(royaltyModule.ipRoyaltyVaults(testIpId)).transfer(address(asclepiusIPDistributionContract), 100_000_000);
        asclepiusIPDistributionContract.addStakingPool(address(stakingTokenB), allocPointsB);
        vm.stopPrank();
    }

    function _createAsclepiusIPVaultInstance() internal virtual {
        asclepiusIPVaultInstance = AsclepiusIPVault(
            asclepiusIPVaultFactory.deployIpVault({
                vaultAdmin: u.admin,
                expiredTime: testExpiredTime,
                fundReceiver: testFundReceiver,
                rwipName: testRwipName,
                fractionalTokenName: testFractionalTokenName,
                fractionalTokenSymbol: testFractionalTokenSymbol,
                totalSupplyOfFractionalToken: testTotalSupplyOfFractionalToken,
                usdcContractAddress: address(mockUsdc)
            })
        );
    }
}
