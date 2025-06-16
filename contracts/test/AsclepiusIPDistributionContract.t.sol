// // SPDX-License-Identifier: UNLICENSED
// pragma solidity 0.8.26;

// import { console2 } from "forge-std/console2.sol";
// import { MockERC20 } from "@storyprotocol/periphery/test/mocks/MockERC20.sol";

// import { IAsclepiusIPDistributionContract } from "../contracts/interfaces/IAsclepiusIPDistributionContract.sol";
// import { BaseTest } from "./utils/BaseTest.t.sol";

// contract AsclepiusIPDistributionContractTest is BaseTest {
//     function setUp() public override {
//         super.setUp();
//     }

//     function test_AsclepiusIPDistributionContract_initialize() public {
//         // an instance is deployed and initialized in the BaseTest setUp

//         // check that the instance is initialized correctly
//         assertEq(asclepiusIPDistributionContract.getAdmin(), u.admin);
//         assertEq(asclepiusIPDistributionContract.getIpId(), testIpId);
//         assertEq(asclepiusIPDistributionContract.getProtocolTreasury(), testProtocolTreasury);
//         assertEq(asclepiusIPDistributionContract.getProtocolTaxRate(), testProtocolTaxRate);
//         assertEq(asclepiusIPDistributionContract.getRewardDistributionPeriod(), testRewardDistributionPeriod);
//         assertEq(asclepiusIPDistributionContract.getCurrentDistributionEndBlock(), 0);
//         assertEq(asclepiusIPDistributionContract.getRewardToken(), address(rewardToken));
//         assertEq(asclepiusIPDistributionContract.getTotalAllocPoints(), allocPointsA + allocPointsB);
//         assertEq(asclepiusIPDistributionContract.getPoolAllocPoints(address(stakingTokenA)), allocPointsA);
//         assertEq(asclepiusIPDistributionContract.getPoolAllocPoints(address(stakingTokenB)), allocPointsB);
//         assertEq(asclepiusIPDistributionContract.getPoolTotalStakedBalance(address(stakingTokenA)), 0);
//         assertEq(asclepiusIPDistributionContract.getPoolTotalStakedBalance(address(stakingTokenB)), 0);
//     }

//     function test_AsclepiusIPDistributionContract_deposit() public {
//         _aliceDeposits(stakingTokenA, 100);

//         _assertStakingBalances({
//             stakingToken: stakingTokenA,
//             aliceTokenBalance: 0,
//             bobTokenBalance: 0,
//             carlTokenBalance: 0,
//             danTokenBalance: 0,
//             aliceStakingBalance: 100,
//             bobStakingBalance: 0,
//             carlStakingBalance: 0,
//             danStakingBalance: 0
//         });

//         vm.roll(block.number + 50);

//         _bobDeposits(stakingTokenA, 200);

//         _assertStakingBalances({
//             stakingToken: stakingTokenA,
//             aliceTokenBalance: 0,
//             bobTokenBalance: 0,
//             carlTokenBalance: 0,
//             danTokenBalance: 0,
//             aliceStakingBalance: 100,
//             bobStakingBalance: 200,
//             carlStakingBalance: 0,
//             danStakingBalance: 0
//         });

//         vm.roll(block.number + 150);

//         _aliceDeposits(stakingTokenB, 300);

//         _assertStakingBalances({
//             stakingToken: stakingTokenB,
//             aliceTokenBalance: 0,
//             bobTokenBalance: 0,
//             carlTokenBalance: 0,
//             danTokenBalance: 0,
//             aliceStakingBalance: 300,
//             bobStakingBalance: 0,
//             carlStakingBalance: 0,
//             danStakingBalance: 0
//         });

//         vm.roll(block.number + 250);

//         _bobDeposits(stakingTokenB, 500);

//         _assertStakingBalances({
//             stakingToken: stakingTokenB,
//             aliceTokenBalance: 0,
//             bobTokenBalance: 0,
//             carlTokenBalance: 0,
//             danTokenBalance: 0,
//             aliceStakingBalance: 300,
//             bobStakingBalance: 500,
//             carlStakingBalance: 0,
//             danStakingBalance: 0
//         });
//     }

//     function test_AsclepiusIPDistributionContract_withdraw() public {
//         _aliceDeposits(stakingTokenA, 100);
//         vm.roll(block.number + 50);
//         _aliceDeposits(stakingTokenA, 2000);
//         _aliceDeposits(stakingTokenB, 1000);
//         vm.roll(block.number + 150);
//         _bobDeposits(stakingTokenA, 200);
//         vm.roll(block.number + 250);
//         _bobDeposits(stakingTokenA, 4000);
//         _bobDeposits(stakingTokenB, 5000);
//         vm.roll(block.number + 350);

//         _assertStakingBalances({
//             stakingToken: stakingTokenA,
//             aliceTokenBalance: 0,
//             bobTokenBalance: 0,
//             carlTokenBalance: 0,
//             danTokenBalance: 0,
//             aliceStakingBalance: 100 + 2000,
//             bobStakingBalance: 200 + 4000,
//             carlStakingBalance: 0,
//             danStakingBalance: 0
//         });

//         _assertStakingBalances({
//             stakingToken: stakingTokenB,
//             aliceTokenBalance: 0,
//             bobTokenBalance: 0,
//             carlTokenBalance: 0,
//             danTokenBalance: 0,
//             aliceStakingBalance: 1000,
//             bobStakingBalance: 5000,
//             carlStakingBalance: 0,
//             danStakingBalance: 0
//         });

//         _aliceWithdraws(stakingTokenA, 1500);
//         _aliceWithdraws(stakingTokenB, 555);
//         _bobWithdraws(stakingTokenA, 1234);
//         _bobWithdraws(stakingTokenB, 4321);

//         _assertStakingBalances({
//             stakingToken: stakingTokenA,
//             aliceTokenBalance: 1500,
//             bobTokenBalance: 1234,
//             carlTokenBalance: 0,
//             danTokenBalance: 0,
//             aliceStakingBalance: 100 + 2000 - 1500,
//             bobStakingBalance: 200 + 4000 - 1234,
//             carlStakingBalance: 0,
//             danStakingBalance: 0
//         });

