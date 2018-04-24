pragma solidity ^0.4.23;
contract ModifiersTest {
    uint public a;
    uint public b;
    uint public c;
    
    modifier modA(){
        a=a+10;
        _;
        c=c+2;
    }
    
    modifier modB() {
        b=b+5;
        _;
        b=b+5;
    }
    
    function f() public modB modA returns(uint,uint,uint){
        c=c+2;
        return (a,b,c);
    }
}
