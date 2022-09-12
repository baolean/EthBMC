pragma solidity ^0.8.13;

contract Sequence {

    uint count;
    uint acc;

    function test() public view {
        require(count > 0);
        assert(acc <= 15);
    }

    function add() public {
        acc -= 5;
        count += 1;
    }

    function set() public {
        acc = 16;
    }
}