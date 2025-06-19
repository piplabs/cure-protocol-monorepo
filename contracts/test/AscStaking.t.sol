// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.26;

import { console2 } from "forge-std/console2.sol";
import { IERC20 } from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import { MockERC20 } from "@storyprotocol/periphery/test/mocks/MockERC20.sol";
import { BeaconProxy } from "@openzeppelin/contracts/proxy/beacon/BeaconProxy.sol";

import { IAscStaking } from "../contracts/interfaces/IAscStaking.sol";
import { AscStaking } from "../contracts/AscStaking.sol";
import { BaseTest } from "./utils/BaseTest.t.sol";

contract AscStakingTest is BaseTest {
    AscStaking internal ascStaking;
    MockERC20 internal stakingTokenA;
    MockERC20 internal stakingTokenB;
    MockERC20 internal bioToken;
    
    uint256 internal allocPointsA = 80;
    uint256 internal allocPointsB = 20;

    function setUp() public override {
        super.setUp();
        
        // Deploy mock staking tokens
        stakingTokenA = new MockERC20("Staking Token A", "STA");
        stakingTokenB = new MockERC20("Staking Token B", "STB");
        bioToken = new MockERC20("Bio Token", "BIO");
        
        // Deploy AscStaking instance using the beacon proxy pattern
        ascStaking = AscStaking(
            address(
                new BeaconProxy(
                    address(ascStakingBeacon),
                    abi.encodeWithSelector(
                        AscStaking.initialize.selector,
                        address(bioToken),
                        _createStakingInitData(testIpId)
                    )
                )
            )
        );
        vm.label(address(ascStaking), "AscStaking");
        // Add initial staking pools (bioToken is already added during initialization)
        vm.startPrank(u.admin);
        ascStaking.addStakingPool(address(stakingTokenA), allocPointsA);
        ascStaking.addStakingPool(address(stakingTokenB), allocPointsB);
        vm.stopPrank();
        
        // Transfer royalty vault tokens to staking contract so it can claim royalties
        address ipRoyaltyVault = royaltyModule.ipRoyaltyVaults(testIpId);
        vm.label(ipRoyaltyVault, "IpRoyaltyVault");
        uint256 balance = IERC20(ipRoyaltyVault).balanceOf(testIpId);
        vm.prank(testIpId);
        IERC20(ipRoyaltyVault).transfer(address(ascStaking), balance);
        
        // Mint tokens to test users
        stakingTokenA.mint(u.alice, 10000 * 10 ** stakingTokenA.decimals());
        stakingTokenA.mint(u.bob, 10000 * 10 ** stakingTokenA.decimals());
        stakingTokenA.mint(u.carl, 10000 * 10 ** stakingTokenA.decimals());
        
        stakingTokenB.mint(u.alice, 10000 * 10 ** stakingTokenB.decimals());
        stakingTokenB.mint(u.bob, 10000 * 10 ** stakingTokenB.decimals());
        stakingTokenB.mint(u.carl, 10000 * 10 ** stakingTokenB.decimals());
        
        bioToken.mint(u.alice, 10000 * 10 ** bioToken.decimals());
        bioToken.mint(u.bob, 10000 * 10 ** bioToken.decimals());
        bioToken.mint(u.carl, 10000 * 10 ** bioToken.decimals());
        
        vm.label(address(ascStaking), "AscStaking");
        vm.label(address(stakingTokenA), "StakingTokenA");
        vm.label(address(stakingTokenB), "StakingTokenB");
        vm.label(address(bioToken), "BioToken");
    }

    function test_AscStaking_initialize() public {
        // Check that the instance is initialized correctly
        assertEq(ascStaking.getAdmin(), u.admin);
        assertEq(ascStaking.getIpId(), testIpId);
        assertEq(ascStaking.getRewardDistributionPeriod(), testRewardDistributionPeriod);
        assertEq(ascStaking.getCurrentDistributionEndBlock(), 0);
        assertEq(ascStaking.getRewardToken(), address(rewardToken));
        assertEq(ascStaking.getTotalAllocPoints(), allocPointsA + allocPointsB + testBioTokenAllocPoints);
        assertEq(ascStaking.getPoolAllocPoints(address(stakingTokenA)), allocPointsA);
        assertEq(ascStaking.getPoolAllocPoints(address(stakingTokenB)), allocPointsB);
        assertEq(ascStaking.getPoolAllocPoints(address(bioToken)), testBioTokenAllocPoints);
        assertEq(ascStaking.getPoolTotalStakedBalance(address(stakingTokenA)), 0);
        assertEq(ascStaking.getPoolTotalStakedBalance(address(stakingTokenB)), 0);
        assertEq(ascStaking.getPoolTotalStakedBalance(address(bioToken)), 0);
    }

    function test_AscStaking_deposit() public {
        uint256 depositAmount = 100 * 10 ** stakingTokenA.decimals();
        
        vm.startPrank(u.alice);
        stakingTokenA.approve(address(ascStaking), depositAmount);
        
        vm.expectEmit();
        emit IAscStaking.Deposited(u.alice, address(stakingTokenA), depositAmount);
        ascStaking.deposit(address(stakingTokenA), depositAmount);
        vm.stopPrank();

        assertEq(ascStaking.getUserStakedBalance(address(stakingTokenA), u.alice), depositAmount);
        assertEq(ascStaking.getPoolTotalStakedBalance(address(stakingTokenA)), depositAmount);
        assertEq(stakingTokenA.balanceOf(address(ascStaking)), depositAmount);
        assertEq(stakingTokenA.balanceOf(u.alice), 10000 * 10 ** stakingTokenA.decimals() - depositAmount);
    }

    function test_AscStaking_deposit_multipleUsers() public {
        uint256 aliceAmount = 100 * 10 ** stakingTokenA.decimals();
        uint256 bobAmount = 200 * 10 ** stakingTokenA.decimals();
        
        // Alice deposits
        vm.startPrank(u.alice);
        stakingTokenA.approve(address(ascStaking), aliceAmount);
        ascStaking.deposit(address(stakingTokenA), aliceAmount);
        vm.stopPrank();
        
        // Bob deposits
        vm.startPrank(u.bob);
        stakingTokenA.approve(address(ascStaking), bobAmount);
        ascStaking.deposit(address(stakingTokenA), bobAmount);
        vm.stopPrank();

        assertEq(ascStaking.getUserStakedBalance(address(stakingTokenA), u.alice), aliceAmount);
        assertEq(ascStaking.getUserStakedBalance(address(stakingTokenA), u.bob), bobAmount);
        assertEq(ascStaking.getPoolTotalStakedBalance(address(stakingTokenA)), aliceAmount + bobAmount);
    }

    function test_AscStaking_withdraw() public {
        uint256 depositAmount = 100 * 10 ** stakingTokenA.decimals();
        uint256 withdrawAmount = 30 * 10 ** stakingTokenA.decimals();
        
        // First deposit
        vm.startPrank(u.alice);
        stakingTokenA.approve(address(ascStaking), depositAmount);
        ascStaking.deposit(address(stakingTokenA), depositAmount);
        
        // Then withdraw
        vm.expectEmit();
        emit IAscStaking.Withdrawn(u.alice, address(stakingTokenA), withdrawAmount);
        ascStaking.withdraw(address(stakingTokenA), withdrawAmount);
        vm.stopPrank();

        assertEq(ascStaking.getUserStakedBalance(address(stakingTokenA), u.alice), depositAmount - withdrawAmount);
        assertEq(ascStaking.getPoolTotalStakedBalance(address(stakingTokenA)), depositAmount - withdrawAmount);
        assertEq(stakingTokenA.balanceOf(address(ascStaking)), depositAmount - withdrawAmount);
        assertEq(stakingTokenA.balanceOf(u.alice), 10000 * 10 ** stakingTokenA.decimals() - depositAmount + withdrawAmount);
    }

    function test_AscStaking_addStakingPool() public {
        MockERC20 newToken = new MockERC20("New Token", "NEW");
        uint256 allocPoints = 50;
        
        vm.startPrank(u.admin);
        vm.expectEmit();
        emit IAscStaking.StakingPoolAdded(address(newToken), allocPoints);
        ascStaking.addStakingPool(address(newToken), allocPoints);
        vm.stopPrank();

        assertEq(ascStaking.getPoolAllocPoints(address(newToken)), allocPoints);
        assertEq(ascStaking.getTotalAllocPoints(), allocPointsA + allocPointsB + testBioTokenAllocPoints + allocPoints);
    }

    function test_AscStaking_setPoolAllocPoints() public {
        uint256 newAllocPoints = 150;
        
        vm.startPrank(u.admin);
        vm.expectEmit();
        emit IAscStaking.PoolAllocPointsUpdated(address(stakingTokenA), allocPointsA, newAllocPoints);
        ascStaking.setPoolAllocPoints(address(stakingTokenA), newAllocPoints);
        vm.stopPrank();

        assertEq(ascStaking.getPoolAllocPoints(address(stakingTokenA)), newAllocPoints);
        assertEq(ascStaking.getTotalAllocPoints(), newAllocPoints + allocPointsB + testBioTokenAllocPoints);
    }

    function test_AscStaking_setRewardDistributionPeriod() public {
        uint256 newPeriod = 500_000;
        
        vm.startPrank(u.admin);
        vm.expectEmit();
        emit IAscStaking.RewardDistributionPeriodUpdated(testRewardDistributionPeriod, newPeriod);
        ascStaking.setRewardDistributionPeriod(newPeriod);
        vm.stopPrank();

        assertEq(ascStaking.getRewardDistributionPeriod(), newPeriod);
    }

    function test_AscStaking_collectRoyalties() public {
        // Generate some revenue for the IP first
        uint256 amount = 10_000_000 * 10 ** rewardToken.decimals();
        rewardToken.mint(address(this), amount);
        rewardToken.approve(address(royaltyModule), amount);
        royaltyModule.payRoyaltyOnBehalf({
            receiverIpId: testIpId,
            payerIpId: address(0),
            token: address(rewardToken),
            amount: amount
        });

        vm.expectEmit();
        emit IAscStaking.RoyaltiesCollected(
            testIpId,
            amount,
            block.number + testRewardDistributionPeriod
        );
        ascStaking.collectRoyalties();

        assertEq(ascStaking.getCurrentDistributionEndBlock(), block.number + testRewardDistributionPeriod);
        
        // Check that rewards are distributed according to allocation points
        uint256 totalAllocPoints = ascStaking.getTotalAllocPoints();
        assertEq(
            ascStaking.getRewardPerBlock(address(stakingTokenA)),
            (amount * allocPointsA / totalAllocPoints) / testRewardDistributionPeriod
        );
        assertEq(
            ascStaking.getRewardPerBlock(address(stakingTokenB)),
            (amount * allocPointsB / totalAllocPoints) / testRewardDistributionPeriod
        );
    }

    function test_AscStaking_claimAllRewards() public {
        // Setup: Deposit tokens and generate revenue
        uint256 depositAmount = 100 * 10 ** stakingTokenA.decimals();
        
        vm.startPrank(u.alice);
        stakingTokenA.approve(address(ascStaking), depositAmount);
        ascStaking.deposit(address(stakingTokenA), depositAmount);
        vm.stopPrank();
        
        // Generate revenue
        uint256 amount = 10_000_000 * 10 ** rewardToken.decimals();
        rewardToken.mint(address(this), amount);
        rewardToken.approve(address(royaltyModule), amount);
        royaltyModule.payRoyaltyOnBehalf({
            receiverIpId: testIpId,
            payerIpId: address(0),
            token: address(rewardToken),
            amount: amount
        });
        
        ascStaking.collectRoyalties();
        
        // Fast forward 100 blocks
        vm.roll(block.number + 100);
   
        uint256 totalAllocPoints = allocPointsA + allocPointsB + testBioTokenAllocPoints; // 80 + 20 + 100 = 200
        uint256 balanceBeforeClaim = rewardToken.balanceOf(u.alice);
        
        vm.startPrank(u.alice);
        vm.expectEmit(true, false, false, false);
        emit IAscStaking.RewardsClaimed(u.alice, 0);
        ascStaking.claimAllRewards(u.alice);
        vm.stopPrank();
        
        assertGt(rewardToken.balanceOf(u.alice), balanceBeforeClaim);
        assertEq(ascStaking.getPendingRewardsForStaker(address(stakingTokenA), u.alice), 0);
    }

    function test_AscStaking_multipleDistributionPeriods() public {
        // Setup: Deposit tokens
        uint256 depositAmount = 100 * 10 ** stakingTokenA.decimals();
        
        vm.startPrank(u.alice);
        stakingTokenA.approve(address(ascStaking), depositAmount);
        ascStaking.deposit(address(stakingTokenA), depositAmount);
        vm.stopPrank();
        
        // First revenue generation
        uint256 amount1 = 5_000_000 * 10 ** rewardToken.decimals();
        rewardToken.mint(address(this), amount1);
        rewardToken.approve(address(royaltyModule), amount1);
        royaltyModule.payRoyaltyOnBehalf({
            receiverIpId: testIpId,
            payerIpId: address(0),
            token: address(rewardToken),
            amount: amount1
        });
        
        ascStaking.collectRoyalties();
        uint256 firstPeriodEnd = ascStaking.getCurrentDistributionEndBlock();
        
        // Fast forward past the distribution period
        vm.roll(firstPeriodEnd + 1);
        
        // Second revenue generation (new distribution period)
        uint256 amount2 = 8_000_000 * 10 ** rewardToken.decimals();
        rewardToken.mint(address(this), amount2);
        rewardToken.approve(address(royaltyModule), amount2);
        royaltyModule.payRoyaltyOnBehalf({
            receiverIpId: testIpId,
            payerIpId: address(0),
            token: address(rewardToken),
            amount: amount2
        });
        
        ascStaking.collectRoyalties();
        uint256 secondPeriodEnd = ascStaking.getCurrentDistributionEndBlock();
        
        assertGt(secondPeriodEnd, firstPeriodEnd);
        assertEq(secondPeriodEnd, block.number + testRewardDistributionPeriod);
    }

    function test_AscStaking_complexStakingScenario() public {
        // Complex scenario with multiple users, tokens, and distribution periods
        uint256 aliceAmountA = 1000 * 10 ** stakingTokenA.decimals();
        uint256 bobAmountA = 500 * 10 ** stakingTokenA.decimals();
        uint256 aliceAmountB = 200 * 10 ** stakingTokenB.decimals();
        uint256 bobAmountB = 800 * 10 ** stakingTokenB.decimals();
        
        // Initial deposits
        vm.startPrank(u.alice);
        stakingTokenA.approve(address(ascStaking), aliceAmountA);
        stakingTokenB.approve(address(ascStaking), aliceAmountB);
        ascStaking.deposit(address(stakingTokenA), aliceAmountA);
        ascStaking.deposit(address(stakingTokenB), aliceAmountB);
        vm.stopPrank();
        
        vm.startPrank(u.bob);
        stakingTokenA.approve(address(ascStaking), bobAmountA);
        stakingTokenB.approve(address(ascStaking), bobAmountB);
        ascStaking.deposit(address(stakingTokenA), bobAmountA);
        ascStaking.deposit(address(stakingTokenB), bobAmountB);
        vm.stopPrank();
        
        // Generate revenue
        uint256 revenue = 1_000_000 * 10 ** rewardToken.decimals();
        rewardToken.mint(address(this), revenue);
        rewardToken.approve(address(royaltyModule), revenue);
        royaltyModule.payRoyaltyOnBehalf({
            receiverIpId: testIpId,
            payerIpId: address(0),
            token: address(rewardToken),
            amount: revenue
        });
        
        ascStaking.collectRoyalties();
        
        // Fast forward 50% of distribution period
        vm.roll(block.number + testRewardDistributionPeriod / 2);
        
        // Claim rewards
        vm.prank(u.alice);
        ascStaking.claimAllRewards(u.alice);
        
        vm.prank(u.bob);
        ascStaking.claimAllRewards(u.bob);
        
        // Check that rewards were distributed
        assertGt(rewardToken.balanceOf(u.alice), 0);
        assertGt(rewardToken.balanceOf(u.bob), 0);
    }

    function test_AscStaking_deposit_revert_zeroAmount() public {
        vm.startPrank(u.alice);
        stakingTokenA.approve(address(ascStaking), 100);
        vm.expectRevert(); // Should revert for zero amount
        ascStaking.deposit(address(stakingTokenA), 0);
        vm.stopPrank();
    }

    function test_AscStaking_withdraw_revert_insufficientBalance() public {
        uint256 depositAmount = 100 * 10 ** stakingTokenA.decimals();
        uint256 withdrawAmount = 200 * 10 ** stakingTokenA.decimals();
        
        vm.startPrank(u.alice);
        stakingTokenA.approve(address(ascStaking), depositAmount);
        ascStaking.deposit(address(stakingTokenA), depositAmount);
        
        vm.expectRevert(); // Should revert for insufficient balance
        ascStaking.withdraw(address(stakingTokenA), withdrawAmount);
        vm.stopPrank();
    }

    function test_AscStaking_addStakingPool_revert_notAdmin() public {
        MockERC20 newToken = new MockERC20("New Token", "NEW");
        
        vm.startPrank(u.alice); // Not admin
        vm.expectRevert(); // Should revert for non-admin
        ascStaking.addStakingPool(address(newToken), 50);
        vm.stopPrank();
    }

    function test_AscStaking_addStakingPool_revert_duplicateToken() public {
        vm.startPrank(u.admin);
        vm.expectRevert(); // Should revert for duplicate token
        ascStaking.addStakingPool(address(stakingTokenA), 50);
        vm.stopPrank();
    }

    function test_AscStaking_setPoolAllocPoints_revert_notAdmin() public {
        vm.startPrank(u.alice); // Not admin
        vm.expectRevert(); // Should revert for non-admin
        ascStaking.setPoolAllocPoints(address(stakingTokenA), 150);
        vm.stopPrank();
    }

    function test_AscStaking_setRewardDistributionPeriod_revert_notAdmin() public {
        vm.startPrank(u.alice); // Not admin
        vm.expectRevert(); // Should revert for non-admin
        ascStaking.setRewardDistributionPeriod(500_000);
        vm.stopPrank();
    }

    /*//////////////////////////////////////////////////////////////////////////
                                 HELPER FUNCTIONS
    //////////////////////////////////////////////////////////////////////////*/

    function _generateRevenue(uint256 amount) internal {
        rewardToken.mint(address(this), amount);
        rewardToken.approve(address(royaltyModule), amount);
        royaltyModule.payRoyaltyOnBehalf({
            receiverIpId: testIpId,
            payerIpId: address(0),
            token: address(rewardToken),
            amount: amount
        });
    }

    function _depositFor(address user, address token, uint256 amount) internal {
        vm.startPrank(user);
        MockERC20(token).approve(address(ascStaking), amount);
        ascStaking.deposit(token, amount);
        vm.stopPrank();
    }

    function _withdrawFor(address user, address token, uint256 amount) internal {
        vm.startPrank(user);
        ascStaking.withdraw(token, amount);
        vm.stopPrank();
    }

    function _claimRewardsFor(address user) internal {
        vm.startPrank(user);
        ascStaking.claimAllRewards(user);
        vm.stopPrank();
    }
}
