# 🪙 AthleteCoin (ATHL)

AthleteCoin is the project's primary ERC-20 token built. It is implemented using the [ERC-20 token implementation](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC20/ERC20.sol) from OpenZeppelin.

⚙️ Built using NextJS, RainbowKit, Foundry, Wagmi, Viem, and Typescript.

## Token properties

| Property | Value |
|---|---|
| Name | AthleteCoin |
| Symbol | ATHL |
| Total supply | 10,000,000,000 ATHL (fixed — no minting or burning) |
| Decimals | 18 |
| Standard | ERC-20 + ERC-2612 (gasless permit) |

## Token distribution

| Recipient | Amount | Vesting schedule |
|---|---|---|
| Team | 2,000,000,000 ATHL (20%) | 1-year cliff, then linear over 3 years |
| Investors | 1,500,000,000 ATHL (15%) | 6-month cliff, then linear over 18 months |
| Treasury / Ecosystem | 6,500,000,000 ATHL (65%) | Held by deployer — no lock |

Vesting is handled by OpenZeppelin [`VestingWallet`](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/finance/VestingWallet.sol) contracts deployed alongside the token. Beneficiaries claim vested tokens by calling `release(athlAddress)` on their respective vesting wallet.

## Key files

- **Contract:** `packages/foundry/contracts/AthleteCoin.sol`
- **Deploy script:** `packages/foundry/script/DeployAthleteCoin.s.sol`

## Deploy

```bash
yarn deploy                                   # deploy all contracts
yarn deploy --file DeployAthleteCoin.s.sol    # deploy AthleteCoin + vesting wallets only
```

> **Before deploying to a live network**, replace `TEAM_BENEFICIARY` and `INVESTOR_BENEFICIARY` in `DeployAthleteCoin.s.sol` with the real recipient addresses. On local Anvil these default to the deployer address.

## Requirements

Before you begin, you need to install the following tools:

- [Node (>= v20.18.3)](https://nodejs.org/en/download/)
- Yarn ([v1](https://classic.yarnpkg.com/en/docs/install/) or [v2+](https://yarnpkg.com/getting-started/install))
- [Git](https://git-scm.com/downloads)

## Quickstart

1. Install dependencies if it was skipped in CLI:

```
cd athl-coin
yarn install
```

2. Run a local network in the first terminal:

```
yarn chain
```

This command starts a local Ethereum network using Foundry. The network runs on your local machine and can be used for testing and development. You can customize the network configuration in `packages/foundry/foundry.toml`.

3. On a second terminal, deploy the test contract:

```
yarn deploy
```

This command deploys a test smart contract to the local network. The contract is located in `packages/foundry/contracts` and can be modified to suit your needs. The `yarn deploy` command uses the deploy script located in `packages/foundry/script` to deploy the contract to the network. You can also customize the deploy script.

4. On a third terminal, start your NextJS app:

```
yarn start
```

Visit your app on: `http://localhost:3000`. You can interact with your smart contract using the `Debug Contracts` page. You can tweak the app config in `packages/nextjs/scaffold.config.ts`.

Run smart contract test with `yarn foundry:test`