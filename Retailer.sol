pragma solidity ^0.4.23;
contract Retailer {
    
    enum orderStatus {placed, processed, rejected}
    
    struct order {
        uint retailerId;
        uint orderId;
        uint units;
        uint orderValue;
        uint orderDate;
        orderStatus status; 
    }
    
    struct retailer {
        uint identityNum;
        address addr;
        string name;
        bool discountAllowed;
        uint8 discountPercent;
        uint numOrders;
    }
    
    address admin;
    uint retailerCount;
    uint priceItem1;
    
    mapping (address => retailer) retailers;
    mapping (uint => mapping (uint => order)) orders;
    
    constructor(uint _price) public {
        admin = msg.sender;
        retailerCount = 0;
        priceItem1 = _price;
    }
    
    modifier adminonly() {
        assert(msg.sender == admin);
        _;
    }
    
    modifier regdRetailerOnly() {
        assert(retailers[msg.sender].addr != 0);
        _;
    }
    
    function registerRetailer(address _retailer1, string _name, bool _discount, uint8 _percent) public 
    adminonly returns (uint _identity) {
        
        if(retailers[_retailer1].addr != 0) {
            revert('Retailer already registered');
        }
        retailer memory retailerTemp;
        retailerCount+=1;
        
        if (_discount) {
            retailerTemp = retailer({identityNum: retailerCount,
                                 addr: _retailer1,
                                 name: _name,
                                 discountAllowed: true,
                                 discountPercent: _percent,
                                 numOrders: 0});
        }
        else{
            retailerTemp = retailer({identityNum: retailerCount,
                                 addr: _retailer1,
                                 name: _name,
                                 discountAllowed: false,
                                 discountPercent: 0,
                                 numOrders: 0});
        }
        retailers[_retailer1] = retailerTemp;
        return retailerCount;
    }
    
    function placeOrder(uint _units, uint _orderDate) public payable regdRetailerOnly 
    returns (uint _orderId){
        retailer memory _retailer;
        _retailer = retailers[msg.sender];
        uint _orderValue;
        _orderValue = _units * priceItem1;
        if(_retailer.discountAllowed == true) {
            _orderValue = _orderValue - ((_orderValue*_retailer.discountPercent)/100);   
        }
        if(msg.value != _orderValue) {
            revert();
        }
        
        _retailer.numOrders+=1;
        
        order memory orderTemp;
        orderTemp = order({retailerId: _retailer.identityNum,
                           orderId: _retailer.numOrders,
                           units: _units,
                           orderValue: _orderValue,
                           orderDate: _orderDate,
                           status: orderStatus.placed});
                           
        orders[_retailer.identityNum][_retailer.numOrders] = orderTemp;
        
        return _retailer.numOrders;
    } 

}
