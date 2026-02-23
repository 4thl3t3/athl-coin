// SPDX-License-Identifier: MIT
pragma solidity >=0.8.20 <0.9.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Permit.sol";

/**
 * @title AthleteCoin (ATHL)
 * @notice Fixed-supply ERC-20 token for the Athlete ecosystem.
 *
 * - Total supply: 10,000,000,000 ATHL (10 billion), minted once to `recipient` at construction.
 * - No further minting or burning is possible.
 * - Includes ERC-2612 permit (gasless approvals via signature).
 *
 * Token distribution is managed off-chain by the deployer and via VestingWallet
 * contracts created in the deploy script.
 */
contract AthleteCoin is ERC20, ERC20Permit {
    /// @notice The fixed total supply: 10 billion ATHL (18 decimals).
    uint256 public constant TOTAL_SUPPLY = 10_000_000_000 * 10 ** 18;

    /**
     * @param recipient Address that receives the entire supply at deployment.
     *                  Typically the deployer, which then distributes to vesting contracts.
     */
    constructor(address recipient) ERC20("AthleteCoin", "ATHL") ERC20Permit("AthleteCoin") {
        _mint(recipient, TOTAL_SUPPLY);
    }
}
