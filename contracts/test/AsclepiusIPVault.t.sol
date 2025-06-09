// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.26;

import { TestProxyHelper } from "@storyprotocol/test/utils/TestProxyHelper.sol";
import { ISPGNFT } from "@storyprotocol/periphery/contracts/interfaces/ISPGNFT.sol";
import { OwnableERC20 } from "@storyprotocol/periphery/contracts/modules/tokenizer/OwnableERC20.sol";
import { SPGNFTLib } from "@storyprotocol/periphery/contracts/lib/SPGNFTLib.sol";
import { WorkflowStructs } from "@storyprotocol/periphery/contracts/lib/WorkflowStructs.sol";

import { IAsclepiusIPDistributionContract } from "../contracts/interfaces/IAsclepiusIPDistributionContract.sol";
import { IAsclepiusIPVault } from "../contracts/interfaces/IAsclepiusIPVault.sol";
import { AsclepiusIPVault } from "../contracts/AsclepiusIPVault.sol";

import { BaseTest } from "./utils/BaseTest.t.sol";
import { Errors } from "../contracts/lib/Errors.sol";

contract AsclepiusIPVaultTest is BaseTest {
    WorkflowStructs.IPMetadata internal rwipMetadata;
    address internal rwipNft;

    function setUp() public override {
        super.setUp();
        rwipMetadata = WorkflowStructs.IPMetadata({
            ipMetadataURI: "TEST RWIP",
            ipMetadataHash: bytes32(0x1234567890abcdef01234567890abcdef01234567890abcdef01234567890abc),
            nftMetadataURI: "TEST NFT",
            nftMetadataHash: bytes32(0x1234567890abcdef01234567890abcdef01234567890abcdef01234567890abc)
        });

        rwipNft = registrationWorkflows.createCollection({
            spgNftInitParams: ISPGNFT.InitParams({
                name: "TEST RWIP",
                symbol: "TRWIP",
                baseURI: "TEST RWIP",
                contractURI: "TEST RWIP",
                maxSupply: 1000,
                mintFee: 0,
                mintFeeToken: address(0),
                mintFeeRecipient: address(0),
                owner: u.admin,
                mintOpen: true,
                isPublicMinting: false
            })
        });

        vm.prank(u.admin);
        ISPGNFT(rwipNft).grantRole(SPGNFTLib.MINTER_ROLE, address(asclepiusIPVaultInstance));
    }

    function test_AsclepiusIPVault_initialize() public {
        address testVaultImpl = address(
            new AsclepiusIPVault({
                royaltyTokenDistributionWorkflows: address(royaltyTokenDistributionWorkflows),
                royaltyModule: address(royaltyModule),
                tokenizerModule: address(tokenizerModule),
                upgradeableBeacon: address(0x222)
            })
        );

        AsclepiusIPVault testVault = AsclepiusIPVault(
            TestProxyHelper.deployUUPSProxy(
                testVaultImpl,
                abi.encodeCall(
                    IAsclepiusIPVault.initialize,
                    (
                        u.admin,
                        block.timestamp + 100_000,
                        address(0x999),
                        "TEST RWIP",
                        "TEST FRACTIONAL TOKEN",
                        "TFT",
                        testTotalSupplyOfFractionalToken,
                        address(0x123)
                    )
                )
            )
        );

        assertEq(testVault.getAdmin(), u.admin);
        assertEq(testVault.getExpirationTime(), block.timestamp + 100_000);
        assertEq(testVault.getFundReceiver(), address(0x999));
        assertEq(testVault.getRwipName(), "TEST RWIP");
        assertEq(testVault.getFractionalTokenName(), "TEST FRACTIONAL TOKEN");
        assertEq(testVault.getFractionalTokenSymbol(), "TFT");
        assertEq(testVault.getTotalSupplyOfFractionalToken(), testTotalSupplyOfFractionalToken);
        assertEq(testVault.getUsdcContractAddress(), address(0x123));
        assertEq(uint(testVault.getState()), uint(IAsclepiusIPVault.State.Open));
    }

    function test_AsclepiusIPVault_deposit() public {
        _aliceDeposits(100_000);
        _bobDeposits(200_000);
        _carlDeposits(300_000);

        assertEq(mockUsdc.balanceOf(address(asclepiusIPVaultInstance)), 600_000 * 10 ** mockUsdc.decimals());
        assertEq(asclepiusIPVaultInstance.getTotalDeposited(address(mockUsdc)), 600_000 * 10 ** mockUsdc.decimals());
        assertEq(
            asclepiusIPVaultInstance.getDepositedAmount(u.alice, address(mockUsdc)),
            100_000 * 10 ** mockUsdc.decimals()
        );
        assertEq(
            asclepiusIPVaultInstance.getDepositedAmount(u.bob, address(mockUsdc)),
            200_000 * 10 ** mockUsdc.decimals()
        );
        assertEq(
            asclepiusIPVaultInstance.getDepositedAmount(u.carl, address(mockUsdc)),
            300_000 * 10 ** mockUsdc.decimals()
        );
    }

    function test_AsclepiusIPVault_withdraw() public {
        _aliceDeposits(100_000);
        _bobDeposits(200_000);
        _carlDeposits(300_000);

        address[] memory expectedTokens = new address[](1);
        expectedTokens[0] = address(mockUsdc);
        uint256[] memory expectedWithdrawnAmounts = new uint256[](1);
        expectedWithdrawnAmounts[0] = 600_000 * 10 ** mockUsdc.decimals();

        vm.warp(block.timestamp + 30 days); // vault expires
        vm.prank(u.admin);
        vm.expectEmit();
        emit IAsclepiusIPVault.TokensWithdrawn(testFundReceiver, expectedTokens, expectedWithdrawnAmounts);
        (address[] memory tokens, uint256[] memory withdrawnAmounts) = asclepiusIPVaultInstance.withdraw();
        assertEq(tokens.length, 1);
        assertEq(tokens[0], expectedTokens[0]);
        assertEq(withdrawnAmounts[0], expectedWithdrawnAmounts[0]);
        assertEq(mockUsdc.balanceOf(testFundReceiver), 600_000 * 10 ** mockUsdc.decimals());
        assertEq(mockUsdc.balanceOf(address(asclepiusIPVaultInstance)), 0);
    }

    function test_AsclepiusIPVault_claimRefund() public {
        _aliceDeposits(100_000);
        _bobDeposits(200_000);
        _carlDeposits(300_000);

        vm.prank(u.admin);
        asclepiusIPVaultInstance.cancel();

        vm.startPrank(u.alice);
        vm.expectEmit();
        emit IAsclepiusIPVault.RefundClaimed(u.alice, address(mockUsdc), 100_000 * 10 ** mockUsdc.decimals());
        asclepiusIPVaultInstance.claimRefund(address(mockUsdc));
        vm.stopPrank();

        vm.startPrank(u.bob);
        vm.expectEmit();
        emit IAsclepiusIPVault.RefundClaimed(u.bob, address(mockUsdc), 200_000 * 10 ** mockUsdc.decimals());
        asclepiusIPVaultInstance.claimRefund(address(mockUsdc));
        vm.stopPrank();

        vm.startPrank(u.carl);
        vm.expectEmit();
        emit IAsclepiusIPVault.RefundClaimed(u.carl, address(mockUsdc), 300_000 * 10 ** mockUsdc.decimals());
        asclepiusIPVaultInstance.claimRefund(address(mockUsdc));
        vm.stopPrank();

        assertEq(mockUsdc.balanceOf(u.alice), 100_000 * 10 ** mockUsdc.decimals());
        assertEq(mockUsdc.balanceOf(u.bob), 200_000 * 10 ** mockUsdc.decimals());
        assertEq(mockUsdc.balanceOf(u.carl), 300_000 * 10 ** mockUsdc.decimals());
        assertEq(mockUsdc.balanceOf(address(asclepiusIPVaultInstance)), 0);
    }

    function test_AsclepiusIPVault_cancel() public {
        vm.prank(u.admin);
        vm.expectEmit();
        emit IAsclepiusIPVault.VaultCanceled();
        asclepiusIPVaultInstance.cancel();
        assertEq(uint(asclepiusIPVaultInstance.getState()), uint(IAsclepiusIPVault.State.Canceled));
    }

    function test_AsclepiusIPVault_close() public {
        vm.prank(u.admin);
        vm.expectEmit();
        emit IAsclepiusIPVault.VaultClosed();
        asclepiusIPVaultInstance.close();
        assertEq(uint(asclepiusIPVaultInstance.getState()), uint(IAsclepiusIPVault.State.Closed));
    }

    function test_AsclepiusIPVault_transferAdminRole() public {
        vm.prank(u.admin);
        vm.expectEmit();
        emit IAsclepiusIPVault.AdminRoleTransferred(u.admin, u.bob);
        asclepiusIPVaultInstance.transferAdminRole(u.bob);
        assertEq(asclepiusIPVaultInstance.getAdmin(), u.bob);

        vm.prank(u.bob);
        vm.expectEmit();
        emit IAsclepiusIPVault.AdminRoleTransferred(u.bob, u.alice);
        asclepiusIPVaultInstance.transferAdminRole(u.alice);
        assertEq(asclepiusIPVaultInstance.getAdmin(), u.alice);
    }

    function test_AsclepiusIPVault_registerIPAndFractionalize() public {
        _aliceDeposits(500_000);
        _bobDeposits(200_000);
        _carlDeposits(300_000);

        vm.warp(block.timestamp + 30 days); // vault expires
        vm.startPrank(u.admin);
        mockToken.mint(u.admin, 1 * 10 ** mockToken.decimals());
        mockToken.approve(address(spgNftPublic), 1 * 10 ** mockToken.decimals()); // nft minting fee
        vm.expectEmit(true, false, false, false);
        emit IAsclepiusIPVault.IPRegisteredAndFractionalized(
            ipAssetRegistry.ipId(block.chainid, rwipNft, 1),
            rwipNft,
            1,
            0,
            address(0),
            address(0)
        );

        (
            uint256 tokenId,
            address ipId,
            ,
            address fractionalToken,
            address distributionContract
        ) = asclepiusIPVaultInstance.registerIPAndFractionalize({
                spgNftContract: rwipNft,
                ipMetadata: rwipMetadata,
                licenseTermsData: licenseTerms[0],
                fractionalTokenTemplate: address(ownableERC20Template),
                distributionContractTemplate: address(asclepiusIPDistributionContractTemplate),
                initData: IAsclepiusIPDistributionContract.InitData({
                    admin: u.admin,
                    ipId: ipAssetRegistry.ipId(block.chainid, rwipNft, 1),
                    protocolTreasury: testProtocolTreasury,
                    protocolTaxRate: testProtocolTaxRate,
                    rewardDistributionPeriod: testRewardDistributionPeriod,
                    rewardToken: address(rewardToken),
                    fractionalTokenAllocPoints: allocPointsA
                })
            });
        vm.stopPrank();

        assertEq(tokenId, 1);
        assertTrue(ipAssetRegistry.isRegistered(ipId));
        assertMetadata(ipId, rwipMetadata);
        assertEq(OwnableERC20(fractionalToken).owner(), address(asclepiusIPVaultInstance));
        assertEq(OwnableERC20(fractionalToken).name(), "TEST FRACTIONAL TOKEN");
        assertEq(OwnableERC20(fractionalToken).symbol(), "TFT");
        assertEq(OwnableERC20(fractionalToken).cap(), testTotalSupplyOfFractionalToken);
        assertEq(IAsclepiusIPDistributionContract(distributionContract).getAdmin(), u.admin);
        assertEq(
            IAsclepiusIPDistributionContract(distributionContract).getIpId(),
            ipAssetRegistry.ipId(block.chainid, rwipNft, 1)
        );
        assertEq(IAsclepiusIPDistributionContract(distributionContract).getProtocolTreasury(), testProtocolTreasury);
        assertEq(IAsclepiusIPDistributionContract(distributionContract).getProtocolTaxRate(), testProtocolTaxRate);
        assertEq(
            IAsclepiusIPDistributionContract(distributionContract).getRewardDistributionPeriod(),
            testRewardDistributionPeriod
        );
        assertEq(IAsclepiusIPDistributionContract(distributionContract).getRewardToken(), address(rewardToken));
        assertEq(
            IAsclepiusIPDistributionContract(distributionContract).getPoolAllocPoints(address(fractionalToken)),
            allocPointsA
        );
        assertEq(IAsclepiusIPDistributionContract(distributionContract).getTotalAllocPoints(), allocPointsA);
    }

    function test_AsclepiusIPVault_claimIPTokens() public {
        uint256 totalAmountStaked = 500_000 + 200_000 + 300_000;
        uint256 aliceAmountDeposited = 500_000;
        uint256 bobAmountDeposited = 200_000;
        uint256 carlAmountDeposited = 300_000;

        _aliceDeposits(aliceAmountDeposited);
        _bobDeposits(bobAmountDeposited);
        _carlDeposits(carlAmountDeposited);

        vm.warp(block.timestamp + 30 days); // vault expires
        vm.startPrank(u.admin);
        mockToken.mint(u.admin, 1 * 10 ** mockToken.decimals());
        mockToken.approve(address(spgNftPublic), 1 * 10 ** mockUsdc.decimals()); // nft minting fee
        vm.expectEmit(true, false, false, false);
        emit IAsclepiusIPVault.IPRegisteredAndFractionalized(
            ipAssetRegistry.ipId(block.chainid, rwipNft, 1),
            rwipNft,
            1,
            0,
            address(0),
            address(0)
        );
        (uint256 tokenId, address ipId, , address fractionalToken, ) = asclepiusIPVaultInstance
            .registerIPAndFractionalize({
                spgNftContract: rwipNft,
                ipMetadata: rwipMetadata,
                licenseTermsData: licenseTerms[0],
                fractionalTokenTemplate: address(ownableERC20Template),
                distributionContractTemplate: address(asclepiusIPDistributionContractTemplate),
                initData: IAsclepiusIPDistributionContract.InitData({
                    admin: u.admin,
                    ipId: ipAssetRegistry.ipId(block.chainid, rwipNft, 1),
                    protocolTreasury: testProtocolTreasury,
                    protocolTaxRate: testProtocolTaxRate,
                    rewardDistributionPeriod: testRewardDistributionPeriod,
                    rewardToken: address(rewardToken),
                    fractionalTokenAllocPoints: allocPointsA
                })
            });
        vm.stopPrank();

        vm.startPrank(u.alice);
        uint256 aliceAmountClaimed = (aliceAmountDeposited * testTotalSupplyOfFractionalToken) / totalAmountStaked;
        vm.expectEmit();
        emit IAsclepiusIPVault.FractionalTokenClaimed(u.alice, aliceAmountClaimed);
        (address fractionalTokenAddr, uint256 amountClaimed) = asclepiusIPVaultInstance.claimFractionalTokens(u.alice);
        vm.stopPrank();
        assertEq(amountClaimed, aliceAmountClaimed);
        assertEq(OwnableERC20(fractionalTokenAddr).balanceOf(u.alice), aliceAmountClaimed);

        vm.startPrank(u.bob);
        uint256 bobAmountClaimed = (bobAmountDeposited * testTotalSupplyOfFractionalToken) / totalAmountStaked;
        vm.expectEmit();
        emit IAsclepiusIPVault.FractionalTokenClaimed(u.bob, bobAmountClaimed);
        (fractionalTokenAddr, amountClaimed) = asclepiusIPVaultInstance.claimFractionalTokens(u.bob);
        vm.stopPrank();
        assertEq(amountClaimed, bobAmountClaimed);
        assertEq(OwnableERC20(fractionalTokenAddr).balanceOf(u.bob), bobAmountClaimed);

        vm.startPrank(u.carl);
        uint256 carlAmountClaimed = (carlAmountDeposited * testTotalSupplyOfFractionalToken) / totalAmountStaked;
        vm.expectEmit();
        emit IAsclepiusIPVault.FractionalTokenClaimed(u.carl, carlAmountClaimed);
        (fractionalTokenAddr, amountClaimed) = asclepiusIPVaultInstance.claimFractionalTokens(u.carl);
        vm.stopPrank();
        assertEq(amountClaimed, carlAmountClaimed);
        assertEq(OwnableERC20(fractionalTokenAddr).balanceOf(u.carl), carlAmountClaimed);
    }

    function test_revert_AsclepiusIPVault_claimRefund_VaultNotCanceled() public {
        _aliceDeposits(100_000);

        vm.startPrank(u.alice);
        vm.expectRevert(
            abi.encodeWithSelector(Errors.AsclepiusIPVault__VaultNotCanceled.selector, IAsclepiusIPVault.State.Open)
        );
        asclepiusIPVaultInstance.claimRefund(address(mockUsdc));
        vm.stopPrank();

        vm.startPrank(u.admin);
        asclepiusIPVaultInstance.close();
        vm.stopPrank();

        vm.startPrank(u.alice);
        vm.expectRevert(
            abi.encodeWithSelector(Errors.AsclepiusIPVault__VaultNotCanceled.selector, IAsclepiusIPVault.State.Closed)
        );
        asclepiusIPVaultInstance.claimRefund(address(mockUsdc));
        vm.stopPrank();
    }

    function test_revert_AsclepiusIPVault_deposit_VaultNotOpen() public {
        vm.prank(u.admin);
        asclepiusIPVaultInstance.close();

        vm.startPrank(u.alice);
        mockUsdc.mint(u.alice, 100_000 * 10 ** mockUsdc.decimals());
        mockUsdc.approve(address(asclepiusIPVaultInstance), 100_000 * 10 ** mockUsdc.decimals());
        uint256 amount = 100_000 * 10 ** mockUsdc.decimals();
        vm.expectRevert(
            abi.encodeWithSelector(Errors.AsclepiusIPVault__VaultNotOpen.selector, IAsclepiusIPVault.State.Closed)
        );
        asclepiusIPVaultInstance.deposit(address(mockUsdc), amount);
        vm.stopPrank();
    }

    function test_revert_AsclepiusIPVault_cancel_VaultNotOpen() public {
        vm.prank(u.admin);
        asclepiusIPVaultInstance.close();

        vm.prank(u.admin);
        vm.expectRevert(
            abi.encodeWithSelector(Errors.AsclepiusIPVault__VaultNotOpen.selector, IAsclepiusIPVault.State.Closed)
        );
        asclepiusIPVaultInstance.cancel();
    }

    function test_revert_AsclepiusIPVault_close_VaultNotOpen() public {
        vm.prank(u.admin);
        asclepiusIPVaultInstance.cancel();

        vm.prank(u.admin);
        vm.expectRevert(
            abi.encodeWithSelector(Errors.AsclepiusIPVault__VaultNotOpen.selector, IAsclepiusIPVault.State.Canceled)
        );
        asclepiusIPVaultInstance.close();
    }

    function test_AsclepiusIPVault_deposit_afterExpirationShouldNotChangeCanceledState() public {
        vm.prank(u.admin);
        asclepiusIPVaultInstance.cancel();

        uint256 amount = 100_000 * 10 ** mockUsdc.decimals();
        vm.warp(block.timestamp + 30 days); // vault expires
        vm.startPrank(u.alice);
        vm.expectRevert(
            abi.encodeWithSelector(Errors.AsclepiusIPVault__VaultNotOpen.selector, IAsclepiusIPVault.State.Canceled)
        );
        asclepiusIPVaultInstance.deposit(address(mockUsdc), amount);
        vm.stopPrank();

        assertEq(uint(asclepiusIPVaultInstance.getState()), uint(IAsclepiusIPVault.State.Canceled));
    }

    function test_revert_AsclepiusIPVault_updateUsdcContractAddress_VaultNotOpen() public {
        vm.startPrank(u.admin);
        asclepiusIPVaultInstance.close();

        vm.expectRevert(
            abi.encodeWithSelector(Errors.AsclepiusIPVault__VaultNotOpen.selector, IAsclepiusIPVault.State.Closed)
        );
        asclepiusIPVaultInstance.updateUsdcContractAddress(address(mockUsdc));
        vm.stopPrank();
    }

    function test_revert_AsclepiusIPVault_updateUsdcContractAddress_ActiveDepositsExist() public {
        _aliceDeposits(100_000);

        vm.startPrank(u.admin);
        vm.expectRevert(
            abi.encodeWithSelector(
                Errors.AsclepiusIPVault__ActiveDepositsExist.selector,
                address(mockUsdc),
                100_000 * 10 ** mockUsdc.decimals()
            )
        );
        asclepiusIPVaultInstance.updateUsdcContractAddress(address(mockUsdc));
        vm.stopPrank();
    }

    //TODO: more tests

    function _aliceDeposits(uint256 amount) internal {
        vm.startPrank(u.alice);
        mockUsdc.mint(u.alice, amount * 10 ** mockUsdc.decimals());
        mockUsdc.approve(address(asclepiusIPVaultInstance), amount * 10 ** mockUsdc.decimals());
        vm.expectEmit();
        emit IAsclepiusIPVault.DepositReceived(u.alice, address(mockUsdc), amount * 10 ** mockUsdc.decimals());
        asclepiusIPVaultInstance.deposit(address(mockUsdc), amount * 10 ** mockUsdc.decimals());
        vm.stopPrank();
    }

    function _bobDeposits(uint256 amount) internal {
        vm.startPrank(u.bob);
        mockUsdc.mint(u.bob, amount * 10 ** mockUsdc.decimals());
        mockUsdc.approve(address(asclepiusIPVaultInstance), amount * 10 ** mockUsdc.decimals());
        vm.expectEmit();
        emit IAsclepiusIPVault.DepositReceived(u.bob, address(mockUsdc), amount * 10 ** mockUsdc.decimals());
        asclepiusIPVaultInstance.deposit(address(mockUsdc), amount * 10 ** mockUsdc.decimals());
        vm.stopPrank();
    }

    function _carlDeposits(uint256 amount) internal {
        vm.startPrank(u.carl);
        mockUsdc.mint(u.carl, amount * 10 ** mockUsdc.decimals());
        mockUsdc.approve(address(asclepiusIPVaultInstance), amount * 10 ** mockUsdc.decimals());
        vm.expectEmit();
        emit IAsclepiusIPVault.DepositReceived(u.carl, address(mockUsdc), amount * 10 ** mockUsdc.decimals());
        asclepiusIPVaultInstance.deposit(address(mockUsdc), amount * 10 ** mockUsdc.decimals());
        vm.stopPrank();
    }
}
