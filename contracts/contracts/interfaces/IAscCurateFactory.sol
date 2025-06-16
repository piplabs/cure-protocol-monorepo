// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.26;

import { IAscCurate } from "./IAscCurate.sol";

/**
 * @title IAscCurateFactory
 * @notice Interface for the IAscCurateFactory contract
 */
interface IAscCurateFactory {
    /**
     * @notice Emitted when a new curate is deployed
     * @param curate The address of the new curate
     */
    event CurateDeployed(address indexed curate);

    /**
     * @notice Emitted when the curate template is updated
     * @param oldCurateTemplate The address of the old curate template
     * @param newCurateTemplate The address of the new curate template
     */
    event CurateTemplateUpdated(address indexed oldCurateTemplate, address indexed newCurateTemplate);

    /**
     * @notice Initializes the factory
     * @param admin_ The address of the admin
     * @param curateTemplate_ The address of the curate template
     */
    function initialize(address admin_, address curateTemplate_) external;

    /**
     * @notice Launches a new curate instance
     * @param initData The initialization data for the AscCurate {see IAscCurate.CurateInitData}
     */
    function launchCurate(IAscCurate.CurateInitData memory initData) external returns (address curate);

    /**
     * @notice Sets the curate template
     * @param newCurateTemplate The address of the new curate template
     */
    function setCurateTemplate(address newCurateTemplate) external;

    /**
     * @notice Returns the address of the admin
     * @return admin The address of the admin
     */
    function getAdmin() external view returns (address);

    /**
     * @notice Returns the address of the curate template
     * @return curateTemplate The address of the curate template
     */
    function getCurateTemplate() external view returns (address);
}