//         _assertStakingBalances({
//             stakingToken: stakingTokenB,
//             aliceTokenBalance: 555,
//             bobTokenBalance: 4321,
//             carlTokenBalance: 0,
//             danTokenBalance: 0,
//             aliceStakingBalance: 1000 - 555,
//             bobStakingBalance: 5000 - 4321,
//             carlStakingBalance: 0,
//             danStakingBalance: 0
//         });
//     }

//     function test_AsclepiusIPDistributionContract_collectRoyalties() public {
//         uint256 amount = 10_000_000 * 10 ** rewardToken.decimals();
//         rewardToken.mint(address(this), amount);
//         rewardToken.approve(address(royaltyModule), amount);
//         royaltyModule.payRoyaltyOnBehalf({ // IP generates 10 million revenue
//                 receiverIpId: testIpId,
//                 payerIpId: address(0),
//                 token: address(rewardToken),
//                 amount: amount
//             });
//         assertEq(rewardToken.balanceOf(royaltyModule.ipRoyaltyVaults(testIpId)), amount);

//         vm.expectEmit();
//         emit IAsclepiusIPDistributionContract.RoyaltiesCollected(
//             testIpId,
//             amount,
//             block.number + testRewardDistributionPeriod
//         );
//         asclepiusIPDistributionContract.collectRoyalties();

//         assertEq(rewardToken.balanceOf(royaltyModule.ipRoyaltyVaults(testIpId)), 0);
//         assertEq(rewardToken.balanceOf(address(asclepiusIPDistributionContract)), amount);
//         assertEq(
//             asclepiusIPDistributionContract.getCurrentDistributionEndBlock(),
//             block.number + testRewardDistributionPeriod
//         );

//         assertEq(
//             asclepiusIPDistributionContract.getRewardPerBlock(address(stakingTokenA)),
//             _getPoolRewardShare(amount, allocPointsA) / testRewardDistributionPeriod
//         );
//         assertEq(
//             asclepiusIPDistributionContract.getRewardPerBlock(address(stakingTokenB)),
//             _getPoolRewardShare(amount, allocPointsB) / testRewardDistributionPeriod
//         );

//         vm.roll(block.number + 500_000); // 500,000 blocks later still in the same distribution period

//         rewardToken.mint(address(this), amount);
//         rewardToken.approve(address(royaltyModule), amount);
//         royaltyModule.payRoyaltyOnBehalf({ // IP generates another 10 million revenue 500,000 blocks later
//                 receiverIpId: testIpId,
//                 payerIpId: address(0),
//                 token: address(rewardToken),
//                 amount: amount
//             });
//         assertEq(rewardToken.balanceOf(royaltyModule.ipRoyaltyVaults(testIpId)), amount);

//         vm.expectEmit();
//         emit IAsclepiusIPDistributionContract.RoyaltiesCollected(
//             testIpId,
//             amount,
//             block.number - 500_000 + testRewardDistributionPeriod
//         );
//         asclepiusIPDistributionContract.collectRoyalties();

//         assertEq(rewardToken.balanceOf(royaltyModule.ipRoyaltyVaults(testIpId)), 0);
//         assertEq(rewardToken.balanceOf(address(asclepiusIPDistributionContract)), amount * 2);
//         assertEq(
//             asclepiusIPDistributionContract.getCurrentDistributionEndBlock(),
//             block.number - 500_000 + testRewardDistributionPeriod
//         );
//         assertEq(
//             asclepiusIPDistributionContract.getRewardPerBlock(address(stakingTokenA)),
//             _getPoolRewardShare(amount * 2, allocPointsA) / (testRewardDistributionPeriod - 500_000)
//         );
//         assertEq(
//             asclepiusIPDistributionContract.getRewardPerBlock(address(stakingTokenB)),
//             _getPoolRewardShare(amount * 2, allocPointsB) / (testRewardDistributionPeriod - 500_000)
//         );

//         vm.roll(block.number + 600_000); // 600,000 blocks later, enters a new distribution period

//         rewardToken.mint(address(this), amount);
//         rewardToken.approve(address(royaltyModule), amount);
//         royaltyModule.payRoyaltyOnBehalf({
//             receiverIpId: testIpId,
//             payerIpId: address(0),
//             token: address(rewardToken),
//             amount: amount
//         });
//         assertEq(rewardToken.balanceOf(royaltyModule.ipRoyaltyVaults(testIpId)), amount);

//         vm.expectEmit();
//         emit IAsclepiusIPDistributionContract.RoyaltiesCollected(
//             testIpId,
//             amount,
//             block.number + testRewardDistributionPeriod
//         );
//         asclepiusIPDistributionContract.collectRoyalties();

//         assertEq(rewardToken.balanceOf(royaltyModule.ipRoyaltyVaults(testIpId)), 0);
//         assertEq(rewardToken.balanceOf(address(asclepiusIPDistributionContract)), amount * 3);
//         assertEq(
//             asclepiusIPDistributionContract.getCurrentDistributionEndBlock(),
//             block.number + testRewardDistributionPeriod
//         );
//         assertEq(
//             asclepiusIPDistributionContract.getRewardPerBlock(address(stakingTokenA)),
//             _getPoolRewardShare(amount * 3, allocPointsA) / testRewardDistributionPeriod
//         );
//         assertEq(
//             asclepiusIPDistributionContract.getRewardPerBlock(address(stakingTokenB)),
//             _getPoolRewardShare(amount * 3, allocPointsB) / testRewardDistributionPeriod
//         );
//     }

//     function test_AsclepiusIPDistributionContract_addStakingPool() public {
//         address stakingTokenC = address(new MockERC20("Staking Token C", "STC"));
//         uint256 allocPointsC = 100;
//         vm.expectEmit();
//         emit IAsclepiusIPDistributionContract.StakingPoolAdded(stakingTokenC, allocPointsC);
//         vm.prank(u.admin);
//         asclepiusIPDistributionContract.addStakingPool(stakingTokenC, allocPointsC);

//         assertEq(asclepiusIPDistributionContract.getPoolAllocPoints(stakingTokenC), allocPointsC);
//         assertEq(asclepiusIPDistributionContract.getTotalAllocPoints(), allocPointsA + allocPointsB + allocPointsC);

