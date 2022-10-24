pragma solidity ^0.8.17;

contract Second {
    bool public set;

    constructor() public {
        // set = true;
    }

    // function getset() external returns (bool) {
    //     // require(false);
    //     return false;
    // }

    function getset() external returns (bool) {
        return set;
    }

    // function _set() external {
        //  set = true;
        // assert(false);
    // }
}

contract First {
    Second public two;

    constructor(address _two) public {
        // two = Second(_two);
        // two = new Second();
    }

    // function set() external {
    //     two._set();
    // }

    function check() external {
        // bool set = two.set();
        // two._set();
        bool set = two.getset();
        if (set) {
            assert(false);
        }
    }

    // function set() external {
        // two._set();
        // assert(false);
    // }
}

