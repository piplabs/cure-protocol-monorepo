// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

interface IAscCurateFactory {

    function launchCurate(
        address ipId,
        uint256 expiredTime,
        address fundReceiver,
        string memory bioName,
        string memory bioTokenName,
        string memory bioTokenSymbol,
        uint256 minimalIpTokensForLaunch,
        uint256 ipToBioTokenRatio
    ) external returns (address curate);
}