//         address stakingTokenD = address(new MockERC20("Staking Token D", "STD"));
//         uint256 allocPointsD = 1000;
//         vm.expectEmit();
//         emit IAsclepiusIPDistributionContract.StakingPoolAdded(stakingTokenD, allocPointsD);
//         vm.prank(u.admin);
//         asclepiusIPDistributionContract.addStakingPool(stakingTokenD, allocPointsD);
//         assertEq(asclepiusIPDistributionContract.getPoolAllocPoints(stakingTokenD), allocPointsD);
//         assertEq(
//             asclepiusIPDistributionContract.getTotalAllocPoints(),
//             allocPointsA + allocPointsB + allocPointsC + allocPointsD
//         );
//     }

//     function test_AsclepiusIPDistributionContract_setPoolAllocPoints() public {
//         uint256 newAllocPointsA = 200;
//         vm.prank(u.admin);
//         asclepiusIPDistributionContract.setPoolAllocPoints(address(stakingTokenA), newAllocPointsA);
//         assertEq(asclepiusIPDistributionContract.getPoolAllocPoints(address(stakingTokenA)), newAllocPointsA);
//         assertEq(asclepiusIPDistributionContract.getTotalAllocPoints(), allocPointsB + newAllocPointsA);

//         uint256 newAllocPointsB = 300;
//         vm.prank(u.admin);
//         asclepiusIPDistributionContract.setPoolAllocPoints(address(stakingTokenB), newAllocPointsB);
//         assertEq(asclepiusIPDistributionContract.getPoolAllocPoints(address(stakingTokenB)), newAllocPointsB);
//         assertEq(asclepiusIPDistributionContract.getTotalAllocPoints(), newAllocPointsA + newAllocPointsB);
//     }

//     function test_AsclepiusIPDistributionContract_setRewardDistributionPeriod() public {
//         _ipGeneratesRevenue(10_000_000);
//         asclepiusIPDistributionContract.collectRoyalties();
//         assertEq(asclepiusIPDistributionContract.getRewardDistributionPeriod(), testRewardDistributionPeriod);
//         assertEq(
//             asclepiusIPDistributionContract.getCurrentDistributionEndBlock(),
//             block.number + testRewardDistributionPeriod
//         );

//         uint256 newRewardDistributionPeriod = 1000;
//         vm.prank(u.admin);
//         asclepiusIPDistributionContract.setRewardDistributionPeriod(newRewardDistributionPeriod);
//         assertEq(asclepiusIPDistributionContract.getRewardDistributionPeriod(), newRewardDistributionPeriod);
//         assertEq(
//             asclepiusIPDistributionContract.getCurrentDistributionEndBlock(),
//             block.number + testRewardDistributionPeriod
//         ); // still in the same end block since the current period is not over yet

//         vm.roll(block.number + testRewardDistributionPeriod); // 1000 blocks later, enters a new distribution period which will have the new reward distribution period

//         _ipGeneratesRevenue(10_000_000);
//         asclepiusIPDistributionContract.collectRoyalties(); // triggers the reward distribution period update
//         assertEq(asclepiusIPDistributionContract.getRewardDistributionPeriod(), newRewardDistributionPeriod);
//         assertEq(
//             asclepiusIPDistributionContract.getCurrentDistributionEndBlock(),
//             block.number + newRewardDistributionPeriod
//         ); // now the new reward distribution period is in effect
//     }

//     function test_AsclepiusIPDistributionContract_setProtocolTaxRate() public {
//         assertEq(asclepiusIPDistributionContract.getProtocolTaxRate(), testProtocolTaxRate);

//         uint32 newProtocolTaxRate = 10_000_000; // 10%
//         vm.prank(u.admin);
//         asclepiusIPDistributionContract.setProtocolTaxRate(newProtocolTaxRate);
//         assertEq(asclepiusIPDistributionContract.getProtocolTaxRate(), newProtocolTaxRate);
//     }

//     function test_AsclepiusIPDistributionContract_claimAllRewards() public {
//         console2.log("block.number: ", block.number);
//         _aliceDeposits(stakingTokenA, 100);
//         _ipGeneratesRevenue(10_000_000); // 10 million revenue
//         asclepiusIPDistributionContract.collectRoyalties();

//         vm.roll(block.number + 100); // 100 blocks

//         _aliceClaimsRewards();
//         uint256 preTaxReward = (_getPoolRewardShare(10_000_000 * 10 ** rewardToken.decimals(), allocPointsA) /
//             testRewardDistributionPeriod) * 100;

//         uint256 expectedReward = _getAfterTaxReward(preTaxReward);
//         assertEq(rewardToken.balanceOf(u.alice), expectedReward);
//         assertEq(
//             rewardToken.balanceOf(address(asclepiusIPDistributionContract)),
//             10_000_000 * 10 ** rewardToken.decimals() - preTaxReward
//         );
//     }

//     /*//////////////////////////////////////////////////////////////////////////
//                                  INTEGRATION TESTS
//     //////////////////////////////////////////////////////////////////////////*/
//     function test_AsclepiusIPDistributionContract_claimAllRewards_StakersJoinAndLeaveMidDistributionPeriod() public {
//         uint256 aliceTotalRewards;
//         uint256 bobTotalRewards;
//         uint256 carlTotalRewards;

//         _aliceDeposits(stakingTokenA, 8000);
//         _aliceDeposits(stakingTokenB, 2000);
//         _bobDeposits(stakingTokenA, 2000);
//         _bobDeposits(stakingTokenB, 8000);
//         // block 1 - 1001 no revenue/rewards

//         vm.roll(block.number + 1000);
//         _ipGeneratesRevenue(10_000_000);
//         asclepiusIPDistributionContract.collectRoyalties();
//         // 10 million revenue / 1 million block distribution period = 10 reward per block

//         // block 1001 - 2001
//         // Total reward = 10 * 1000 = 10,000
//         // Alice's pre-tax reward = (10000 * 80/(80 + 20))/(8000 + 2000) * 8000 + (10000 * 20/(80 + 20))/(8000 + 2000) * 2000 = 6800
//         // Bob's pre-tax reward = (10000 * 80/(80 + 20))/(8000 + 2000) * 2000 + (10000 * 20/(80 + 20))/(8000 + 2000) * 8000 = 3200

