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
  

## Requirements 
- [x] The multisig contract allows k-of-n signers to execute an arbitrary method on an arbitrary contract
- [x] Anyone can execute the multisig as long as they provide the required signatures
- [x] The blockchain’s native transaction/signature verification mechanism should NOT be used for it, i.e. the verification should happen within the smart contract, and not via the chain’s native account authorization/multisig feature.
- [x] Feel free to pick any signature scheme to use for the multisig
- [x] The multisig should also allow the current signers to sign off on an update to a new signer set
- [x] Define a list of tests that you would add for coverage (they don’t need to be implemented).


# Solution 
### Design Philosophy 
**KISS: Keep It Simple, Stupid** </br>
  *- Kelly Johnson* 

The two primary principles that will dictate the design for this would be functionality and security, Once the design meets at the intersection of both and works as intended, the solution is complete, everything beyond that becomes excess weight. 

The objective is to minimize code and by extension, minimize attack surfaces. 

![KISS Design Philosophy: Intersection of Functionality and Security](media/sol.png)

## Approach
A systematic approach will be used to build the contract, it will be a bottom up approach, breaking down each logical building block and building while reasoning the security of the single block and then at the end, looking at the security of the system *as is*, before moving on to the next reponsibility. 

## Threat model 

The [Threat Model Manifesto](https://www.threatmodelingmanifesto.org/) will be used, to evaluate each logical block, with focus on the first three questions. And the fourth will be evaluated at the end of the system build.
1. What are we working on?
2. What can go wrong?
3. What are we going to do about it?
4. Did we do a good enough job?

Each logical block will be evaluated on both the attack sufface it introduces in isolation and in the system. 


## System design 
### External functions
![The system design from ext functions view](media/system.png)

## Logical blocks
- [x] Skeleton (State variables, functions, events & modifiers)
- [x] Access Control
- [ ] Call 
- [x] Signature Verification
- [ ] Funds Transfer
- [x] Update signer

## Skeleton 
[Commit: 0a86fc3](https://github.com/0xffchain/multisig-contract/commit/0a86fc3c90452af305da7d796ef243de64be364a) This is the basic. It will be included in all subsequent tests. 


#### Update 1
[Commit: de7fbee](https://github.com/0xffchain/multisig-contract/commit/de7fbee5b1aa8d45207a4d717ebf9e35059bae43)
Updated skeleton to remove signers history. The signers history will be emited in the `Updated` event,
also all update to signers at `#update` and `#constructor` fnc , will emit the `Updated` event. 

Pros
1. Keeps the state tree clean 
2. Saves on gas
3. Moves all non contract needed data out of the contract state. 
4. Moves historical computation offchain
5. Reduces attack suface by reducing code size

#### Update 1.1

[Commit: bc3bdd7](https://github.com/0xffchain/multisig-contract/commit/bc3bdd7031d566476ade1743152c6e5f25ed112f) Updated events to index nonce, for proper offchain tracking.

Pros. 
1. Makes tracking of state easier offchain. 


## Access Control

- [x] Build the constructor function to update signers and threshold
- [x] Add modifier to update
- [x] Write test cases for functions and state variable
   
### [TM Q1] What are we working on?
The access control for the multisig contract, which should dictate who has access to what  entry points in the contract. 

 **What are the entry points**
 - Execute
 - Update
 - Recieve
  
**Who has access to each**
 - Execute : Callable by anyone, but will only succeed if the provided signatures are from the current signers and meet the threshold. 
 - Update : Callable by anyone, but will only succeed if called with the current set signatures and within threshold.
 - Recieve : Anyone can send ether to the contract.

**Note**
Authorization is enforced by signature verification, not by restricting who can call the function.

### [TM Q2] What can go wrong? 

1. Anyone can call `execute` and `update` (as they are external and have no onlyOwner or similar modifier).
This is intentional in a multisig: the contract relies on signature checks, not msg.sender, for authorization.

2. If update does not use the same mechanism and process as `execute` being that it has same requiremnts, it could open up new attack surface.  

### [TM Q3] What are we going to do about it?

1. Restrict `update` so it can only be called by the contract itself. To update the signers set or threshold, users must submit a multisig-approved transaction via `execute` that calls `update` with the new parameters. This ensures that all critical changes require the same level of multisig approval, maintaining consistency, security and reducing attack surfaces. 

## Signature Verification 
- [x] Choose a scheme to use
- [x] Signers data validation
- [x] Signers signature validation
   
### [TM Q1] What are we working on? 

Building the mechanism that checks and enforces that only valid, unique, and authorized signatures from the current signer set can approve and execute transactions, using a secure and replay-resistant signature scheme.

### [TM Q2] What can go wrong? 

Building the mechanism that checks and enforces that only valid, unique, and authorized signatures from the current signer set can approve and execute transactions, using a secure and replay-resistant signature scheme. 

**What is a valid signature** 
   - A valid signature Correctly signs the expected transaction hash (including all relevant parameters and the current nonce)
   - Is produced using the private key of a current signer
   - Passes cryptographic verification (e.g., ecrecover returns a nonzero address)
 
**Who are the valid signers**
   - The current set of the approved signers.
   - Only signatures from this set are counted towards threshold. 
   
**What constiteutes a valid action**
   - Valid unique signature set
   - Threshold reached
   - No replay
   - Correct transaction hash


### [TM Q2] What can go wrong?

1. Malformed message hash 
2. Replay attack
   1. Cross chain
   2. Cross Contract
   3. Time base (noce)
3. Duplicate signatures
4. Bad signature accepeted 
5. Signature maliability 
6. Old signer set valid in new


### [TM Q3] What are we going to do about it?
1. Malformed message hash: Use a well-defined, structured hash (EIP-712 or EIP-191) and test hash construction off-chain and on-chain for consistency.
2. Replay attack: Use EIP-712 for domain separation (protects against cross-chain, contract, and function replay). Use a nonce to prevent reuse of signatures on the same contract and function.
3. Duplicate signatures: Check for signature uniqueness in the verification logic.
4. Bad signature accepeted: Check that `ecrecover` returns a nonzero address and that the address is in the current signer set.
5. Signature maliability: [will be addressed later on, on further research] 
6. Old signer set valid in new: Maintain a single set of only present signers; invalidate old signers, and ensure the nonce is independent of the signer set.

## Update Signers set
   - [x] Validate new set same requirements as current set
   - [x] Delete current set
   - [ ] Test cases

### [TM Q1] What are we working on? 

We are building the mechanism that allows the current set of signers, meeting the required threshold, to securely update the signer set and threshold of the multisig contract. This mechanism must ensure that only a multisig-approved transaction can change who the signers are or what the threshold is, and that the new signer set is valid (no duplicates, no zero addresses, threshold is within bounds). In essence the same validation mechanism that the first set of signers were updated with should be applied to this. 

### [TM Q2] What can go wrong?
1. Unauthorized Update:
2. Threshold Lockout
3. Duplicate Signers
4. Zero Address in Signers
5. One of two calls fails
   1. call 1: valid signatures
   2. call 2: calls self to update signatures
6. Replay or Reentrancy Attack
  
### [TM Q3] What are we going to do about it?
1. Unauthorized Update: Only the valid set is allowed to call this func, this is performed by limiting only the contract to call update func. So the transaction to update must be executed through the contracts execute function which only permits the valid set.
2. Threshold Lockout : we will use the same validation mechanism as the initial signers which does not allow threshold < 1. 
3. Duplicate Signers : we will use the same validation mechanism as the initial signers which does not allow duplicate signatures. 
4. Zero Address in Signers : we will use the same validation mechanism as the initial signers which does not allow zero addresses.
5. One of two calls fails : The second call to the `to` address must be successful for the entire transaction to be valid. 
   1. call 1: valid signatures
   2. call 2: calls self to update signatures
6. Replay or Reentrancy Attack : The nonce is updated in execute, so the execute function handles this already. 

## Test cases
1. Deployment / Constructor
   - Deploy with valid signers and threshold.
   - Fail to deploy with:
     - Zero signers.
     - Duplicate signers.
     - Zero threshold.
     - Threshold greater than number of signers.
     - Zero address as a signer.
2. Access Control
   - Any address (EOA or contract) can call execute (should not revert due to access control).
   - If an EOA or external contract calls update, it reverts with "Not authorized".
   - If the contract itself calls update (e.g., via an internal call or through execute), it does not revert due to access control.
   - Any address can send Ether to the contract via the receive function.
   - Any address can call the view functions (nonce(), threshold(), signers(uint256), isSigner(address)) without restriction.
3. execute Function
   - Succeeds with exactly threshold valid, unique signatures from current signers.
   - Succeeds with more than threshold valid, unique signatures.
   - Fails with fewer than threshold signatures.
   - Fails with duplicate signatures.
   - Fails with signatures from non-signers.
   - Fails with invalid signatures (random data).
   - Fails if the same signer signs twice.
   - Fails if nonce is not current (replay attack).
4. update Function
   - Succeeds with a valid new signer set and threshold.
   - Fails if called by an EOA or external contract (not via multisig).
   - Succeeds if called by the contract itself (via execute) with valid signatures and threshold.
   - Fails with zero signers.
   - Fails with threshold = 0.
   - Fails with threshold greater than the number of signers.
   - Fails with duplicate signers in the new set.
   - Fails with zero address in the new signer set.
   - Fails if any validation fails, and state remains unchanged.
   - Succeeds with the same signer set and threshold (optional, depending on logic).
   - Emits the Updated event on successful update with correct parameters.
   - After removing a signer, that address cannot sign future transactions.
   - After adding a new signer, that address can sign future transactions.
   - After changing the threshold, the new threshold is enforced for subsequent transactions.






   