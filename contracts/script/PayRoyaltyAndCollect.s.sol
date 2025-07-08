// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

import { Script } from "forge-std/Script.sol";
import { IERC20 } from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import { IRoyaltyModule } from "@storyprotocol/core/interfaces/modules/royalty/IRoyaltyModule.sol";

import { IAscCurate } from "../../contracts/interfaces/IAscCurate.sol";
import { IAscStaking } from "../../contracts/interfaces/IAscStaking.sol";

// forge script script/PayRoyaltyAndCollect.s.sol:PayRoyaltyAndCollect 0xB35b1A096e9dF59C2aA14D0Ede6B597AB00276D1 0x98776d62CE1c2A55f1b335f61589353916426Ae5 1ether --sig "run(address,address,uint256)" --fork-url=$STORY_RPC -vvvv --broadcast --sender=$ADMIN  --priority-gas-price=1 --legacy --skip-simulation
contract PayRoyaltyAndCollect is Script {
    address internal constant ROYALTY_MODULE = 0xD2f60c40fEbccf6311f8B47c4f2Ec6b040400086;
    address payable internal constant WIP_TOKEN = payable(0x1514000000000000000000000000000000000000);

    address internal ADMIN = vm.envAddress("ADMIN");

    function run(address ipId, address curateContract, uint256 amount) public virtual {
        vm.startBroadcast(vm.envUint("PK"));
        _payRoyaltyAndCollectToVault(ipId, curateContract, amount);
        vm.stopBroadcast();
    }

    function _payRoyaltyAndCollectToVault(address ipId, address curateContract, uint256 amount) internal {
        // get WIP
        (bool success, ) = WIP_TOKEN.call{ value: amount }(abi.encodeWithSignature("deposit()"));
        require(success, "Failed to deposit to WIP token");

        // approve amount WIP to royalty module
        IERC20(WIP_TOKEN).approve(ROYALTY_MODULE, amount);

        // pay royalty on behalf
        IRoyaltyModule(ROYALTY_MODULE).payRoyaltyOnBehalf({
            receiverIpId: ipId,
            payerIpId: ADMIN,
            token: WIP_TOKEN,
            amount: amount
        });

        // collect royalties
        IAscStaking(IAscCurate(curateContract).getStakingContract()).collectRoyalties();
    }
}