//         // Alice's after-tax reward = 6800 * (1 - 2%) = 6664
//         // Bob's after-tax reward = 3200 * (1 - 2%) = 3136

//         vm.roll(block.number + 1000);
//         aliceTotalRewards += _getAfterTaxReward(
//             _calculateRewardForStaker({
//                 totalRewardToDistribute: 10_000_000,
//                 blocksToDistribute: testRewardDistributionPeriod,
//                 stakingPeriod: 1_000,
//                 stakingToken: stakingTokenA,
//                 poolAllocPoint: allocPointsA,
//                 totalAmtStaked: 8000,
//                 poolStakingBalance: 10_000
//             })
//         );
//         aliceTotalRewards += _getAfterTaxReward(
//             _calculateRewardForStaker({
//                 totalRewardToDistribute: 10_000_000,
//                 blocksToDistribute: testRewardDistributionPeriod,
//                 stakingPeriod: 1_000,
//                 stakingToken: stakingTokenB,
//                 poolAllocPoint: allocPointsB,
//                 totalAmtStaked: 2000,
//                 poolStakingBalance: 10_000
//             })
//         );

//         bobTotalRewards += _getAfterTaxReward(
//             _calculateRewardForStaker({
//                 totalRewardToDistribute: 10_000_000,
//                 blocksToDistribute: testRewardDistributionPeriod,
//                 stakingPeriod: 1_000,
//                 stakingToken: stakingTokenA,
//                 poolAllocPoint: allocPointsA,
//                 totalAmtStaked: 2000,
//                 poolStakingBalance: 10_000
//             })
//         );

//         bobTotalRewards += _getAfterTaxReward(
//             _calculateRewardForStaker({
//                 totalRewardToDistribute: 10_000_000,
//                 blocksToDistribute: testRewardDistributionPeriod,
//                 stakingPeriod: 1_000,
//                 stakingToken: stakingTokenB,
//                 poolAllocPoint: allocPointsB,
//                 totalAmtStaked: 8000,
//                 poolStakingBalance: 10_000
//             })
//         );

//         _aliceWithdraws(stakingTokenA, 6000);
//         _bobDeposits(stakingTokenA, 8000);
//         // block 2001 - 3001
//         // Total reward = 10 * 1000 = 10,000
//         // Alice's pre-tax reward = (10000 * 80/(80 + 20))/(2000 + 10000) * 2000 + (10000 * 20/(80 + 20))/(8000 + 2000) * 2000 = 1733.3333333333
//         // Bob's pre-tax reward = (10000 * 80/(80 + 20))/(2000 + 10000) * 10000 + (10000 * 20/(80 + 20))/(8000 + 2000) * 8000 = 8266.6666666667

//         // Alice's after-tax reward = 1733.3333333333 * (1 - 2%) = 1,698.6666666666
//         // Bob's after-tax reward = 8266.6666666667 * (1 - 2%) = 8,101.3333333334

//         vm.roll(block.number + 1000);
//         aliceTotalRewards += _getAfterTaxReward(
//             _calculateRewardForStaker({
//                 totalRewardToDistribute: 10_000_000,
//                 blocksToDistribute: testRewardDistributionPeriod,
//                 stakingPeriod: 1_000,
//                 stakingToken: stakingTokenA,
//                 poolAllocPoint: allocPointsA,
//                 totalAmtStaked: 2_000,
//                 poolStakingBalance: 12_000
//             })
//         );

//         aliceTotalRewards += _getAfterTaxReward(
//             _calculateRewardForStaker({
//                 totalRewardToDistribute: 10_000_000,
//                 blocksToDistribute: testRewardDistributionPeriod,
//                 stakingPeriod: 1_000,
//                 stakingToken: stakingTokenB,
//                 poolAllocPoint: allocPointsB,
//                 totalAmtStaked: 2_000,
//                 poolStakingBalance: 10_000
//             })
//         );

//         bobTotalRewards += _getAfterTaxReward(
//             _calculateRewardForStaker({
//                 totalRewardToDistribute: 10_000_000,
//                 blocksToDistribute: testRewardDistributionPeriod,
//                 stakingPeriod: 1_000,
//                 stakingToken: stakingTokenA,
//                 poolAllocPoint: allocPointsA,
//                 totalAmtStaked: 10_000,
//                 poolStakingBalance: 12_000
//             })
//         );

//         bobTotalRewards += _getAfterTaxReward(
//             _calculateRewardForStaker({
//                 totalRewardToDistribute: 10_000_000,
//                 blocksToDistribute: testRewardDistributionPeriod,
//                 stakingPeriod: 1_000,
//                 stakingToken: stakingTokenB,
//                 poolAllocPoint: allocPointsB,
//                 totalAmtStaked: 8_000,
//                 poolStakingBalance: 10_000
//             })
//         );

//         _aliceWithdraws(stakingTokenA, 2000);
//         _aliceWithdraws(stakingTokenB, 2000);
//         // block 3001 - 4001
//         // Total reward = 10,000
//         // Alice pre-tax reward = 0 (no staking balance)
//         // Bob pre-tax reward = 10,000

//         // Alice's after-tax reward = 0
//         // Bob's after-tax reward = 10,000 * (1 - 2%) = 9,800

//         vm.roll(block.number + 1000);
//         bobTotalRewards += _getAfterTaxReward(
//             _calculateRewardForStaker({
//                 totalRewardToDistribute: 10_000_000,
//                 blocksToDistribute: testRewardDistributionPeriod,
//                 stakingPeriod: 1_000,
//                 stakingToken: stakingTokenA,
//                 poolAllocPoint: allocPointsA,
//                 totalAmtStaked: 10_000,
//                 poolStakingBalance: 10_000
//             })
//         );

//         bobTotalRewards += _getAfterTaxReward(
//             _calculateRewardForStaker({
//                 totalRewardToDistribute: 10_000_000,
//                 blocksToDistribute: testRewardDistributionPeriod,
//                 stakingPeriod: 1_000,
//                 stakingToken: stakingTokenB,
//                 poolAllocPoint: allocPointsB,
//                 totalAmtStaked: 8_000,
//                 poolStakingBalance: 8_000
//             })
//         );

