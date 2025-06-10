// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.26;

import { BaseTest } from "./utils/BaseTest.t.sol";

import { IAsclepiusIPVaultFactory } from "../contracts/interfaces/IAsclepiusIPVaultFactory.sol";
import { IAsclepiusIPVault } from "../contracts/interfaces/IAsclepiusIPVault.sol";
import { AsclepiusIPVault } from "../contracts/AsclepiusIPVault.sol";

contract AsclepiusIPVaultFactoryTest is BaseTest {
    function setUp() public override {
        super.setUp();
    }

    function test_AsclepiusIPVaultFactory_initialize() public {
        // we already have a instance initialized in the BaseTest

        // check that the instance is initialized correctly
        assertEq(asclepiusIPVaultFactory.getAdmin(), u.admin);
        assertEq(asclepiusIPVaultFactory.getVaultTemplate(), address(asclepiusIPVaultTemplate));
    }

    function test_deployIpVault() public {
        IAsclepiusIPVault newVault = IAsclepiusIPVault(
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

        assertEq(newVault.getAdmin(), u.admin);
        assertEq(newVault.getExpirationTime(), testExpiredTime);
        assertEq(newVault.getFundReceiver(), testFundReceiver);
        assertEq(newVault.getRwipName(), testRwipName);
        assertEq(newVault.getFractionalTokenName(), testFractionalTokenName);
        assertEq(newVault.getFractionalTokenSymbol(), testFractionalTokenSymbol);
        assertEq(newVault.getTotalSupplyOfFractionalToken(), testTotalSupplyOfFractionalToken);
        assertEq(newVault.getUsdcContractAddress(), address(mockUsdc));
        assertEq(uint(newVault.getState()), uint(IAsclepiusIPVault.State.Open));
    }

    function test_setVaultTemplate() public {
        address newVaultTemplate = address(
            new AsclepiusIPVault(
                address(royaltyTokenDistributionWorkflows),
                address(royaltyModule),
                address(tokenizerModule),
                address(asclepiusIPVaultBeacon)
            )
        );
        vm.prank(u.admin);
        vm.expectEmit();
        emit IAsclepiusIPVaultFactory.VaultTemplateUpdated(address(asclepiusIPVaultTemplate), newVaultTemplate);
        asclepiusIPVaultFactory.setVaultTemplate(newVaultTemplate);
        assertEq(asclepiusIPVaultFactory.getVaultTemplate(), newVaultTemplate);
    }

    //TODO: more tests
}
