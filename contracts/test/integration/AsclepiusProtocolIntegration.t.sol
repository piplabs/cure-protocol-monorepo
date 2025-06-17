// // SPDX-License-Identifier: UNLICENSED
// pragma solidity 0.8.26;

// import { SPGNFTLib } from "@storyprotocol/periphery/contracts/lib/SPGNFTLib.sol";
// import { ISPGNFT } from "@storyprotocol/periphery/contracts/interfaces/ISPGNFT.sol";
// import { WorkflowStructs } from "@storyprotocol/periphery/contracts/lib/WorkflowStructs.sol";
// import { OwnableERC20 } from "@storyprotocol/periphery/contracts/modules/tokenizer/OwnableERC20.sol";
// import { PILFlavors } from "@storyprotocol/core/lib/PILFlavors.sol";
// import { Licensing } from "@storyprotocol/core/lib/Licensing.sol";

// import { BaseTest } from "../utils/BaseTest.t.sol";
// import { AsclepiusIPVault } from "../../contracts/AsclepiusIPVault.sol";
// import { IAsclepiusIPVault } from "../../contracts/interfaces/IAsclepiusIPVault.sol";
// import { IAsclepiusIPDistributionContract } from "../../contracts/interfaces/IAsclepiusIPDistributionContract.sol";

// // @notice This test is to test the end to end flow of the Asclepius Protocol
// contract AsclepiusProtocolIntegrationTest is BaseTest {
//     address internal asclepiusNft;
//     AsclepiusIPVault internal asclepiusIPVault;
//     IAsclepiusIPDistributionContract internal ipDistributionContract;
//     OwnableERC20 internal fractionalToken;

//     function setUp() public override {
//         super.setUp();

//         // pre-requisites
//         // create a spg nft collection
//         asclepiusNft = registrationWorkflows.createCollection({
//             spgNftInitParams: ISPGNFT.InitParams({
//                 name: "ASCLEPIUS NFT",
//                 symbol: "ASCLEPIUSNFT",
//                 baseURI: "",
//                 contractURI: "",
//                 maxSupply: 1000,
//                 mintFee: 0, // no nft mint fee
//                 mintFeeToken: address(0),
//                 mintFeeRecipient: address(0),
//                 owner: u.admin,
//                 mintOpen: true,
//                 isPublicMinting: false // only address with minter role can mint
//             })
//         });
//     }

//     function test_AsclepiusProtocolIntegration_EndToEnd() public {
//         address multisigWallet = address(0x123);
//         uint256 expiredTime = block.timestamp + 30 days;

//         // 1. deploy an asclepius ip vault via AsclepiusIPVaultFactory
//         {
//             asclepiusIPVault = AsclepiusIPVault(
//                 asclepiusIPVaultFactory.deployIpVault({
//                     vaultAdmin: u.admin,
//                     expiredTime: expiredTime,
//                     fundReceiver: multisigWallet,
//                     rwipName: "Mickey Mouse",
//                     fractionalTokenName: "Fractional Mickey Mouse",
//                     fractionalTokenSymbol: "FMICKEY",
//                     totalSupplyOfFractionalToken: 1_000_000_000 * 10 ** 18, // 1 billion
//                     usdcContractAddress: address(mockUsdc)
//                 })
//             );

//             assertEq(asclepiusIPVault.getAdmin(), u.admin);
//             assertEq(asclepiusIPVault.getExpirationTime(), expiredTime);
//             assertEq(asclepiusIPVault.getFundReceiver(), multisigWallet);
//             assertEq(asclepiusIPVault.getRwipName(), "Mickey Mouse");
//             assertEq(asclepiusIPVault.getFractionalTokenName(), "Fractional Mickey Mouse");
//             assertEq(asclepiusIPVault.getFractionalTokenSymbol(), "FMICKEY");
//             assertEq(asclepiusIPVault.getTotalSupplyOfFractionalToken(), 1_000_000_000 * 10 ** 18);
//             assertEq(asclepiusIPVault.getUsdcContractAddress(), address(mockUsdc));
//             assertEq(uint(asclepiusIPVault.getState()), uint(IAsclepiusIPVault.State.Open));
//         }

