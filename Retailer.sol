pragma solidity ^0.4.23;
contract Retailer {
    
    enum orderStatus {placed, inprocess, dispatched, rejected, received}
    
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
    address owner;
    uint retailerCount;
    uint priceItem1;
    
    mapping (address => retailer) retailers;
    mapping (uint => mapping (uint => order)) orders;
    
    uint contractBalance;
    
    constructor(uint _price, address _owner) public {
        admin = msg.sender;
        retailerCount = 0;
        contractBalance = 0;
        priceItem1 = _price;
        owner = _owner;
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
    
    function updateRetailer(address _retailer1, string _name, bool _discount, uint8 _percent) public
    adminonly returns (bool) {
        if(retailers[_retailer1].addr  == 0) {
            revert('Not a registered retailer');
        }
        
        retailer memory retailerTemp;
        retailerTemp = retailers[_retailer1];
        
        retailerTemp.name = _name;
        retailerTemp.discountAllowed = _discount;
        retailerTemp.discountPercent = _percent;
        
        retailers[_retailer1] = retailerTemp;
        return true;
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
            revert('Not enough amount to place the order');
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
        contractBalance+=_orderValue;
        return _retailer.numOrders;
    } 
    
    function trackOrder(uint _retailerId, uint _orderId) public constant returns (orderStatus) {
        
        if(retailers[msg.sender].addr == 0) {
            if(admin != msg.sender) {
                revert('Not a registered retailer/Admin');
            }
        }
        
        order memory orderTemp;
        orderTemp = orders[_retailerId][_orderId];
        
        return orderTemp.status;
    }
    
    function updateOrder(uint _retailerId, uint _orderId, uint8 _status) public returns (bool) {
        
        if(retailers[msg.sender].addr == 0) {
            if(admin != msg.sender) {
                revert('Not a registered retailer/Admin');
            }
        }
        
        if(msg.sender != admin) {
            if(retailers[msg.sender].addr != 0) {
                if (_status != 4) {
                    revert('Retailer can only update the status as Received');
                }
            }
            else {
                revert('Not a registered retailer');
            }
        }
        else {
            if(_status == 0 || _status == 4)
            revert('Admin cant update the order with this status');
        }
        
        order memory orderTemp;
        orderTemp = orders[_retailerId][_orderId];
        orderTemp.status = orderStatus(_status);
        
        orders[_retailerId][_orderId] = orderTemp;
        
        if(msg.sender != admin){
            sendEther(orderTemp.orderValue);    
        }
        return true;
    }
    
    function sendEther(uint _value) internal {
        owner.transfer(_value);
        contractBalance-=_value;
    }

}