//         _aliceDeposits(stakingTokenA, 80_000);
//         _aliceDeposits(stakingTokenB, 20_000);
//         // block 4001 - 5001
//         // Total reward = 10,000
//         // Alice pre-tax reward = (10000 * 80/(80 + 20))/(80000 + 10000) * 80000 + (10000 * 20/(80 + 20))/(20000 + 8000) * 20000 = 8,539.6825396825
//         // Bob pre-tax reward = (10000 * 80/(80 + 20))/(80000 + 10000) * 10000 + (10000 * 20/(80 + 20))/(20000 + 8000) * 8000 = 1,460.3174603175

//         // Alice's after-tax reward = 8,539.6825396825 * (1 - 2%) = 8,368.8888888888
//         // Bob's after-tax reward = 1,460.3174603175 * (1 - 2%) = 1,431.1111111112

//         vm.roll(block.number + 1000);
//         aliceTotalRewards += _getAfterTaxReward(
//             _calculateRewardForStaker({
//                 totalRewardToDistribute: 10_000_000,
//                 blocksToDistribute: testRewardDistributionPeriod,
//                 stakingPeriod: 1_000,
//                 stakingToken: stakingTokenA,
//                 poolAllocPoint: allocPointsA,
//                 totalAmtStaked: 80_000,
//                 poolStakingBalance: 90_000
//             })
//         );

//         aliceTotalRewards += _getAfterTaxReward(
//             _calculateRewardForStaker({
//                 totalRewardToDistribute: 10_000_000,
//                 blocksToDistribute: testRewardDistributionPeriod,
//                 stakingPeriod: 1_000,
//                 stakingToken: stakingTokenB,
//                 poolAllocPoint: allocPointsB,
//                 totalAmtStaked: 20_000,
//                 poolStakingBalance: 28_000
//             })
//         );

//         bobTotalRewards += _getAfterTaxReward(
//             _calculateRewardForStaker({
//                 totalRewardToDistribute: 10_000_000,
//                 blocksToDistribute: testRewardDistributionPeriod,
//                 stakingPeriod: 1_000,
//                 stakingToken: stakingTokenA,
//                 poolAllocPoint: allocPointsA,
//                 totalAmtStaked: 10_000,
//                 poolStakingBalance: 90_000
//             })
//         );

//         bobTotalRewards += _getAfterTaxReward(
//             _calculateRewardForStaker({
//                 totalRewardToDistribute: 10_000_000,
//                 blocksToDistribute: testRewardDistributionPeriod,
//                 stakingPeriod: 1_000,
//                 stakingToken: stakingTokenB,
//                 poolAllocPoint: allocPointsB,
//                 totalAmtStaked: 8_000,
//                 poolStakingBalance: 28_000
//             })
//         );

//         _carlDeposits(stakingTokenA, 10_000);
//         _carlDeposits(stakingTokenB, 12_000);
//         // block 5001 - 6001
//         // Total reward = 10,000
//         // Alice pre-tax reward = (10000 * 80/(80 + 20))/(80000 + 10000 + 10000) * 80000 + (10000 * 20/(80 + 20))/(20000 + 8000 + 12000) * 20000 = 7,400
//         // Bob pre-tax reward = (10000 * 80/(80 + 20))/(80000 + 10000 + 10000) * 10000 + (10000 * 20/(80 + 20))/(20000 + 8000 + 12000) * 8000 = 1,200
//         // Carl pre-tax reward = (10000 * 80/(80 + 20))/(80000 + 10000 + 10000) * 10000 + (10000 * 20/(80 + 20))/(20000 + 8000 + 12000) * 12000 = 1,400

//         // Alice's after-tax reward = 7400 * (1 - 2%) = 7252
//         // Bob's after-tax reward = 1200 * (1 - 2%) = 1176
//         // Carl's after-tax reward = 1400 * (1 - 2%) = 1372

//         vm.roll(block.number + 1000);
//         aliceTotalRewards += _getAfterTaxReward(
//             _calculateRewardForStaker({
//                 totalRewardToDistribute: 10_000_000,
//                 blocksToDistribute: testRewardDistributionPeriod,
//                 stakingPeriod: 1_000,
//                 stakingToken: stakingTokenA,
//                 poolAllocPoint: allocPointsA,
//                 totalAmtStaked: 80_000,
//                 poolStakingBalance: 100_000
//             })
//         );

//         aliceTotalRewards += _getAfterTaxReward(
//             _calculateRewardForStaker({
//                 totalRewardToDistribute: 10_000_000,
//                 blocksToDistribute: testRewardDistributionPeriod,
//                 stakingPeriod: 1_000,
//                 stakingToken: stakingTokenB,
//                 poolAllocPoint: allocPointsB,
//                 totalAmtStaked: 20_000,
//                 poolStakingBalance: 40_000
//             })
//         );

//         bobTotalRewards += _getAfterTaxReward(
//             _calculateRewardForStaker({
//                 totalRewardToDistribute: 10_000_000,
//                 blocksToDistribute: testRewardDistributionPeriod,
//                 stakingPeriod: 1_000,
//                 stakingToken: stakingTokenA,
//                 poolAllocPoint: allocPointsA,
//                 totalAmtStaked: 10_000,
//                 poolStakingBalance: 100_000
//             })
//         );

//         bobTotalRewards += _getAfterTaxReward(
//             _calculateRewardForStaker({
//                 totalRewardToDistribute: 10_000_000,
//                 blocksToDistribute: testRewardDistributionPeriod,
//                 stakingPeriod: 1_000,
//                 stakingToken: stakingTokenB,
//                 poolAllocPoint: allocPointsB,
//                 totalAmtStaked: 8_000,
//                 poolStakingBalance: 40_000
//             })
//         );

//         carlTotalRewards += _getAfterTaxReward(
//             _calculateRewardForStaker({
//                 totalRewardToDistribute: 10_000_000,
//                 blocksToDistribute: testRewardDistributionPeriod,
//                 stakingPeriod: 1_000,
//                 stakingToken: stakingTokenA,
//                 poolAllocPoint: allocPointsA,
//                 totalAmtStaked: 10_000,
//                 poolStakingBalance: 100_000
//             })
//         );