//         // 2. admin grant minter role to the vault
//         {
//             vm.prank(u.admin);
//             ISPGNFT(asclepiusNft).grantRole(SPGNFTLib.MINTER_ROLE, address(asclepiusIPVault));
//         }

//         // 3. user can deposit usdc into the vault
//         {
//             vm.startPrank(u.alice);
//             mockUsdc.mint(u.alice, 20_000 * 10 ** mockUsdc.decimals());
//             mockUsdc.approve(address(asclepiusIPVault), 20_000 * 10 ** mockUsdc.decimals());
//             vm.expectEmit();
//             emit IAsclepiusIPVault.DepositReceived(u.alice, address(mockUsdc), 20_000 * 10 ** mockUsdc.decimals());
//             asclepiusIPVault.deposit(address(mockUsdc), 20_000 * 10 ** mockUsdc.decimals()); // alice deposits 10,000 usdc
//             vm.stopPrank();

//             vm.startPrank(u.bob);
//             mockUsdc.mint(u.bob, 30_000 * 10 ** mockUsdc.decimals());
//             mockUsdc.approve(address(asclepiusIPVault), 30_000 * 10 ** mockUsdc.decimals());
//             vm.expectEmit();
//             emit IAsclepiusIPVault.DepositReceived(u.bob, address(mockUsdc), 30_000 * 10 ** mockUsdc.decimals());
//             asclepiusIPVault.deposit(address(mockUsdc), 30_000 * 10 ** mockUsdc.decimals()); // bob deposits 10,000 usdc
//             vm.stopPrank();

//             vm.startPrank(u.carl);
//             mockUsdc.mint(u.carl, 50_000 * 10 ** mockUsdc.decimals());
//             mockUsdc.approve(address(asclepiusIPVault), 50_000 * 10 ** mockUsdc.decimals());
//             vm.expectEmit();
//             emit IAsclepiusIPVault.DepositReceived(u.carl, address(mockUsdc), 50_000 * 10 ** mockUsdc.decimals());
//             asclepiusIPVault.deposit(address(mockUsdc), 50_000 * 10 ** mockUsdc.decimals()); // carl deposits 10,000 usdc
//             vm.stopPrank();
//         }

//         // 4. Vault reach expiration time, withdraw the usdc to the fund receiver (multisig wallet)
//         {
//             vm.warp(expiredTime);

//             address[] memory expectedTokens = new address[](1);
//             expectedTokens[0] = address(mockUsdc);
//             uint256[] memory expectedWithdrawnAmounts = new uint256[](1);
//             expectedWithdrawnAmounts[0] = 100_000 * 10 ** mockUsdc.decimals();

//             vm.prank(u.admin);
//             vm.expectEmit();
//             emit IAsclepiusIPVault.TokensWithdrawn(multisigWallet, expectedTokens, expectedWithdrawnAmounts);
//             (address[] memory tokens, uint256[] memory withdrawnAmounts) = asclepiusIPVault.withdraw();
//             assertEq(tokens.length, 1);
//             assertEq(tokens[0], expectedTokens[0]);
//             assertEq(withdrawnAmounts[0], expectedWithdrawnAmounts[0]);
//             assertEq(mockUsdc.balanceOf(multisigWallet), expectedWithdrawnAmounts[0]);
//             assertEq(mockUsdc.balanceOf(address(asclepiusIPVault)), 0);
//         }

