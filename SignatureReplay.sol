// SPDX-License-Identifier: MIT
pragma solidity ^0.7.6;
pragma experimental ABIEncoderV2;

import "github.com/OpenZeppelin/openzeppelin-contracts/blob/release-v3.3/contracts/cryptography/ECDSA.sol";

/*
This contract is an unsecure version of a multi signature wallet because it's vulnerable 
to a signature replay attack. Indeed, once one of the owner has the other's signature he will 
be able to call transfer() as many times as he wants (signatures are not unique).
*/
contract UnsecureMultiSigWallet {
    using ECDSA for bytes32;

    address[2] public owners;

    constructor(address[2] memory _owner) payable {
        owners = _owner;
    }

    function deposit() external payable {}

    // transfers an amount of eth to someone else
    // _sigs must contain the signatures of the 2 owners of the contract
    function transfer(
        address _to,
        uint256 _amount,
        bytes[2] memory _sigs
    ) external {
        // recreate the hash that was signed from the parameters
        bytes32 txHash = getTxHash(_to, _amount);
        // check the two signatures against the hash
        require(_checkSigs(_sigs, txHash), "invalid signature");
        // send eth
        (bool success, ) = _to.call{value: _amount}("");
        require(success, "Failed to send eth");
    }

    // hashes the recipient's address and the amount of eth to be sent
    function getTxHash(address _to, uint256 _amount)
        public
        view
        returns (bytes32)
    {
        return keccak256(abi.encodePacked(_to, _amount));
    }

    // check if that each signatures was signed by an owner
    function _checkSigs(bytes[2] memory _sigs, bytes32 _txHash)
        private
        view
        returns (bool)
    {
        // recompute the actual hash that was signed
        bytes32 ethSignedHash = _txHash.toEthSignedMessageHash();
        for (uint256 i = 0; i < _sigs.length; i++) {
            // recover the signer of the signature
            address signer = ethSignedHash.recover(_sigs[i]);
            // check if the signer is an owner
            bool valid = signer == owners[i];
            if (!valid) {
                return false;
            }
        }
        return true;
    }
}

/*
This is a more secure version of the multi signature wallet above. It uses a unique signature 
for each transaction and then marks it has executed to prevent replay attacks. Unique signatures 
are created using a unique transaction hash which is created using the nonce of the transaction. 
This protects replay attacks on the same contract. We also need to protect this contract from 
replay attacks for the same contract deployed at a different address. This is achieved by including 
the address of the contract inside the transaction hash.
*/
contract SecureMultiSigWallet {
    using ECDSA for bytes32;

    address[2] public owners;

    // keeps track of executed transactions
    mapping(bytes32 => bool) public executed;

    constructor(address[2] memory _owner) payable {
        owners = _owner;
    }

    function deposit() external payable {}

    // transfers an amount of eth to someone else
    // _sigs must contain the signatures of the 2 owners of the contract
    // _nonce is the new parameter that makes the hash unique
    function transfer(
        address _to,
        uint256 _amount,
        uint256 _nonce,
        bytes[2] memory _sigs
    ) external {
        // recreate the hash that was signed from the parameters
        bytes32 txHash = getTxHash(_to, _amount, _nonce);
        // ensure the transaction has not been executed already
        require(!executed[txHash], "transaction executed");
        // ensure the two signatures were signed by owners
        require(_checkSigs(_sigs, txHash), "invalid signature");
        // update transaction status
        executed[txHash] = true;
        // send eth
        (bool success, ) = _to.call{value: _amount}("");
        require(success, "Failed to send eth");
    }

    // hashes this contract's address, the recipient's address, and the amount of eth to be sent
    // the contract's address is used to make sure the hash is unique to this contract
    function getTxHash(
        address _to,
        uint256 _amount,
        uint256 _nonce
    ) public view returns (bytes32) {
        return keccak256(abi.encodePacked(address(this), _to, _amount, _nonce));
    }

    // checks that each signatures was signed by an owner
    function _checkSigs(bytes[2] memory _sigs, bytes32 _txHash)
        private
        view
        returns (bool)
    {
        // recompute the actual hash that was signed
        bytes32 ethSignedHash = _txHash.toEthSignedMessageHash();
        for (uint256 i = 0; i < _sigs.length; i++) {
            // recover the signer of the signature
            address signer = ethSignedHash.recover(_sigs[i]);
            // check that the signer is an owner
            bool valid = signer == owners[i];
            if (!valid) {
                return false;
            }
        }
        return true;
    }
}
