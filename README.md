# Unruggable Resolve: Resolution of ENS Names with Secure Resolvers and Metadata

**Unruggable Resolve** enables clients to resolve ENS names using secured resolvers. Over the past few years, ENS names have diversified to include L1 onchain names, L2 onchain names, and offchain names. However, there is currently no straightforward way for clients to determine which names to resolve or assess their security properties.

Unruggable Resolve provides clients with the tools they need to resolve, for example, only ENS names that meet their specific security requirements. Additionally, it enables the resolution of onchain records, such as zk-based attestations, such as a text record `isOver18`.

At present, ENS name resolution lacks critical metadata. Unruggable Resolve addresses this gap by providing comprehensive metadata for ENS names, including:

- **The type of resolver** (e.g., L1, L2, or offchain).
- **Whether the resolver is fully end-to-end verified** using proofs.
- **Resolver audits and a corresponding audit ID**.
- **A resolver registry** that logs resolvers with a block number.
- **A history of resolver changes**.
- **Whether the resolver is immutable**.

This metadata enables the derivation of a trust score for each ENS name based on its associated data. Clients can use this information to validate that a resolver has not been changed abruptly, thereby preventing name owners from spoofing onchain records, such as token balances or attestations.

## Resolving ENS Names with Metadata

Currently, clients resolve ENS names through various methods, such as using libraries like `ethers.js` or custom software setups. Unruggable Resolve meets clients where they are, offering the flexibility to complement existing resolution methods or act as a standalone solution for resolving names. Metadata provided during name resolution allows clients to make real-time, strategic decisions, such as blocking insecure names or records. Additionally, it is possible to expose metadata to end users, providing valuable insights into the security of a name.

Secure ENS name resolvers are essential for resolving onchain records, such as token balances or zk-based attestations. Currently, existing methods allow text records to be modified, potentially displaying spoofed values. With Unruggable Resolve, metadata facilitates the secure resolution of specific text records, such as a WETH token balance represented as `weth-balance`.

Unruggable Resolve can also be used as a trusted API service for resolving ENS names along with metadata. Through a mix-and-match strategy, we deliver what clients need to resolve ENS names securely and effectively.

- **Trusted Metadata**: Some metadata associated with ENS names is managed by Unruggable and provided as trusted advisory data (e.g., audit details and quality assessments of resolvers).
- **Onchain Metadata**: Other metadata is onchain and cryptographically provable, such as detecting resolver address changes.

### Clients can access ENS name resolution and metadata through two methods:

1. **API Access**: Clients using trusted RPC servers for L1 Ethereum nodes may find it convenient and equally secure to resolve ENS names and metadata via the API.
2. **Onchain Access**: Clients operating their own L1 Ethereum nodes or allowing users to set their own RPC server may prefer to resolve ENS names and metadata directly onchain.

## Comprehensive ENS Name Registry Website

**Unruggable.com** will be a comprehensive information resource for ENS name data and metadata:

- **Name Ownership History**: A timeline of ownership changes, including transfers, expiration events, and resolver updates.
- **Profile Status**: Identifies whether the ENS name qualifies as a "Profile" with bidirectional validation through forward and reverse resolution records.
- **Name Records**: Displays ENS name records, including avatar, contenthash, text records, and social links.
- **Resolver Type**: Indicates whether the resolver operates on L1, L2, or offchain infrastructure.
- **Resolve Proofs**: Shows whether L2 resolvers use proofs to ensure data integrity.
- **Resolver Audit Check**: Indicates whether the resolver has undergone independent audits.
- **Resolver History**: Tracks resolver changes, updates, and any “locks” set on the registry.
- **Community Stars**: Allows users to star resolvers, reflecting trust and authenticity.

## Foundry Project
This is a Foundry project with tests. To run the tests make sure that Foundry is installed, clone the repo, and install the dependencies. 

## Running Tests

You can run the test suite using `forge`:

`
forge test
`