//         carlTotalRewards += _getAfterTaxReward(
//             _calculateRewardForStaker({
//                 totalRewardToDistribute: 10_000_000,
//                 blocksToDistribute: testRewardDistributionPeriod,
//                 stakingPeriod: 1_000,
//                 stakingToken: stakingTokenB,
//                 poolAllocPoint: allocPointsB,
//                 totalAmtStaked: 12_000,
//                 poolStakingBalance: 40_000
//             })
//         );

//         _ipGeneratesRevenue(10_000_000);
//         asclepiusIPDistributionContract.collectRoyalties();
//         // block 6001 - 16001
//         // Total revenue left = 10 million old revenue + 10 million new revenue - 50,000 reward distributed = 19,950,000
//         // Blocks left in current distribution period = 1 million total blocks - 5000 blocks already elapsed = 995,000
//         // Reward per block =  19,950,000 / 995,000 = 20.05025125628

//         // Total reward = 20.05025125628 * 10,000 = 200,502.5125628
//         // Alice pre-tax reward = (200,502.5125628 * 80/(80 + 20))/(80000 + 10000 + 10000) * 80000 + (200,502.5125628 * 20/(80 + 20))/(20000 + 8000 + 12000) * 20000 = 148,371.859296472
//         // Bob pre-tax reward = (200,502.5125628 * 80/(80 + 20))/(80000 + 10000 + 10000) * 10000 + (200,502.5125628 * 20/(80 + 20))/(20000 + 8000 + 12000) * 8000 = 24,060.301507536
//         // Carl pre-tax reward = (200,502.5125628 * 80/(80 + 20))/(80000 + 10000 + 10000) * 10000 + (200,502.5125628 * 20/(80 + 20))/(20000 + 8000 + 12000) * 12000 = 28,070.351758792

//         // Alice's after-tax reward = 148,371.859296472 * (1 - 2%) = 145,404.4221105426
//         // Bob's after-tax reward = 24,060.301507536 * (1 - 2%) = 23,579.09547738528
//         // Carl's after-tax reward = 28,070.351758792 * (1 - 2%) = 27,508.9447236162

//         vm.roll(block.number + 10_000);
//         aliceTotalRewards += _getAfterTaxReward(
//             _calculateRewardForStaker({
//                 totalRewardToDistribute: (10_000_000 + 10_000_000 - 50_000),
//                 blocksToDistribute: testRewardDistributionPeriod - 5_000,
//                 stakingPeriod: 10_000,
//                 stakingToken: stakingTokenA,
//                 poolAllocPoint: allocPointsA,
//                 totalAmtStaked: 80_000,
//                 poolStakingBalance: 100_000
//             })
//         );

//         aliceTotalRewards += _getAfterTaxReward(
//             _calculateRewardForStaker({
//                 totalRewardToDistribute: (10_000_000 + 10_000_000 - 50_000),
//                 blocksToDistribute: testRewardDistributionPeriod - 5_000,
//                 stakingPeriod: 10_000,
//                 stakingToken: stakingTokenB,
//                 poolAllocPoint: allocPointsB,
//                 totalAmtStaked: 20_000,
//                 poolStakingBalance: 40_000
//             })
//         );

//         bobTotalRewards += _getAfterTaxReward(
//             _calculateRewardForStaker({
//                 totalRewardToDistribute: (10_000_000 + 10_000_000 - 50_000),
//                 blocksToDistribute: testRewardDistributionPeriod - 5_000,
//                 stakingPeriod: 10_000,
//                 stakingToken: stakingTokenA,
//                 poolAllocPoint: allocPointsA,
//                 totalAmtStaked: 10_000,
//                 poolStakingBalance: 100_000
//             })
//         );

//         bobTotalRewards += _getAfterTaxReward(
//             _calculateRewardForStaker({
//                 totalRewardToDistribute: (10_000_000 + 10_000_000 - 50_000),
//                 blocksToDistribute: testRewardDistributionPeriod - 5_000,
//                 stakingPeriod: 10_000,
//                 stakingToken: stakingTokenB,
//                 poolAllocPoint: allocPointsB,
//                 totalAmtStaked: 8_000,
//                 poolStakingBalance: 40_000
//             })
//         );

//         carlTotalRewards += _getAfterTaxReward(
//             _calculateRewardForStaker({
//                 totalRewardToDistribute: (10_000_000 + 10_000_000 - 50_000),
//                 blocksToDistribute: testRewardDistributionPeriod - 5_000,
//                 stakingPeriod: 10_000,
//                 stakingToken: stakingTokenA,
//                 poolAllocPoint: allocPointsA,
//                 totalAmtStaked: 10_000,
//                 poolStakingBalance: 100_000
//             })
//         );

//         carlTotalRewards += _getAfterTaxReward(
//             _calculateRewardForStaker({
//                 totalRewardToDistribute: (10_000_000 + 10_000_000 - 50_000),
//                 blocksToDistribute: testRewardDistributionPeriod - 5_000,
//                 stakingPeriod: 10_000,
//                 stakingToken: stakingTokenB,
//                 poolAllocPoint: allocPointsB,
//                 totalAmtStaked: 12_000,
//                 poolStakingBalance: 40_000
//             })
//         );

//         _aliceClaimsRewards();
//         _bobClaimsRewards();
//         _carlClaimsRewards();

//         _assertStakingBalances({
//             stakingToken: stakingTokenA,
//             aliceTokenBalance: 6_000 + 2_000,
//             bobTokenBalance: 0,
//             carlTokenBalance: 0,
//             danTokenBalance: 0,
//             aliceStakingBalance: 8_000 - 6_000 - 2_000 + 80_000,
//             bobStakingBalance: 2_000 + 8_000,
//             carlStakingBalance: 10_000,
//             danStakingBalance: 0
//         });

//         _assertStakingBalances({
//             stakingToken: stakingTokenB,
//             aliceTokenBalance: 2_000,
//             bobTokenBalance: 0,
//             carlTokenBalance: 0,
//             danTokenBalance: 0,
//             aliceStakingBalance: 2_000 - 2_000 + 20_000,
//             bobStakingBalance: 8_000,
//             carlStakingBalance: 12_000,
//             danStakingBalance: 0
//         });

