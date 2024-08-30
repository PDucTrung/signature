// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.20;
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract Signature is Ownable {
    address public backendSigner;
    mapping(address => uint256) public points;

    // Event
    event Deposited(address indexed user, uint256 amount);
    event FundsWithdrawn(address indexed to, uint256 value);

    constructor(address _backendSigner) Ownable(msg.sender) {
        backendSigner = _backendSigner;
    }

    function exchangePointsForTokens(
        uint256 point,
        uint256 timestamp,
        bytes memory signature
    ) public {
        bytes32 messageHash = keccak256(
            abi.encodePacked(msg.sender, point, timestamp)
        );

        bytes32 ethSignedMessageHash = prefixed(messageHash);
        require(
            recoverSigner(ethSignedMessageHash, signature) == backendSigner,
            "Invalid signature"
        );

        points[msg.sender] += point;
    }

    function prefixed(bytes32 hash) internal pure returns (bytes32) {
        return
            keccak256(
                abi.encodePacked("\x19Ethereum Signed Message:\n32", hash)
            );
    }

    function recoverSigner(bytes32 message, bytes memory sig)
        internal
        pure
        returns (address)
    {
        (uint8 v, bytes32 r, bytes32 s) = splitSignature(sig);
        return ecrecover(message, v, r, s);
    }

    function splitSignature(bytes memory sig)
        internal
        pure
        returns (
            uint8 v,
            bytes32 r,
            bytes32 s
        )
    {
        require(sig.length == 65, "Invalid signature length");

        assembly {
            r := mload(add(sig, 32))
            s := mload(add(sig, 64))
            v := byte(0, mload(add(sig, 96)))
        }
    }
}
