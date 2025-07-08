// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.26;

import { console2 } from "forge-std/console2.sol";
import { IERC721 } from "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import { BeaconProxy } from "@openzeppelin/contracts/proxy/beacon/BeaconProxy.sol";
import { UpgradeableBeacon } from "@openzeppelin/contracts/proxy/beacon/UpgradeableBeacon.sol";
import { ERC721Holder } from "@openzeppelin/contracts/token/ERC721/utils/ERC721Holder.sol";

import { AscCurateFactory } from "../contracts/AscCurateFactory.sol";
import { AscCurate } from "../contracts/AscCurate.sol";
import { IAscCurate } from "../contracts/interfaces/IAscCurate.sol";
import { IAscCurateFactory } from "../contracts/interfaces/IAscCurateFactory.sol";
import { BaseTest } from "./utils/BaseTest.t.sol";
import { WorkflowStructs } from "@storyprotocol/periphery/contracts/lib/WorkflowStructs.sol";

contract AscCurateFactoryTest is BaseTest, ERC721Holder {
    // Test-specific variables
    address internal testIpId2;
    uint256 internal testIpNftTokenId2;
    address internal testIpId3;
    uint256 internal testIpNftTokenId3;

    function setUp() public override {
        super.setUp();
        
        // Create additional test IPs for comprehensive testing
        _createAdditionalTestIPs();
        
        vm.label(address(ascCurateFactory), "AscCurateFactory");
        vm.label(address(ascCurateTemplate), "AscCurateTemplate");
    }

    function _createAdditionalTestIPs() internal {
        // Create second test IP
        vm.startPrank(u.admin);
        mockToken.mint(u.admin, 2 * 10 ** mockToken.decimals());
        mockToken.approve(address(spgNftPublic), 2 * 10 ** mockToken.decimals());
        (testIpId2, testIpNftTokenId2, ) = royaltyTokenDistributionWorkflows
            .mintAndRegisterIpAndAttachPILTermsAndDistributeRoyaltyTokens({
                spgNftContract: address(spgNftPublic),
                recipient: u.admin,
                ipMetadata: ipMetadataDefault,
                licenseTermsData: licenseTerms,
                royaltyShares: _createRoyaltyShares(u.admin),
                allowDuplicates: true
            });
        
        // Create third test IP for Alice
        mockToken.mint(u.alice, 1 * 10 ** mockToken.decimals());
        mockToken.approve(address(spgNftPublic), 1 * 10 ** mockToken.decimals());
        vm.stopPrank();
        
        vm.startPrank(u.alice);
        mockToken.approve(address(spgNftPublic), 1 * 10 ** mockToken.decimals());
        (testIpId3, testIpNftTokenId3, ) = royaltyTokenDistributionWorkflows
            .mintAndRegisterIpAndAttachPILTermsAndDistributeRoyaltyTokens({
                spgNftContract: address(spgNftPublic),
                recipient: u.alice,
                ipMetadata: ipMetadataDefault,
                licenseTermsData: licenseTerms,
                royaltyShares: _createRoyaltyShares(u.alice),
                allowDuplicates: true
            });
        vm.stopPrank();
        
        vm.label(testIpId2, "TestIpId2");
        vm.label(testIpId3, "TestIpId3");
    }

    function _createRoyaltyShares(address recipient) internal pure returns (WorkflowStructs.RoyaltyShare[] memory) {
        WorkflowStructs.RoyaltyShare[] memory royaltyShares = new WorkflowStructs.RoyaltyShare[](1);
        royaltyShares[0] = WorkflowStructs.RoyaltyShare({
            recipient: recipient,
            percentage: 100_000_000 // 100%
        });
        return royaltyShares;
    }


    function test_AscCurateFactory_launchCurate() public {
        IAscCurate.CurateInitData memory initData = _createCurateInitData(
            testIpId,
            address(spgNftPublic),
            testIpNftTokenId
        );
        
        // Transfer NFT to the caller (required for launchCurate)
        vm.prank(u.admin);
        spgNftPublic.safeTransferFrom(u.admin, address(this), testIpNftTokenId);
        
        // Approve factory to transfer NFT
        spgNftPublic.approve(address(ascCurateFactory), testIpNftTokenId);
        
        address curateAddress = ascCurateFactory.launchCurate(initData);
        
        // Verify the curate was deployed correctly
        assertNotEq(curateAddress, address(0));
        
        IAscCurate curate = IAscCurate(curateAddress);
        assertEq(curate.getAdmin(), initData.admin);
        assertEq(curate.getIpId(), initData.ipId);
        assertEq(curate.getExpirationTime(), initData.expirationTime);
        assertEq(curate.getFundReceiver(), initData.fundReceiver);
        assertEq(curate.getBioName(), initData.bioName);
        assertEq(curate.getBioTokenName(), initData.bioTokenName);
        assertEq(curate.getBioTokenSymbol(), initData.bioTokenSymbol);
        assertEq(uint(curate.getState()), uint(IAscCurate.State.Open));
        
        // Verify NFT was transferred to the curate
        assertEq(spgNftPublic.ownerOf(testIpNftTokenId), curateAddress);
    }

    function test_AscCurateFactory_launchCurate_multipleDeployments() public {
        // Deploy first curate
        IAscCurate.CurateInitData memory initData1 = _createCurateInitData(
            testIpId,
            address(spgNftPublic),
            testIpNftTokenId
        );
        initData1.bioName = "First Bio Project";
        initData1.bioTokenName = "First Bio Token";
        initData1.bioTokenSymbol = "FBT";
        
        vm.prank(u.admin);
        spgNftPublic.safeTransferFrom(u.admin, address(this), testIpNftTokenId);
        spgNftPublic.approve(address(ascCurateFactory), testIpNftTokenId);
        
        address curate1 = ascCurateFactory.launchCurate(initData1);
        
        // Deploy second curate with different IP
        IAscCurate.CurateInitData memory initData2 = _createCurateInitData(
            testIpId2,
            address(spgNftPublic),
            testIpNftTokenId2
        );
        initData2.bioName = "Second Bio Project";
        initData2.bioTokenName = "Second Bio Token";
        initData2.bioTokenSymbol = "SBT";
        initData2.fundReceiver = u.bob; // Different fund receiver
        
        vm.prank(u.admin);
        spgNftPublic.safeTransferFrom(u.admin, address(this), testIpNftTokenId2);
        spgNftPublic.approve(address(ascCurateFactory), testIpNftTokenId2);
        
        address curate2 = ascCurateFactory.launchCurate(initData2);
        
        // Verify both curates are different and correctly configured
        assertNotEq(curate1, curate2);
        
        IAscCurate curateContract1 = IAscCurate(curate1);
        IAscCurate curateContract2 = IAscCurate(curate2);
        
        assertEq(curateContract1.getBioName(), "First Bio Project");
        assertEq(curateContract2.getBioName(), "Second Bio Project");
        assertEq(curateContract1.getFundReceiver(), testFundReceiver);
        assertEq(curateContract2.getFundReceiver(), u.bob);
        
        // Verify NFTs were transferred correctly
        assertEq(spgNftPublic.ownerOf(testIpNftTokenId), curate1);
        assertEq(spgNftPublic.ownerOf(testIpNftTokenId2), curate2);
    }

    function test_AscCurateFactory_launchCurate_differentUsers() public {
        // Admin launches a curate
        IAscCurate.CurateInitData memory adminInitData = _createCurateInitData(
            testIpId,
            address(spgNftPublic),
            testIpNftTokenId
        );
        adminInitData.admin = u.admin;
        
        vm.prank(u.admin);
        spgNftPublic.safeTransferFrom(u.admin, address(this), testIpNftTokenId);
        spgNftPublic.approve(address(ascCurateFactory), testIpNftTokenId);
        
        address adminCurate = ascCurateFactory.launchCurate(adminInitData);
        
        // Alice launches a curate
        IAscCurate.CurateInitData memory aliceInitData = _createCurateInitData(
            testIpId3,
            address(spgNftPublic),
            testIpNftTokenId3
        );
        aliceInitData.admin = u.alice;
        aliceInitData.fundReceiver = u.alice;
        aliceInitData.bioName = "Alice's Bio Project";
        
        vm.prank(u.alice);
        spgNftPublic.safeTransferFrom(u.alice, address(this), testIpNftTokenId3);
        spgNftPublic.approve(address(ascCurateFactory), testIpNftTokenId3);
        
        address aliceCurate = ascCurateFactory.launchCurate(aliceInitData);
        
        // Verify both curates have correct admins
        assertEq(IAscCurate(adminCurate).getAdmin(), u.admin);
        assertEq(IAscCurate(aliceCurate).getAdmin(), u.alice);
        assertEq(IAscCurate(aliceCurate).getBioName(), "Alice's Bio Project");
    }

    function test_AscCurateFactory_launchCurate_revert_noNftApproval() public {
        IAscCurate.CurateInitData memory initData = _createCurateInitData(
            testIpId,
            address(spgNftPublic),
            testIpNftTokenId
        );
        
        // Transfer NFT to caller but don't approve factory
        vm.prank(u.admin);
        spgNftPublic.safeTransferFrom(u.admin, address(this), testIpNftTokenId);
        
        // Should revert because factory doesn't have approval
        vm.expectRevert(); // ERC721: caller is not token owner or approved
        ascCurateFactory.launchCurate(initData);
    }

    function test_AscCurateFactory_launchCurate_revert_notNftOwner() public {
        IAscCurate.CurateInitData memory initData = _createCurateInitData(
            testIpId,
            address(spgNftPublic),
            testIpNftTokenId
        );
        
        // Don't transfer NFT to caller - u.admin still owns it
        // Admin approves factory, but caller (this contract) doesn't own the NFT
        vm.prank(u.admin);
        spgNftPublic.approve(address(ascCurateFactory), testIpNftTokenId);
        
        // Should revert because caller doesn't own the NFT
        vm.expectRevert(); // ERC721: transfer from incorrect owner
        ascCurateFactory.launchCurate(initData);
    }

    function test_AscCurateFactory_setCurateTemplate() public {
        // Deploy a new template
        AscCurate newTemplate = new AscCurate(
            address(royaltyModule),
            address(tokenizerModule),
            address(ascCurateBeacon),
            address(ipAssetRegistry)
        );
        
        vm.startPrank(u.admin);
        vm.expectEmit();
        emit IAscCurateFactory.CurateTemplateUpdated(address(ascCurateTemplate), address(newTemplate));
        ascCurateFactory.setCurateTemplate(address(newTemplate));
        vm.stopPrank();
        
        assertEq(ascCurateFactory.getCurateTemplate(), address(newTemplate));
    }

    function test_AscCurateFactory_setCurateTemplate_revert_notAdmin() public {
        AscCurate newTemplate = new AscCurate(
            address(royaltyModule),
            address(tokenizerModule),
            address(ascCurateBeacon),
            address(ipAssetRegistry)
        );
        
        vm.startPrank(u.alice); // Not admin
        vm.expectRevert(); // Should revert for non-admin
        ascCurateFactory.setCurateTemplate(address(newTemplate));
        vm.stopPrank();
    }

    function test_AscCurateFactory_setCurateTemplate_revert_zeroAddress() public {
        vm.startPrank(u.admin);
        vm.expectRevert(); // Should revert for zero address
        ascCurateFactory.setCurateTemplate(address(0));
        vm.stopPrank();
    }


    function _deployTestCurate(address ipId, uint256 tokenId) internal returns (address) {
        IAscCurate.CurateInitData memory initData = _createCurateInitData(
            ipId,
            address(spgNftPublic),
            tokenId
        );
        
        vm.prank(u.admin);
        spgNftPublic.safeTransferFrom(u.admin, address(this), tokenId);
        spgNftPublic.approve(address(ascCurateFactory), tokenId);
        
        return ascCurateFactory.launchCurate(initData);
    }

    function _deploySecondCurate() internal returns (address) {
        IAscCurate.CurateInitData memory initData2 = _createCurateInitData(
            testIpId2,
            address(spgNftPublic),
            testIpNftTokenId2
        );
        initData2.bioName = "Second Bio Project";
        
        vm.prank(u.admin);
        spgNftPublic.safeTransferFrom(u.admin, address(this), testIpNftTokenId2);
        spgNftPublic.approve(address(ascCurateFactory), testIpNftTokenId2);
        
        return ascCurateFactory.launchCurate(initData2);
    }
} 