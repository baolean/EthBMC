pragma solidity ^0.8.4;

contract Overflow {
    mapping(uint256 => uint256) public sin;
    uint256 public Sin;

    function flog() public {
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
