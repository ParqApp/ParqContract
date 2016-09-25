// creates ownership of contract so a central admin can freeze accounts
contract owned {
    address public owner;

    function owned() {
        owner = msg.sender;
    }

    modifier onlyOwner() {
        if (msg.sender != owner) throw;
        _
    }

    // transfers ownership of the contract
    function transferOwnership(address newOwner) onlyOwner {
        owner = newOwner;
    }
}

contract ParqCoin is owned {
    struct Location {
        string lat;
        string long;
        string alt;
    }

    // Defines a parking meter.
    struct Meter {
        address owner;
        uint cost;
        Location location;
    }

    mapping (address => uint256) public balanceOf;

    uint numMeters;
    mapping (uint => Meter) meters;

    string public name;
    string public symbol;
    uint8 public decimals;

    // creates public event on the blockchain that will notify clients
    event PayMeter(address indexed _from, uint indexed _id, uint _value);

    // initiates contract with initial supply of tokens to creator of contract
    function ParqCoin(uint256 initialSupply, string tokenName, uint8 decimalUnits, string tokenSymbol) {
        balanceOf[msg.sender] = initialSupply;      // gives creator all initial tokens
        name = tokenName;                           // sets the name for display purposes
        symbol = tokenSymbol;                       // sets the symbol for display purposes
        decimals = decimalUnits;                    // amount of decimals for display purposes
    }

    event NewMeter(address indexed _owner, uint indexed _id);

    // creates a new meter
    function newMeter(uint cost, string lat, string long, string alt) returns (uint meterID) {
        meterID = numMeters++; // meterID is return variable

        // Creates a new Location struct
        var location = Location(lat, long, alt);

        // Creates new struct and saves in storage. We leave out the mapping type.
        meters[meterID] = Meter(msg.sender, cost, location);

        NewMeter(msg.sender, meterID);
    }

    // pay the meter
    function payMeter(uint _meterID) {
        var _meter = meters[_meterID];
        uint256 _value = _meter.cost;
        address _to = _meter.owner;

        if (balanceOf[msg.sender] < _value || balanceOf[_to] + _value < balanceOf[_to])
            throw;

        if (frozenAccount[msg.sender])
            throw;

        // Only approved accounts can operate meters
        if (!approvedAccount[_to])
            throw;

        balanceOf[msg.sender] -= _value;
        balanceOf[_to] += _value;
        PayMeter(msg.sender, _meterID, _value);
    }

    // creates array of all frozen accounts
    mapping (address => bool) public frozenAccount;
    event FrozenAccount(address target, bool frozen);

    // adds public event notifying clients about a frozen account
    function freezeAccount(address target, bool freeze) onlyOwner {
        frozenAccount[target] = freeze;
        FrozenAccount(target, freeze);
    }

    // creates array of all approved accounts
    mapping (address => bool) public approvedAccount;
    event ApprovedAccount(address target, bool approved);

    //adds public event notifying clients about an approved account
    function approveAccount(address target, bool approve) onlyOwner {
        approvedAccount[target] = approve;
        ApprovedAccount(target, approve);
    }
}
