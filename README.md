# Unruggable Registry: Securely Resolving ENS Names

Currently, the most up-to-date method to resolve ENS names onchain, without a trusted intermediary, is to use a Universal Resolver. This is a smart contract that handles all the complexity of resolving an ENS name onchain. However, resolving an ENS name securely onchain and resolving a secure ENS name are not the same thing. All ENS names are resolved using the resolver of the ENS name. An ENS name is only as secure as the resolver smart contract of the name. Many names also use CCIP-Read (ERC-3668) offchain resolution, including many that are simply resolved using a fully trusted gateway server. Because an ENS name is only as secure as its resolver, to have fully secure onchain resolution of ENS names, both the resolution method and the resolvers need to be secure.

Because every ENS name has its own security properties, which could range from totally trusted to totally trustless, clients need a way to resolve only the ENS names that fit their security requirements. To provide this capability for onchain ENS name resolution, we use a Universal Resolver wrapper that allows us to add additional conditions, such as only allowing ENS names to be resolved if they have a resolver that is at least 30 days old or a resolver that is immutable and has been audited.

By choosing a custom-configured Universal Resolver wrapper contract, clients can choose which constraints they want when resolving ENS names.

## Universal Resolver Wrappers

Wrappers serve as entry point contracts for resolving ENS names. They are deployed on Ethereum Mainnet, are immutable, and anyone can use them.

### WrapperUR_30DaysOldResolver.sol

This wrapper is configured to only resolve ENS names with resolvers that are registered onchain and where the resolver is older than 30 days. This wrapper entry point is useful for preventing ENS name owners from suddenly switching out a resolver to spoof records.

### WrappedUR_AuditedResolver.sol

This wrapper only resolves ENS names that use audited resolvers. It checks against an audit registry to verify that the resolver has a valid audit ID. This provides an additional layer of security by ensuring that only ENS names with professionally audited resolver contracts can be resolved.

### WrappedUR_AuditedAnd30Days.sol

This wrapper combines both security features - it only resolves ENS names that use audited resolvers AND have been registered for at least 30 days. This provides the highest level of security by ensuring:
1. The resolver has been professionally audited
2. The resolver has been stable for at least 30 days
3. The resolver is properly registered in the resolver registry

This wrapper is ideal for applications requiring maximum security in ENS name resolution.

## How Universal Resolver Wrappers Work

A Universal Resolver wrapper, such as `WrapperUR_30DaysOldResolver.sol`, uses a special registry of resolvers that allows any name owner to register their resolver onchain.

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