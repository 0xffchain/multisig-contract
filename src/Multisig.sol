// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

contract Multisig {

    string public constant NAME = "Multisig 101"; 
    string public constant VERSION = "1";
    bytes32 public immutable DOMAIN_SEPARATOR; 
    bytes32 public constant EX_HASH = keccak256("EXECUTE(address to,uint256 value,bytes data,uint256 nonce)");
    
    address[] public signers;
    mapping(address => bool) public isSigner;
    uint256 public threshold; 
    uint256 public nonce; 



    modifier onlyContract() {
        require(msg.sender == address(this), "Not authorized");
        _;
    }

    event Executed(address indexed to, uint256 value, bytes data, bool success, bytes32 indexed executeHash);
    event Updated(address[] newOwners, uint256 newThreshold, uint256 indexed nonce);
    event Received(address indexed sender, uint256 amount);

    constructor(address[] memory _signers, uint256 _threshold) {
        
        newSet(_signers, _threshold);

       DOMAIN_SEPARATOR = keccak256(
            abi.encode(
                keccak256("EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)"),
                keccak256(bytes(NAME)),
                keccak256(bytes(VERSION)),
                block.chainid,
                address(this)
            )
        );

        emit Updated(_signers, _threshold, nonce);
    }

    function execute(address to, uint256 value, bytes calldata data, bytes[] calldata signatures) external returns (bool) {
        require(signatures.length >= threshold, "Not enough signatures");
        bytes32 executeHash = getTransactionHash(to, value, data);
        
        address[] memory seen = new address[](signatures.length);

        for(uint256 i =0; i < threshold; i++){
            address signerExtracted = extract(executeHash, signatures[i]);
            require(isSigner[signerExtracted], "Not a valid signer");

            for (uint256 x = 0; x < i; x++) {
                require(seen[x] != signerExtracted, "Duplicate signature");
            }
            seen[i] = signerExtracted;

        }

        nonce++; 
        (bool res, ) = to.call{value: value}(data);

        emit Executed(to, value , data, res, executeHash);
        return res;
    }

    function update( address[] memory _signers, uint256 _threshold) onlyContract external returns (bool){
        for(uint256 x = 0; x < signers.length; x++)
        {
            isSigner[signers[x]] = false;
        }
        delete signers;

        newSet(_signers, _threshold);

        emit Updated(_signers, _threshold, nonce);
        return true;
    }

    function getTransactionHash(
        address to,
        uint value,
        bytes calldata data
    ) public view returns (bytes32) {
        bytes32 structHash = keccak256(
             abi.encode(
                EX_HASH,
                to,
                value,
                keccak256(data),
                nonce
            )
        );

        return keccak256(abi.encodePacked("\x19\x01", DOMAIN_SEPARATOR, structHash));
 
    }

    function newSet( address[] memory _signers, uint256 _threshold) internal{
        require(_signers.length > 0 &&  _threshold <= _signers.length && _threshold > 0, "Kindly provide valid owners and threshold");
        for(uint256 i = 0; i < _signers.length; i++) {
            address signer = _signers[i];
            require(signer != address(0), "Signer cannot be zero address");
            require(!isSigner[signer], "Signer already exists");
            isSigner[signer] = true;
            signers.push(signer);
        }
        threshold = _threshold;
    }

    function extract(bytes32 executeHash, bytes memory signature) internal pure returns (address) {
        require(signature.length == 65, "Invalid signature");
        bytes32 r; bytes32 s; uint8 v;
        assembly {
            r := mload(add(signature, 32))
            s := mload(add(signature, 64))
            v := byte(0, mload(add(signature, 96)))
        }
        return ecrecover(executeHash, v, r, s);
    }
    receive() external payable {}
}