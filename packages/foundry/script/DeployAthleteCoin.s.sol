// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import { console } from "forge-std/Script.sol";
import "../contracts/AthleteCoin.sol";
import "./DeployHelpers.s.sol";
import "@openzeppelin/contracts/finance/VestingWallet.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

/**
 * @notice Deploys AthleteCoin and sets up VestingWallet contracts for team and investor
 *         token distributions.
 *
 * Token allocation (10,000,000,000 ATHL total):
 * ┌─────────────┬────────────────┬────────────────────────────────────────────────┐
 * │ Recipient   │ Amount         │ Schedule                                       │
 * ├─────────────┼────────────────┼────────────────────────────────────────────────┤
 * │ Team        │  2,000,000,000 │ 1-year cliff, then linear over 3 years         │
 * │ Investors   │  1,500,000,000 │ 6-month cliff, then linear over 18 months      │
 * │ Deployer    │  6,500,000,000 │ Treasury / ecosystem / liquidity (no lock)     │
 * └─────────────┴────────────────┴────────────────────────────────────────────────┘
 *
 * VestingWallet behaviour:
 *   Tokens are locked until `start`, then released linearly over `duration`.
 *   Setting `start` to (deploy time + cliff period) effectively creates a cliff.
 *   Beneficiaries call `vestingWallet.release(athlAddress)` to claim vested tokens.
 *
 * Before deploying to a live network, replace the TEAM_BENEFICIARY and
 * INVESTOR_BENEFICIARY constants below with the real recipient addresses.
 */
contract DeployAthleteCoin is ScaffoldETHDeploy {
    using SafeERC20 for AthleteCoin;
    // -------------------------------------------------------------------------
    // Allocations (in ATHL base units, 18 decimals)
    // -------------------------------------------------------------------------
    uint256 constant TEAM_ALLOCATION     = 2_000_000_000 * 10 ** 18; // 20 %
    uint256 constant INVESTOR_ALLOCATION = 1_500_000_000 * 10 ** 18; // 15 %

    // -------------------------------------------------------------------------
    // Vesting durations (in seconds)
    // -------------------------------------------------------------------------
    uint64 constant ONE_YEAR       = 365 days;
    uint64 constant SIX_MONTHS     = 182 days;
    uint64 constant THREE_YEARS    = 3 * uint64(365 days);
    uint64 constant EIGHTEEN_MONTHS = 547 days; // 18 months ≈ 547 days

    // -------------------------------------------------------------------------
    // Beneficiary addresses
    // TODO: Replace with real addresses before deploying to a live network.
    //       For local Anvil testing the deployer address is used as a fallback.
    // -------------------------------------------------------------------------
    address constant TEAM_BENEFICIARY     = address(0); // replace with team multisig
    address constant INVESTOR_BENEFICIARY = address(0); // replace with investor multisig

    function run() external ScaffoldEthDeployerRunner {
        // Resolve beneficiaries: fall back to deployer on local Anvil so that
        // `yarn deploy` works out-of-the-box without editing this file first.
        address teamBeneficiary     = TEAM_BENEFICIARY     == address(0) ? deployer : TEAM_BENEFICIARY;
        address investorBeneficiary = INVESTOR_BENEFICIARY == address(0) ? deployer : INVESTOR_BENEFICIARY;

        // 1. Deploy AthleteCoin — entire 10B supply minted to the deployer.
        AthleteCoin athl = new AthleteCoin(deployer);
        console.logString(string.concat("AthleteCoin deployed at:  ", vm.toString(address(athl))));

        uint64 deployTime = uint64(block.timestamp);

        // 2. Team vesting wallet
        //    Nothing is releasable before (deployTime + 1 year).
        //    After that, tokens unlock linearly over 3 years.
        VestingWallet teamVesting = new VestingWallet(
            teamBeneficiary,
            deployTime + ONE_YEAR, // vesting start = end of 1-year cliff
            THREE_YEARS            // linear release over 3 years post-cliff
        );
        athl.safeTransfer(address(teamVesting), TEAM_ALLOCATION);
        console.logString(string.concat("Team VestingWallet at:    ", vm.toString(address(teamVesting))));

        // 3. Investor vesting wallet
        //    Nothing is releasable before (deployTime + 6 months).
        //    After that, tokens unlock linearly over 18 months.
        VestingWallet investorVesting = new VestingWallet(
            investorBeneficiary,
            deployTime + SIX_MONTHS, // vesting start = end of 6-month cliff
            EIGHTEEN_MONTHS          // linear release over 18 months post-cliff
        );
        athl.safeTransfer(address(investorVesting), INVESTOR_ALLOCATION);
        console.logString(string.concat("Investor VestingWallet at:", vm.toString(address(investorVesting))));

        // Remaining 6.5B ATHL stays with the deployer for treasury / ecosystem / liquidity.
        console.logString(
            string.concat(
                "Deployer treasury balance: ",
                vm.toString(athl.balanceOf(deployer) / 10 ** 18),
                " ATHL"
            )
        );
    }
}
