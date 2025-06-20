# Multisig Contract

## Problem statement
As discussed, we would like to give you a little homework. Please implement a smart contract for
a multisig wallet in your preferred smart contract VM (Solidity/EVM, Rust/Cosmwasm, Rust/Solana
etc.).

## Goal 
 1. How you approach a new challenge.
 2. Which issues you faced along the way.
 3. How you design a solution.
 4. How you think about its security.
  

## Requirements. 
1. The multisig contract allows k-of-n signers to execute an arbitrary method on an arbitrary contract
2. Anyone can execute the multisig as long as they provide the required signatures
3. The blockchain’s native transaction/signature verification mechanism should NOT be used for it,
i.e. the verification should happen within the smart contract, and not via the chain’s native account
authorization/multisig feature.
4. Feel free to pick any signature scheme to use for the multisig
5. The multisig should also allow the current signers to sign off on an update to a new signer set
6. Define a list of tests that you would add for coverage (they don’t need to be implemented).