# Asclepius Protocol Core

## Architecture

### AsclepiusIPVault

The main contract that manages the RWIP lifecycle, from collecting funds (crowdsourcing) to registering Asclepius IP Assets for RWIP. It also deploys fractionalized IP Tokens and the staking (distribution) contract.

All users who participate in the crowdsourcing fundraising will be entitled to claim fractionalized tokens in proportion to their contributions.

### AsclepiusIPVaultFactory

A launchpad for AsclepiusIPVault that deploys an individual AsclepiusIPVault contract for each RWIP.

### AsclepiusIPDistributionContract

The staking contract allows token holders to stake fractionalized IP Tokens and LP tokens into the distribution (staking) contract to earn royalties from the RWIP as staking rewards. Each IP has its own dedicated Distribution Contract.

### TokenizerModule

A component of Story Protocol responsible for tokenizing and fractionalizing IPs. It deploys an ERC20 token contract (using a whitelisted ERC20 token template) for the specified IP. Only the IP owner has permission to tokenize the IP.

### OwnableERC20

The default ERC20 token template, where only the ERC20 token contract owner can mint tokens to specified recipients.

### IPAsset

The IP Asset contract that is deployed when an RWIP is registered into Story Protocol.

### IpRoyaltyVault

The IP Royalty Vault is deployed for each IP Asset to store royalties earned by the IP.

Royalties stored in the Vault will eventually be transferred to the IP’s staking/distribution contract for further distribution to stakeholders.

## Workflows

### Admin Register IP and Fractionalize Workflow

- The admin calls the AsclepiusIPVault function `registerIPAndFractionalize(...)` to register the IP.
- The AsclepiusIPVault interacts with SPG to mint and register the IP, while setting its metadata.
- The AsclepiusIPVault becomes the owner of the `IP Asset`.
- The AsclepiusIPVault calls the `TokenizerModule` to fractionalize/tokenize the IP.
- The TokenizerModule deploys an `OwnableERC20` contract.
- The TokenizerModule assigns the `AsclepiusIPVault` as the owner of the OwnableERC20 contract.
- The AsclepiusIPVault deploys the `AsclepiusIPDistributionContract` (Staking Contract).

### User Claim Fractionalized Token Workflow

- User call Asclepius IPVault function `claimIPToken()`
- AsclepiusVault call `OwnerableERC20` to mint token to the User


## Usage

### Build

```shell
$ forge build
```

### Test

```shell
$ forge test
```

