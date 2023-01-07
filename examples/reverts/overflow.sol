pragma solidity ^0.8.4;

contract Overflow {
    mapping(uint256 => uint256) public sin;
    uint256 public Sin;
    uint256 value;

    function flog(uint256 i) public {
        assert(sin[i] != 15);

        unchecked {
            if (Sin == 44) {
                uint256 test = 1;
                Sin += test + 4;
                uint256 val = sin[test];
                // Sin == 49
                require(Sin + val >= 49, "Overflow");
            }
        }
    }
}
