pragma solidity ^0.4.23;
contract Retailer {
    
    struct retailer {
        uint identity_num;
        address addr;
        string name;
        bool discount_allowed;
        uint8 discount_percent;
    }
    
    address admin;
    uint count;
    mapping (address => retailer) retailers;
    
    function Retailer() public {
        admin = msg.sender;
        count = 0;
    }
    
    modifier adminonly() {
        assert(msg.sender == admin);
        _;
    }
    function registerRetailer(address _retailer1, string _name, bool _discount, uint8 _percent) public 
    adminonly returns (uint _identity) {
        if(retailers[_retailer1] == 0) {
            revert();
        }
        retailer memory _retailer;
        count+=1;
        _retailer.addr = _retailer1;
        _retailer.identity_num = count;
        _retailer.name = _name;
        if (_discount) {
            _retailer.discount_allowed = true;
            _retailer.discount_percent = _percent;
        }
        else{
            _retailer.discount_allowed = false;
            _retailer.discount_percent = 0;
        }
        retailers[_retailer1] = _retailer;
        return count;
    }
}