//         // 5. The admin buys the IP and register the IP on Story and deploys fractionalized ERC20 token
//         {
//             vm.startPrank(u.admin);
//             vm.expectEmit(true, false, false, false);
//             emit IAsclepiusIPVault.IPRegisteredAndFractionalized(
//                 ipAssetRegistry.ipId(block.chainid, address(asclepiusNft), 1),
//                 address(asclepiusNft),
//                 1,
//                 0,
//                 address(0),
//                 address(0)
//             );
//             (
//                 uint256 tokenId,
//                 address ipId,
//                 uint256 licenseTermsId,
//                 address fractionalTokenAddr,
//                 address distributionContract
//             ) = asclepiusIPVault.registerIPAndFractionalize({
//                     spgNftContract: address(asclepiusNft),
//                     ipMetadata: WorkflowStructs.IPMetadata({
//                         ipMetadataURI: "https://example.com/mickey-mouse/ip-metadata.json",
//                         ipMetadataHash: bytes32(0x1234567890abcdef01234567890abcdef01234567890abcdef01234567890abc),
//                         nftMetadataURI: "https://example.com/mickey-mouse/nft-metadata.json",
//                         nftMetadataHash: bytes32(0x1234567890abcdef01234567890abcdef01234567890abcdef01234567890abc)
//                     }),
//                     licenseTermsData: WorkflowStructs.LicenseTermsData({
//                         terms: PILFlavors.commercialRemix({
//                             mintingFee: 100 * 10 ** rewardToken.decimals(), // 100 reward tokens
//                             commercialRevShare: 10_000_000, // 10%
//                             royaltyPolicy: royaltyPolicyLAPAddr,
//                             currencyToken: address(rewardToken)
//                         }),
//                         licensingConfig: Licensing.LicensingConfig({
//                             isSet: false,
//                             mintingFee: 0,
//                             licensingHook: address(0),
//                             hookData: "",
//                             commercialRevShare: 0,
//                             disabled: false,
//                             expectMinimumGroupRewardShare: 0,
//                             expectGroupRewardPool: address(0)
//                         })
//                     }),
//                     fractionalTokenTemplate: address(ownableERC20Template),
//                     distributionContractTemplate: address(asclepiusIPDistributionContractTemplate),
//                     initData: IAsclepiusIPDistributionContract.InitData({
//                         admin: u.admin,
//                         ipId: ipAssetRegistry.ipId(block.chainid, address(asclepiusNft), 1),
//                         protocolTreasury: testProtocolTreasury,
//                         protocolTaxRate: testProtocolTaxRate,
//                         rewardDistributionPeriod: testRewardDistributionPeriod,
//                         rewardToken: address(rewardToken),
//                         fractionalTokenAllocPoints: 100
//                     })
//                 });
//             vm.stopPrank();
//             fractionalToken = OwnableERC20(fractionalTokenAddr);
//             ipDistributionContract = IAsclepiusIPDistributionContract(distributionContract);

//             assertEq(tokenId, 1);
//             assertTrue(ipAssetRegistry.isRegistered(ipId));
//             assertEq(fractionalToken.owner(), address(asclepiusIPVault));
//             assertEq(fractionalToken.name(), "Fractional Mickey Mouse");
//             assertEq(fractionalToken.symbol(), "FMICKEY");
//             assertEq(fractionalToken.cap(), 1_000_000_000 * 10 ** 18);
//             assertEq(ipDistributionContract.getAdmin(), u.admin);
//             assertEq(ipDistributionContract.getIpId(), ipAssetRegistry.ipId(block.chainid, address(asclepiusNft), 1));
//             assertEq(ipDistributionContract.getProtocolTreasury(), testProtocolTreasury);
//             assertEq(ipDistributionContract.getProtocolTaxRate(), testProtocolTaxRate);
//             assertEq(ipDistributionContract.getRewardDistributionPeriod(), testRewardDistributionPeriod);
//             assertEq(ipDistributionContract.getRewardToken(), address(rewardToken));
//             assertEq(ipDistributionContract.getPoolAllocPoints(address(fractionalToken)), 100);
//             assertEq(ipDistributionContract.getTotalAllocPoints(), 100);
//             (, uint256 attachedLicenseTermsId) = licenseRegistry.getAttachedLicenseTerms(ipId, 0);
//             assertEq(attachedLicenseTermsId, licenseTermsId);
//         }

