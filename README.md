## Overview

### Components

The following contracts are provided:

```console
- token
    - ERC20
        - BaseERC20.sol
        - MintableERC20.sol
    - ERC721
        - BaseERC721.sol
- farming
- LP vaults
- strategies
    - convex
- vesting
- oracles
- voting
```

### Installation

```console
$ npm install @scalingparrots/contracts
```

### Usage

Once installed, you can use the contracts in the library by importing them:

```solidity
pragma solidity ^0.8.0;
import "@scalingparrots/contracts/ERC20/BaseERC20.sol";
contract MyToken is BaseERC20 {
    constructor() BaseERC20("MyToken", "MTK") {
    }
}
```

## Security

This project is maintained by [ScalingParrots](https://scalingparrots.com), and developed following our high standards for code quality and security. ScalingParrots Contracts is meant to provide tested and community-audited code, but please use common sense when doing anything that deals with real money! We take no responsibility for your implementation decisions and any security problems you might experience.

## Audit

Contracts are not audited, use at your own risk