//         _assertRewardBalances({
//             totalRevenue: 10_000_000 + 10_000_000,
//             aliceReward: aliceTotalRewards,
//             bobReward: bobTotalRewards,
//             carlReward: carlTotalRewards,
//             danReward: 0
//         });

//         console2.log("aliceTotalRewards", aliceTotalRewards);
//         console2.log("bobTotalRewards", bobTotalRewards);
//         console2.log("carlTotalRewards", carlTotalRewards);
//     }

//     //TODO: more tests

//     function test_AsclepiusIPDistributionContract_claimAllRewards_claimAcrossDistributionPeriods() public {}

//     function test_AsclepiusIPDistributionContract_claimAllRewards_complexScenario() public {}

//     /*//////////////////////////////////////////////////////////////////////////
//                                 HELPER FUNCTIONS
//     //////////////////////////////////////////////////////////////////////////*/

//     function _ipGeneratesRevenue(uint256 amount) internal {
//         rewardToken.mint(address(this), amount * 10 ** rewardToken.decimals());
//         rewardToken.approve(address(royaltyModule), amount * 10 ** rewardToken.decimals());
//         royaltyModule.payRoyaltyOnBehalf({
//             receiverIpId: testIpId,
//             payerIpId: address(0),
//             token: address(rewardToken),
//             amount: amount * 10 ** rewardToken.decimals()
//         });
//     }

//     function _getPoolRewardShare(uint256 totalReward, uint256 poolAllocPoints) internal view returns (uint256) {
//         return (totalReward * poolAllocPoints) / (allocPointsA + allocPointsB);
//     }

//     function _getAfterTaxReward(uint256 preTaxReward) internal view returns (uint256) {
//         return
//             (preTaxReward * (asclepiusIPDistributionContract.MAX_PERCENTAGE() - testProtocolTaxRate)) /
//             asclepiusIPDistributionContract.MAX_PERCENTAGE();
//     }

//     function _calculateRewardForStaker(
//         uint256 totalRewardToDistribute,
//         uint256 blocksToDistribute,
//         uint256 stakingPeriod,
//         MockERC20 stakingToken,
//         uint256 poolAllocPoint,
//         uint256 totalAmtStaked,
//         uint256 poolStakingBalance
//     ) internal view returns (uint256 preTaxReward) {
//         uint256 rewardPerBlock = (totalRewardToDistribute * 10 ** stakingToken.decimals()) / blocksToDistribute;
//         uint256 totalRewardDistributed = rewardPerBlock * stakingPeriod;
//         uint256 poolShare = (totalRewardDistributed * poolAllocPoint) / (allocPointsA + allocPointsB);
//         preTaxReward =
//             (poolShare * (totalAmtStaked * 10 ** stakingToken.decimals())) /
//             (poolStakingBalance * 10 ** stakingToken.decimals());
//     }

//     function _aliceDeposits(MockERC20 stakingToken, uint256 amount) internal {
//         vm.startPrank(u.alice);
//         stakingToken.mint(u.alice, amount * 10 ** stakingToken.decimals());
//         stakingToken.approve(address(asclepiusIPDistributionContract), amount * 10 ** stakingToken.decimals());
//         vm.expectEmit();
//         emit IAsclepiusIPDistributionContract.Deposited(
//             u.alice,
//             address(stakingToken),
//             amount * 10 ** stakingToken.decimals()
//         );
//         asclepiusIPDistributionContract.deposit(address(stakingToken), amount * 10 ** stakingToken.decimals());
//         vm.stopPrank();
//     }

//     function _bobDeposits(MockERC20 stakingToken, uint256 amount) internal {
//         vm.startPrank(u.bob);
//         stakingToken.mint(u.bob, amount * 10 ** stakingToken.decimals());
//         stakingToken.approve(address(asclepiusIPDistributionContract), amount * 10 ** stakingToken.decimals());
//         vm.expectEmit();
//         emit IAsclepiusIPDistributionContract.Deposited(
//             u.bob,
//             address(stakingToken),
//             amount * 10 ** stakingToken.decimals()
//         );
//         asclepiusIPDistributionContract.deposit(address(stakingToken), amount * 10 ** stakingToken.decimals());
//         vm.stopPrank();
//     }

//     function _carlDeposits(MockERC20 stakingToken, uint256 amount) internal {
//         vm.startPrank(u.carl);
//         stakingToken.mint(u.carl, amount * 10 ** stakingToken.decimals());
//         stakingToken.approve(address(asclepiusIPDistributionContract), amount * 10 ** stakingToken.decimals());
//         vm.expectEmit();
//         emit IAsclepiusIPDistributionContract.Deposited(
//             u.carl,
//             address(stakingToken),
//             amount * 10 ** stakingToken.decimals()
//         );
//         asclepiusIPDistributionContract.deposit(address(stakingToken), amount * 10 ** stakingToken.decimals());
//         vm.stopPrank();
//     }

//     function _danDeposits(MockERC20 stakingToken, uint256 amount) internal {
//         vm.startPrank(u.dan);
//         stakingToken.mint(u.dan, amount * 10 ** stakingToken.decimals());
//         stakingToken.approve(address(asclepiusIPDistributionContract), amount * 10 ** stakingToken.decimals());
//         vm.expectEmit();
//         emit IAsclepiusIPDistributionContract.Deposited(
//             u.dan,
//             address(stakingToken),
//             amount * 10 ** stakingToken.decimals()
//         );
//         asclepiusIPDistributionContract.deposit(address(stakingToken), amount * 10 ** stakingToken.decimals());
//         vm.stopPrank();
//     }

//     function _aliceWithdraws(MockERC20 stakingToken, uint256 amount) internal {
//         vm.startPrank(u.alice);
//         vm.expectEmit();
//         emit IAsclepiusIPDistributionContract.Withdrawn(
//             u.alice,
//             address(stakingToken),
//             amount * 10 ** stakingToken.decimals()
//         );
//         asclepiusIPDistributionContract.withdraw(address(stakingToken), amount * 10 ** stakingToken.decimals());
//         vm.stopPrank();
//     }

