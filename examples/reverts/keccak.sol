pragma solidity ^0.8.17;

contract SHATest {
    bytes32 public answer =
        0x60298f78cc0b47170ba79c10aa3851d7648bd96f2f8e46a19dbc777c36fb0c00;

    function solve(string memory _word) public {
        if (keccak256(abi.encodePacked(_word)) == answer) {
            assert(false);
        }
    }
}
