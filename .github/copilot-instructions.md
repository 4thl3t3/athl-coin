# Copilot Instructions

## Project Overview

This is **Scaffold-ETH 2 (Foundry flavor)** — a dApp starter kit for Ethereum. The repo is a monorepo with two packages:

- `packages/foundry` — Solidity contracts, deploy scripts, tests (Forge/Anvil)
- `packages/nextjs` — React frontend (Next.js App Router, RainbowKit, Wagmi, Viem, DaisyUI)

**`SE2Token` is a placeholder contract.** Replace it (or add alongside it) with the real application contracts.

## Dev Workflow

```bash
yarn chain      # Start local Anvil node (chain ID 31337)
yarn deploy     # Compile + deploy + auto-generate deployedContracts.ts
yarn start      # Start Next.js at http://localhost:3000
```

Run each in a separate terminal. Always run `yarn deploy` after any Solidity change — it regenerates `packages/nextjs/contracts/deployedContracts.ts` via `scripts-js/generateTsAbis.js`. **Never edit `deployedContracts.ts` manually.**

## Adding a New Contract

1. Create `packages/foundry/contracts/MyContract.sol`
2. Create `packages/foundry/script/DeployMyContract.s.sol` inheriting `ScaffoldETHDeploy` with the `ScaffoldEthDeployerRunner` modifier (required for broadcast + ABI export):

```solidity
import { DeployHelpers } from "./DeployHelpers.s.sol";
contract DeployMyContract is ScaffoldETHDeploy {
    function run() external ScaffoldEthDeployerRunner {
        MyContract myContract = new MyContract();
    }
}
```

3. Register it in `packages/foundry/script/Deploy.s.sol`:

```solidity
DeployMyContract deployMyContract = new DeployMyContract();
deployMyContract.run();
```

4. Deploy: `yarn deploy` (all contracts) or `yarn deploy --file DeployMyContract.s.sol` (single contract)

## Frontend Contract Interaction

Use hooks from `~~/hooks/scaffold-eth`. The `contractName` string must exactly match the key in `deployedContracts.ts` (set by the deploy script):

```tsx
const { data: balance } = useScaffoldReadContract({
  contractName: "SE2Token",
  functionName: "balanceOf",
  args: [connectedAddress],
});

const { writeContractAsync } = useScaffoldWriteContract("SE2Token");
await writeContractAsync({ functionName: "mint", args: [address, parseEther("1")] });
```

Available hooks: `useScaffoldReadContract`, `useScaffoldWriteContract`, `useScaffoldEventHistory`, `useScaffoldWatchContractEvent`, `useScaffoldContract`, `useDeployedContractInfo`, `useTransactor`.

See `packages/nextjs/app/erc20/page.tsx` as a reference implementation.

## UI Components & Styling

Import web3 UI primitives from `@scaffold-ui/components`:

```tsx
import { Address, AddressInput, Balance, EtherInput } from "@scaffold-ui/components";
```

Use **DaisyUI** classes for layout/components (`btn btn-primary`, `card bg-base-100`, etc.). Use the `~~` path alias for all intra-nextjs imports:

```tsx
import { useTargetNetwork } from "~~/hooks/scaffold-eth";
```

## Solidity Conventions

- OpenZeppelin import remapping: `@openzeppelin/contracts/` → `lib/openzeppelin-contracts/contracts` (see `remappings.txt`)
- Pragma range: `>=0.8.0 <0.9.0` for contracts, `^0.8.19` for deploy scripts
- Deploy script filenames use `PascalCase.s.sol` (`DeployMyContract.s.sol`)

## Testing (Forge)

Tests live in `packages/foundry/test/` with `.t.sol` extension. Test contracts inherit from `forge-std/Test.sol`:

```solidity
import { Test } from "forge-std/Test.sol";
contract MyContractTest is Test {
    function setUp() public { /* runs before each test */ }
    function test_SomeBehavior() public { ... }
    function testFuzz_Transfer(uint256 amount) public {
        amount = bound(amount, 1, 1000 ether);
        // fuzz automatically runs 256 iterations
    }
}
```

Key conventions: test functions prefixed `test_`, revert tests prefixed `test_RevertWhen_`, fuzz tests prefixed `testFuzz_`. Use `vm.prank`, `vm.deal`, `vm.warp`, `vm.expectRevert`, `vm.expectEmit` cheatcodes.

```bash
yarn foundry:test              # run all tests
forge test --match-test test_X # run specific test
forge test -vvv                # show traces for failures
forge test -vvvv               # show traces for all tests
```

## Network Configuration

- Default target: `chains.foundry` (local Anvil, chain ID 31337) — set in `packages/nextjs/scaffold.config.ts`
- To deploy to a live network: add/use an RPC entry in `packages/foundry/foundry.toml` → `[rpc_endpoints]`, then `yarn deploy --network <name>`
- Add the network to `targetNetworks` in `scaffold.config.ts` for the frontend; decrease `pollingInterval` for L2 chains

## Code Review

Use the **`grumpy-carlos-code-reviewer`** specialized agent for code reviews before finalizing changes.

## Key File Reference

| File | Purpose |
|------|---------|
| `packages/foundry/contracts/SE2Token.sol` | Placeholder ERC-20 — replace with real contracts |
| `packages/foundry/script/Deploy.s.sol` | Entry point orchestrating all deployments |
| `packages/foundry/script/DeployHelpers.s.sol` | `ScaffoldETHDeploy` base + `ScaffoldEthDeployerRunner` modifier |
| `packages/nextjs/contracts/deployedContracts.ts` | Auto-generated ABIs — do not edit |
| `packages/nextjs/scaffold.config.ts` | Target networks, API keys, polling interval |
| `packages/nextjs/app/erc20/page.tsx` | Reference page showing read/write hook patterns |