//     function _bobWithdraws(MockERC20 stakingToken, uint256 amount) internal {
//         vm.startPrank(u.bob);
//         vm.expectEmit();
//         emit IAsclepiusIPDistributionContract.Withdrawn(
//             u.bob,
//             address(stakingToken),
//             amount * 10 ** stakingToken.decimals()
//         );
//         asclepiusIPDistributionContract.withdraw(address(stakingToken), amount * 10 ** stakingToken.decimals());
//         vm.stopPrank();
//     }

//     function _carlWithdraws(MockERC20 stakingToken, uint256 amount) internal {
//         vm.startPrank(u.carl);
//         vm.expectEmit();
//         emit IAsclepiusIPDistributionContract.Withdrawn(
//             u.carl,
//             address(stakingToken),
//             amount * 10 ** stakingToken.decimals()
//         );
//         asclepiusIPDistributionContract.withdraw(address(stakingToken), amount * 10 ** stakingToken.decimals());
//         vm.stopPrank();
//     }

//     function _danWithdraws(MockERC20 stakingToken, uint256 amount) internal {
//         vm.startPrank(u.dan);
//         vm.expectEmit();
//         emit IAsclepiusIPDistributionContract.Withdrawn(
//             u.dan,
//             address(stakingToken),
//             amount * 10 ** stakingToken.decimals()
//         );
//         asclepiusIPDistributionContract.withdraw(address(stakingToken), amount * 10 ** stakingToken.decimals());
//         vm.stopPrank();
//     }

//     function _aliceClaimsRewards() internal {
//         vm.startPrank(u.alice);
//         vm.expectEmit(true, true, true, false);
//         emit IAsclepiusIPDistributionContract.RewardsClaimed(u.alice, 0, 0);
//         asclepiusIPDistributionContract.claimAllRewards(u.alice);
//         vm.stopPrank();
//     }

//     function _bobClaimsRewards() internal {
//         vm.startPrank(u.bob);
//         vm.expectEmit(true, true, true, false);
//         emit IAsclepiusIPDistributionContract.RewardsClaimed(u.bob, 0, 0);
//         asclepiusIPDistributionContract.claimAllRewards(u.bob);
//         vm.stopPrank();
//     }

//     function _carlClaimsRewards() internal {
//         vm.startPrank(u.carl);
//         vm.expectEmit(true, true, true, false);
//         emit IAsclepiusIPDistributionContract.RewardsClaimed(u.carl, 0, 0);
//         asclepiusIPDistributionContract.claimAllRewards(u.carl);
//         vm.stopPrank();
//     }

//     function _danClaimsRewards() internal {
//         vm.startPrank(u.dan);
//         vm.expectEmit(true, true, true, false);
//         emit IAsclepiusIPDistributionContract.RewardsClaimed(u.dan, 0, 0);
//         asclepiusIPDistributionContract.claimAllRewards(u.dan);
//         vm.stopPrank();
//     }

//     function _assertStakingBalances(
//         MockERC20 stakingToken,
//         uint256 aliceTokenBalance,
//         uint256 bobTokenBalance,
//         uint256 carlTokenBalance,
//         uint256 danTokenBalance,
//         uint256 aliceStakingBalance,
//         uint256 bobStakingBalance,
//         uint256 carlStakingBalance,
//         uint256 danStakingBalance
//     ) internal view {
//         assertEq(stakingToken.balanceOf(u.alice), aliceTokenBalance * 10 ** stakingToken.decimals());
//         assertEq(stakingToken.balanceOf(u.bob), bobTokenBalance * 10 ** stakingToken.decimals());
//         assertEq(stakingToken.balanceOf(u.carl), carlTokenBalance * 10 ** stakingToken.decimals());
//         assertEq(stakingToken.balanceOf(u.dan), danTokenBalance * 10 ** stakingToken.decimals());
//         assertEq(
//             asclepiusIPDistributionContract.getUserStakedBalance(address(stakingToken), u.alice),
//             aliceStakingBalance * 10 ** stakingToken.decimals()
//         );
//         assertEq(
//             asclepiusIPDistributionContract.getUserStakedBalance(address(stakingToken), u.bob),
//             bobStakingBalance * 10 ** stakingToken.decimals()
//         );
//         assertEq(
//             asclepiusIPDistributionContract.getUserStakedBalance(address(stakingToken), u.carl),
//             carlStakingBalance * 10 ** stakingToken.decimals()
//         );
//         assertEq(
//             asclepiusIPDistributionContract.getUserStakedBalance(address(stakingToken), u.dan),
//             danStakingBalance * 10 ** stakingToken.decimals()
//         );
//         uint256 totalStakedBalance = aliceStakingBalance + bobStakingBalance + carlStakingBalance + danStakingBalance;
//         assertEq(
//             stakingToken.balanceOf(address(asclepiusIPDistributionContract)),
//             totalStakedBalance * 10 ** stakingToken.decimals()
//         );
//         assertEq(
//             asclepiusIPDistributionContract.getPoolTotalStakedBalance(address(stakingToken)),
//             totalStakedBalance * 10 ** stakingToken.decimals()
//         );
//     }

//     function _assertRewardBalances(
//         uint256 totalRevenue,
//         uint256 aliceReward,
//         uint256 bobReward,
//         uint256 carlReward,
//         uint256 danReward
//     ) internal view {
//         totalRevenue = totalRevenue * 10 ** rewardToken.decimals();
//         assertEq(rewardToken.balanceOf(u.alice) / 10 ** 6, aliceReward / 10 ** 6);
//         assertEq(rewardToken.balanceOf(u.bob) / 10 ** 6, bobReward / 10 ** 6);
//         assertEq(rewardToken.balanceOf(u.carl) / 10 ** 6, carlReward / 10 ** 6);
//         assertEq(rewardToken.balanceOf(u.dan) / 10 ** 6, danReward / 10 ** 6);
//         assertEq(
//             (rewardToken.balanceOf(address(asclepiusIPDistributionContract)) +
//                 rewardToken.balanceOf(address(testProtocolTreasury))) / 10 ** 6,
//             (totalRevenue - aliceReward - bobReward - carlReward - danReward) / 10 ** 6
//         );
//     }
// }
