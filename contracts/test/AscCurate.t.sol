// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.26;

import { BeaconProxy } from "@openzeppelin/contracts/proxy/beacon/BeaconProxy.sol";
import { ERC721Holder } from "@openzeppelin/contracts/token/ERC721/utils/ERC721Holder.sol";
import { IERC721 } from "@openzeppelin/contracts/token/ERC721/IERC721.sol";

import { IAscStaking } from "../contracts/interfaces/IAscStaking.sol";
import { IAscCurate } from "../contracts/interfaces/IAscCurate.sol";
import { AscCurate } from "../contracts/AscCurate.sol";
import { IERC20 } from "@openzeppelin/contracts/interfaces/IERC20.sol";

import { BaseTest } from "./utils/BaseTest.t.sol";

contract AscCurateTest is BaseTest, ERC721Holder {
    AscCurate internal ascCurateInstance;

    function setUp() public override {
        super.setUp();
        _createAscCurateInstance();
    }

    function _createAscCurateInstance() internal {
        // Use the same NFT contract and token ID that was used to create testIpId in BaseTest
        // BaseTest uses spgNftPublic and the first minted token ID is 1
        address ipNft = address(spgNftPublic);
        
        IAscCurate.CurateInitData memory initData = _createCurateInitData(testIpId, ipNft, testIpNftTokenId);

        ascCurateInstance = AscCurate(
            address(
                new BeaconProxy(
                    address(ascCurateBeacon),
                    abi.encodeCall(IAscCurate.initialize, (initData))
                )
            )
        );
        vm.label(address(ascCurateInstance), "AscCurateInstance");
    }

    function test_AscCurate_initialize() public {
        assertEq(ascCurateInstance.getAdmin(), u.admin);
        assertEq(ascCurateInstance.getIpId(), testIpId);
        assertEq(ascCurateInstance.getExpirationTime(), testExpirationTime);
        assertEq(ascCurateInstance.getFundReceiver(), testFundReceiver);
        assertEq(ascCurateInstance.getBioName(), testBioName);
        assertEq(ascCurateInstance.getBioTokenName(), testBioTokenName);
        assertEq(ascCurateInstance.getBioTokenSymbol(), testBioTokenSymbol);
        assertEq(uint(ascCurateInstance.getState()), uint(IAscCurate.State.Open));
    }

    function test_AscCurate_deposit() public {
        uint256 depositAmount = 0.5 ether;
        
        vm.deal(u.alice, depositAmount);
        vm.startPrank(u.alice);
        vm.expectEmit();
        emit IAscCurate.DepositReceived(u.alice, depositAmount);
        ascCurateInstance.deposit{value: depositAmount}(depositAmount);
        vm.stopPrank();

        assertEq(ascCurateInstance.getDepositedAmount(u.alice), depositAmount);
        assertEq(ascCurateInstance.getTotalDeposited(), depositAmount);
        assertEq(address(ascCurateInstance).balance, depositAmount);
    }

    function test_AscCurate_withdraw() public {
        uint256 depositAmount = 2 ether; // Above minimum
        
        // Alice deposits
        vm.deal(u.alice, depositAmount);
        vm.startPrank(u.alice);
        ascCurateInstance.deposit{value: depositAmount}(depositAmount);
        vm.stopPrank();

        // Admin closes the curate
        vm.prank(u.admin);
        ascCurateInstance.close();

        // Admin withdraws
        uint256 initialBalance = testFundReceiver.balance;
        vm.prank(u.admin);
        vm.expectEmit();
        emit IAscCurate.TokensWithdrawn(testFundReceiver, depositAmount);
        uint256 withdrawnAmount = ascCurateInstance.withdraw();
        
        assertEq(withdrawnAmount, depositAmount);
        assertEq(testFundReceiver.balance, initialBalance + depositAmount);
        assertEq(address(ascCurateInstance).balance, 0);
    }

    function test_AscCurate_claimRefund() public {
        uint256 depositAmount = 0.5 ether;
        
        // Alice deposits
        vm.deal(u.alice, depositAmount);
        vm.startPrank(u.alice);
        ascCurateInstance.deposit{value: depositAmount}(depositAmount);
        vm.stopPrank();

        // Admin cancels
        vm.prank(u.admin);
        ascCurateInstance.cancel();

        // Alice claims refund
        uint256 initialBalance = u.alice.balance;
        vm.startPrank(u.alice);
        vm.expectEmit();
        emit IAscCurate.RefundClaimed(u.alice, depositAmount);
        uint256 refundAmount = ascCurateInstance.claimRefund();
        vm.stopPrank();

        assertEq(refundAmount, depositAmount);
        assertEq(u.alice.balance, initialBalance + depositAmount);
        assertEq(ascCurateInstance.getDepositedAmount(u.alice), 0);
    }

    function test_AscCurate_cancel() public {
        vm.prank(u.admin);
        vm.expectEmit();
        emit IAscCurate.CurateCanceled();
        ascCurateInstance.cancel();
        
        assertEq(uint(ascCurateInstance.getState()), uint(IAscCurate.State.Canceled));
    }

    function test_AscCurate_close() public {
        uint256 depositAmount = 2 ether; // Above minimum
        
        // Deposit enough to meet minimum
        vm.deal(u.alice, depositAmount);
        vm.startPrank(u.alice);
        ascCurateInstance.deposit{value: depositAmount}(depositAmount);
        vm.stopPrank();

        vm.prank(u.admin);
        vm.expectEmit();
        emit IAscCurate.CurateClosed();
        ascCurateInstance.close();
        
        assertEq(uint(ascCurateInstance.getState()), uint(IAscCurate.State.Closed));
    }

    function test_AscCurate_transferAdminRole() public {
        vm.prank(u.admin);
        vm.expectEmit();
        emit IAscCurate.AdminRoleTransferred(u.admin, u.bob);
        ascCurateInstance.transferAdminRole(u.bob);
        
        assertEq(ascCurateInstance.getAdmin(), u.bob);
    }

    function test_AscCurate_launchProject() public {
        uint256 depositAmount = 2 ether; // Above minimum
        
        // Alice deposits
        vm.deal(u.alice, depositAmount);
        vm.startPrank(u.alice);
        ascCurateInstance.deposit{value: depositAmount}(depositAmount);
        vm.stopPrank();

        // Admin closes the curate
        vm.startPrank(u.admin);
        ascCurateInstance.close();

        // Transfer NFT to the AscCurate contract before launching project
        IERC721(address(spgNftPublic)).approve(address(ascCurateInstance), testIpNftTokenId);
        IERC721(address(spgNftPublic)).transferFrom(u.admin, address(ascCurateInstance), testIpNftTokenId);
        vm.stopPrank();
        // Admin launches project
        IAscStaking.InitData memory stakingInitData = _createStakingInitData(testIpId);
        
        address ipRoyaltyVault = royaltyModule.ipRoyaltyVaults(testIpId);
        // Verify the IP has the full royalty vault tokens suppy
        assertEq(IERC20(ipRoyaltyVault).balanceOf(testIpId), IERC20(ipRoyaltyVault).totalSupply());

        vm.prank(u.admin);
        (address bioToken, address stakingContract) = ascCurateInstance.launchProject(
            address(bioTokenTemplate),
            address(ascStakingTemplate),
            stakingInitData
        );

        assertTrue(bioToken != address(0), "Bio token should be deployed");
        assertTrue(stakingContract != address(0), "Staking contract should be deployed");
        assertEq(ascCurateInstance.getBioToken(), bioToken);
        assertEq(ascCurateInstance.getStakingContract(), stakingContract);
        
        assertEq(IERC20(ipRoyaltyVault).balanceOf(stakingContract), IERC20(ipRoyaltyVault).totalSupply());
    }

    function test_AscCurate_claimBioTokens() public {
        uint256 aliceDeposit = 1 ether;
        uint256 bobDeposit = 2 ether;
        uint256 totalDeposits = aliceDeposit + bobDeposit;
        
        // Users deposit
        vm.deal(u.alice, aliceDeposit);
        vm.startPrank(u.alice);
        ascCurateInstance.deposit{value: aliceDeposit}(aliceDeposit);
        vm.stopPrank();

        vm.deal(u.bob, bobDeposit);
        vm.startPrank(u.bob);
        ascCurateInstance.deposit{value: bobDeposit}(bobDeposit);
        vm.stopPrank();

        // Admin closes and launches project
        vm.startPrank(u.admin);
        ascCurateInstance.close();

        // Transfer NFT to the AscCurate contract before launching project
        // The testIpId was created from spgNftPublic token ID 1 in BaseTest
        IERC721(address(spgNftPublic)).approve(address(ascCurateInstance), testIpNftTokenId);
        IERC721(address(spgNftPublic)).transferFrom(u.admin, address(ascCurateInstance), testIpNftTokenId);
        vm.stopPrank();

        IAscStaking.InitData memory stakingInitData = _createStakingInitData(testIpId);
        
        vm.prank(u.admin);
        (address bioToken, ) = ascCurateInstance.launchProject(
            address(bioTokenTemplate),
            address(ascStakingTemplate),
            stakingInitData
        );

        // Alice claims bio tokens
        vm.startPrank(u.alice);
        uint256 expectedAliceTokens = (aliceDeposit * testTotalBioTokenSupply) / totalDeposits;
        vm.expectEmit();
        emit IAscCurate.BioTokenClaimed(u.alice, expectedAliceTokens);
        (address claimedBioTokenAlice, uint256 aliceTokens) = ascCurateInstance.claimBioTokens(u.alice);
        vm.stopPrank();

        assertEq(claimedBioTokenAlice, bioToken);
        assertEq(aliceTokens, expectedAliceTokens);

        // Bob claims bio tokens
        vm.startPrank(u.bob);
        uint256 expectedBobTokens = (bobDeposit * testTotalBioTokenSupply) / totalDeposits;
        vm.expectEmit();
        emit IAscCurate.BioTokenClaimed(u.bob, expectedBobTokens);
        (address claimedBioTokenBob, uint256 bobTokens) = ascCurateInstance.claimBioTokens(u.bob);
        vm.stopPrank();

        assertEq(claimedBioTokenBob, bioToken);
        assertEq(bobTokens, expectedBobTokens);
    }
}
