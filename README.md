## Overview

### Components

The following libraries are included:

```console
"@openzeppelin/contracts": "^4.7.3",
"@uniswap/lib": "^4.0.1-alpha",
"@uniswap/v2-core": "^1.0.1",
"@uniswap/v2-periphery": "^1.1.0-beta.0",
"@chainlink/contracts": "^0.5.1",
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