//         // 6. The depositors claims their fractionalized ERC20 token
//         uint256 aliceAmtClaimed;
//         uint256 bobAmtClaimed;
//         uint256 carlAmtClaimed;
//         uint256 totalAmtClaimed;
//         {
//             address fractionalTokenAddr;
//             uint256 aliceAmountExpected = (20_000 * fractionalToken.cap()) / 100_000;
//             vm.startPrank(u.alice);
//             vm.expectEmit();
//             emit IAsclepiusIPVault.FractionalTokenClaimed(u.alice, aliceAmountExpected);
//             (fractionalTokenAddr, aliceAmtClaimed) = asclepiusIPVault.claimFractionalTokens(u.alice);
//             vm.stopPrank();
//             assertEq(aliceAmtClaimed, aliceAmountExpected);
//             assertEq(OwnableERC20(fractionalTokenAddr).balanceOf(u.alice), aliceAmountExpected);
//             totalAmtClaimed += aliceAmtClaimed;
//             uint256 bobAmountExpected = (30_000 * fractionalToken.cap()) / 100_000;
//             vm.startPrank(u.bob);
//             vm.expectEmit();
//             emit IAsclepiusIPVault.FractionalTokenClaimed(u.bob, bobAmountExpected);
//             (fractionalTokenAddr, bobAmtClaimed) = asclepiusIPVault.claimFractionalTokens(u.bob);
//             vm.stopPrank();
//             assertEq(bobAmtClaimed, bobAmountExpected);
//             assertEq(OwnableERC20(fractionalTokenAddr).balanceOf(u.bob), bobAmountExpected);
//             totalAmtClaimed += bobAmtClaimed;
//             uint256 carlAmountExpected = (50_000 * fractionalToken.cap()) / 100_000;
//             vm.startPrank(u.carl);
//             vm.expectEmit();
//             emit IAsclepiusIPVault.FractionalTokenClaimed(u.carl, carlAmountExpected);
//             (fractionalTokenAddr, carlAmtClaimed) = asclepiusIPVault.claimFractionalTokens(u.carl);
//             vm.stopPrank();
//             assertEq(carlAmtClaimed, carlAmountExpected);
//             assertEq(OwnableERC20(fractionalTokenAddr).balanceOf(u.carl), carlAmountExpected);
//             totalAmtClaimed += carlAmtClaimed;
//         }

//         // 7. The depositors can stake the fractionalized ERC20 token to the AsclepiusIPDistributionContract
//         {
//             vm.startPrank(u.alice);
//             fractionalToken.approve(address(ipDistributionContract), aliceAmtClaimed);
//             vm.expectEmit();
//             emit IAsclepiusIPDistributionContract.Deposited(u.alice, address(fractionalToken), aliceAmtClaimed);
//             ipDistributionContract.deposit(address(fractionalToken), aliceAmtClaimed);
//             vm.stopPrank();

//             vm.startPrank(u.bob);
//             fractionalToken.approve(address(ipDistributionContract), bobAmtClaimed);
//             vm.expectEmit();
//             emit IAsclepiusIPDistributionContract.Deposited(u.bob, address(fractionalToken), bobAmtClaimed);
//             ipDistributionContract.deposit(address(fractionalToken), bobAmtClaimed);
//             vm.stopPrank();

//             vm.startPrank(u.carl);
//             fractionalToken.approve(address(ipDistributionContract), carlAmtClaimed);
//             vm.expectEmit();
//             emit IAsclepiusIPDistributionContract.Deposited(u.carl, address(fractionalToken), carlAmtClaimed);
//             ipDistributionContract.deposit(address(fractionalToken), carlAmtClaimed);
//             vm.stopPrank();
//         }

