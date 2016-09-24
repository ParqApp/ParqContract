//creates ownership of contract so a central admin can freeze accounts
contract owned {
    address public owner;

    function owned(){
        owner = msg.sender;
    }

    modifier onlyOwner(){
        if(msg.sender != owner) throw;
        _
    }
    //transfers ownership of the contract
    function transferOwnership(address newOwner) onlyOwner {
        owner = newOwner;
    }

}

contract MyToken is owned {
    /* This creates an array with all balances */
    mapping (address => uint256) public balanceOf;
    string public name;
    string public symbol;
    uint8 public decimals;
    address centralMeter;

    //creates public event on the blockchain that will notify clients
    event Transfer(address indexed from, address indexed to, uint256 value);

    //initiates contract with initial supply of tokens to creator of contract
    function MyToken(uint256 initialSupply, string tokenName, uint8 decimalUnits, string tokenSymbol, address meterMaster){
        balanceOf[msg.sender] = initialSupply;      //gives creator all initial tokens
        name = tokenName;                           //sets the name for display purposes
        symbol = tokenSymbol;                       //sets the symbol for display purposes
        decimals = decimalUnits;                    //amount of decimals for display purposes
        if(centralMeter != 0) owner = meterMaster;
    }
    //send coins
    function transfer(address _to, uint256 _value){
        if(balanceOf[msg.sender] < _value || balanceOf[_to] + _value < balanceOf[_to])
            throw;

        if(frozenAccount[msg.sender])
            throw;

        if(!approvedAccount[msg.sender])
            throw;

        balanceOf[msg.sender] -= _value;
        balanceOf[_to] += _value;
        Transfer(msg.sender, _to, _value);
    }
    //creates array of all frozen accounts
    mapping (address => bool) public frozenAccount;
    event FrozenAccount(address target, bool frozen);

    //creates array of all approved accounts
    mapping (address => bool) public approvedAccount;
    event ApprovedAccount(address target, bool approved);

    //adds public event notifying clients about a frozen account
    function freezeAccount(address target, bool freeze) onlyOwner{
        frozenAccount[target] = freeze;
        FrozenAccount(target, freeze);
    }

    //adds public event notifying clients about an approved account
    function approveAccount(address target, bool approve) onlyOwner{
        approvedAccount[target] = approve;
        ApprovedAccount(target, approve);
    }

}
