pragma solidity ^0.8.13;

contract Vat {
    // --- Data ---

    // struct Ilk
    uint256 public ilk_Art;
    uint256 public ilk_rate;
    uint256 public ilk_spot;
    uint256 public ilk_line;
    uint256 public ilk_dust;

    // struct Urn
    uint256 public urn_ink;
    uint256 public urn_art;


    // mapping (address => uint256) public dai;  // [rad]
    uint256 public dai_i;
    
    // mapping (bytes32 => mapping (address => uint)) public gem;  // [wad]
    uint256 public gem_i_u;

    uint256 public debt;  // Total Dai Issued    [rad]
    uint256 public vice;  // Total Unbacked Dai  [rad]
    uint256 public Line;  // Total Debt Ceiling  [rad]
    uint256 public live;  // Active Flag

    // --- Events ---
    event Init(bytes32 indexed ilk);
    event Rely(address indexed usr);
    event File(bytes32 indexed what, uint256 data);
    event File(bytes32 indexed ilk, bytes32 indexed what, uint256 data);
    // int256 wad -> uint256 wad
    event Slip(bytes32 indexed ilk, address indexed usr, uint256 wad);
    // int256 dink, int256 dart => uint256 dink, uint256 dart
    event Frob(bytes32 indexed i, address indexed u, address v, address w, uint256 dink, uint256 dart);
    // int256 rate -> uint256 rate
    event Fold(bytes32 indexed i, address indexed u, uint256 rate);

    // modifier auth 

    function wish(address bit, address usr) internal view returns (bool) {
        return bit == usr; // either(bit == usr, can[bit][usr] == 1);
    }

    // --- Init ---
    constructor() {
        // removed:
        // wards[msg.sender] = 1;
        live = 1;
        emit Rely(msg.sender);
    }

    // --- Math ---
    // in _add(), _sub(): int256 y => uint256 y
    // removed: _int256() 

    function _add(uint256 x, uint256 y) internal pure returns (uint256 z) {
        unchecked {
            z = x + y;
        }
        require(y >= 0 || z <= x);
        // require(y <= 0 || z >= x);
    }

    function _sub(uint256 x, uint256 y) internal pure returns (uint256 z) {
        unchecked {
            z = x - y;
        }
        require(y <= 0 || z <= x);
        // require(y >= 0 || z >= x);
    }

    // --- Administration ---
    // removed: rely(), deny(), cage();

    function init(bytes32 ilk) public { // external auth
        require(ilk_rate == 0, "Vat/ilk-already-init");
        ilk_rate = 10 ** 27;
        emit Init(ilk);
    }

    function file(bytes32 what, uint256 data) public { // external auth
        require(live == 1, "Vat/not-live");
        if (what == "Line") Line = data;
        else revert("Vat/file-unrecognized-param");
        emit File(what, data);
    }

    function file(bytes32 ilk, bytes32 what, uint256 data) public { // external auth
        require(live == 1, "Vat/not-live");
        if (what == "spot") ilk_spot = data;
        else if (what == "line") ilk_line = data;
        else if (what == "dust") ilk_dust = data;
        else revert("Vat/file-unrecognized-param");
        emit File(ilk, what, data);
    }

    // removed: struct getters, allowance: hope(), nope()


    // --- Fungibility ---
    // in slip(): int256 wad => uint256 wad
    // removed: flux(), move()

    // int256 wad => uint256 wad
    function slip(bytes32 ilk, address usr, uint256 wad) public { // external auth
        gem_i_u = _add(gem_i_u, wad);
        emit Slip(ilk, usr, wad);
    }

    function either(bool x, bool y) internal pure returns (bool z) {
        assembly{ z := or(x, y)}
    }

    function both(bool x, bool y) internal pure returns (bool z) {
        assembly{ z := and(x, y)}
    }

    // --- CDP Manipulation ---
    // in frob(): int256 dink, int256 dart => uint256 dink, uint256 dart

    function frob(bytes32 i, address u, address v, address w, uint256 dink, uint256 dart) public { // external
        // system is live
        require(live == 1, "Vat/not-live");

        // ilk has been initialised
        require(ilk_rate != 0, "Vat/ilk-not-init");

        urn_ink = _add(urn_ink, dink);
        urn_art = _add(urn_art, dart);
        ilk_Art = _add(ilk_Art, dart);

        // int256 dtab => uint256 dtab
        uint256 dtab = ilk_rate * dart;
        uint256 tab = ilk_rate * urn_art;
        debt     = _add(debt, dtab);

        // either debt has decreased, or debt ceilings are not exceeded
        require(either(dart <= 0, both(ilk_Art * ilk_rate <= ilk_line, debt <= Line)), "Vat/ceiling-exceeded");
        // urn is either less risky than before, or it is safe
        require(either(both(dart <= 0, dink >= 0), tab <= urn_ink * ilk_spot), "Vat/not-safe");

        // urn is either more safe, or the owner consents
        require(either(both(dart <= 0, dink >= 0), wish(u, msg.sender)), "Vat/not-allowed-u");
        // collateral src consents
        require(either(dink <= 0, wish(v, msg.sender)), "Vat/not-allowed-v");
        // debt dst consents
        require(either(dart >= 0, wish(w, msg.sender)), "Vat/not-allowed-w");

        // urn has no debt, or a non-dusty amount
        require(either(urn_art == 0, tab >= ilk_dust), "Vat/dust");

        gem_i_u = _sub(gem_i_u, dink);
        dai_i   = _add(dai_i,   dtab);

        emit Frob(i, u, v, w, dink, dart);
    }

    // --- CDP Fungibility ---
    // removed: fork(), grab(), heal(), suck()


    // --- Rates ---
    // in fold(): int256 rate_ -> uint256 rate_
    function fold(bytes32 i, address u, uint256 rate_) public { // external auth
        require(live == 1, "Vat/not-live");
        // _add(int256 rad) -> _sub(uint256 rad)
        ilk_rate    = _sub(ilk_rate, rate_);
        // int256 rad -> uint256 rad
        uint256 rad  = ilk_Art * rate_;
        dai_i       = _sub(dai_i, rad);
        debt        = _sub(debt,  rad);

        emit Fold(i, u, rate_);
    }

    // --- FEoD Violation --- 
    function fail() external {      
        // Constructor
        live = 1;
        // wards[msg.sender] = 1;

        // Setup
        init("gems");
        file("gems", "spot", 0.5*10**27); // ray(0.5  ether));
        file("gems", "line", 1000*10**27); // rad(1000 ether));
        file("Line",         1000*10**27); // rad(1000 ether));
        address me = msg.sender; // address(this);
        slip("gems", me, 8*10**27);

        // Exploit
        frob("gems", me, me, me, 8, 4);
        fold("gems", me, 10**27);
        init("gems");

        assert(debt == (vice + ilk_Art * ilk_rate));
    }
}