//         // 8. IP generates revenue, anyone can collects the revenue to the the AsclepiusIPDistributionContract
//         uint256 totalRevenue = 10_000_000 * 10 ** rewardToken.decimals();
//         {
//             rewardToken.mint(address(this), totalRevenue);
//             rewardToken.approve(address(royaltyModule), totalRevenue);
//             royaltyModule.payRoyaltyOnBehalf({
//                 receiverIpId: ipAssetRegistry.ipId(block.chainid, address(asclepiusNft), 1),
//                 payerIpId: address(0),
//                 token: address(rewardToken),
//                 amount: totalRevenue
//             });

//             ipDistributionContract.collectRoyalties();
//             assertEq(ipDistributionContract.getRewardDistributionPeriod(), testRewardDistributionPeriod);
//             assertEq(
//                 ipDistributionContract.getCurrentDistributionEndBlock(),
//                 block.number + testRewardDistributionPeriod
//             );
//         }

//         // 9. The stakers can claim their rewards base on the time they've staked
//         {
//             vm.roll(block.number + testRewardDistributionPeriod);

//             uint256 aliceRewardPreTax = (aliceAmtClaimed * totalRevenue) / totalAmtClaimed;
//             uint256 aliceTaxPaid = (aliceRewardPreTax * testProtocolTaxRate) / 100_000_000;
//             uint256 aliceRewardPostTax = aliceRewardPreTax - aliceTaxPaid;
//             vm.startPrank(u.alice);
//             vm.expectEmit();
//             emit IAsclepiusIPDistributionContract.RewardsClaimed(u.alice, aliceTaxPaid, aliceRewardPostTax);
//             ipDistributionContract.claimAllRewards(u.alice);
//             vm.stopPrank();
//             assertEq(rewardToken.balanceOf(u.alice), aliceRewardPostTax);
//             assertEq(rewardToken.balanceOf(address(testProtocolTreasury)), aliceTaxPaid);
//             assertEq(rewardToken.balanceOf(address(ipDistributionContract)), totalRevenue - aliceRewardPreTax);

//             uint256 bobRewardPreTax = (bobAmtClaimed * totalRevenue) / totalAmtClaimed;
//             uint256 bobTaxPaid = (bobRewardPreTax * testProtocolTaxRate) / 100_000_000;
//             uint256 bobRewardPostTax = bobRewardPreTax - bobTaxPaid;
//             vm.startPrank(u.bob);
//             vm.expectEmit();
//             emit IAsclepiusIPDistributionContract.RewardsClaimed(u.bob, bobTaxPaid, bobRewardPostTax);
//             ipDistributionContract.claimAllRewards(u.bob);
//             vm.stopPrank();
//             assertEq(rewardToken.balanceOf(u.bob), bobRewardPostTax);
//             assertEq(rewardToken.balanceOf(address(testProtocolTreasury)), aliceTaxPaid + bobTaxPaid);
//             assertEq(
//                 rewardToken.balanceOf(address(ipDistributionContract)),
//                 totalRevenue - aliceRewardPreTax - bobRewardPreTax
//             );

//             uint256 carlRewardPreTax = (carlAmtClaimed * totalRevenue) / totalAmtClaimed;
//             uint256 carlTaxPaid = (carlRewardPreTax * testProtocolTaxRate) / 100_000_000;
//             uint256 carlRewardPostTax = carlRewardPreTax - carlTaxPaid;
//             vm.startPrank(u.carl);
//             vm.expectEmit();
//             emit IAsclepiusIPDistributionContract.RewardsClaimed(u.carl, carlTaxPaid, carlRewardPostTax);
//             ipDistributionContract.claimAllRewards(u.carl);
//             vm.stopPrank();
//             assertEq(rewardToken.balanceOf(u.carl), carlRewardPostTax);
//             assertEq(rewardToken.balanceOf(address(testProtocolTreasury)), aliceTaxPaid + bobTaxPaid + carlTaxPaid);
//             assertEq(
//                 rewardToken.balanceOf(address(ipDistributionContract)),
//                 totalRevenue - aliceRewardPreTax - bobRewardPreTax - carlRewardPreTax
//             );
//         }
//         // for more complicated staking tests see AsclepiusIPDistributionContract.t.sol
//     }
// }
