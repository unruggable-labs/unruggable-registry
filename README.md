
# Unruggable Registry: Securely Resolving ENS Names

Currently, the most up-to-date method to resolve ENS names onchain, without a trusted intermediary, is to use a Universal Resolver—a smart contract that handles all the complexity of resolving an ENS name onchain. However, to provide secure ENS name resolution, we use a Universal Resolver wrapper that allows us to add additional conditions, such as only allowing ENS names to be resolved if they have a resolver that is at least 30 days old or a resolver that is immutable and has been audited.

By choosing a custom-configured Universal Resolver wrapper contract, clients can choose which constraints they want when resolving ENS names.

## Universal Resolver Wrappers

Wrappers serve as entry point contracts for resolving ENS names. They are deployed on Ethereum Mainnet, are immutable, and anyone can use them.

### WrapperUR_30DaysOldResolver.sol

This wrapper is configured to only resolve ENS names with resolvers that are registered onchain and where the resolver is older than 30 days. This wrapper entry point is useful for preventing ENS name owners from suddenly switching out a resolver to spoof records.

## How Universal Resolver Wrappers Work

The Universal Resolver Wrapper `WrapperUR_30DaysOldResolver.sol` uses a special registry of resolvers that allows any name owner to register their resolver onchain.

1. **Resolver Registry**: 
   - A registry of resolver addresses registered by name owners
   - Each record includes the resolver address and timestamp

2. **Resolution Safety Checks**:
   - Before resolving any ENS records, `WrapperUR_30DaysOldResolver` performs two critical checks:
     1. Verifies that the current resolver of the ENS name matches the one registered in `UResolverRegistry`
     2. Ensures the resolver has been in place for at least 30 days

### Security Benefits

- **Change Detection**: Immediately detects if a resolver has been changed.
- **Cooling Period**: The 30-day waiting period provides users time to:
  - Become aware of resolver changes
  - Review new resolver contracts
  - Take action if necessary
- **Attack Prevention**: Protects against sudden resolver switches that could be used to:
  - Spoof ENS records (This is particularly important for onchain records like token balances)

## Foundry Project

This is a Foundry project with tests. To run the tests, make sure that Foundry is installed, clone the repo, and install the dependencies.

## Running Tests

You can run the test suite using `forge`:

`
forge test
`