pragma solidity ^0.8.13;

contract ChainTest {

    function test() public view {
        uint256 chID;
        uint256 ts;
        chID = block.chainid;
        ts = block.timestamp;
        assert(chID == 1);
    }
}