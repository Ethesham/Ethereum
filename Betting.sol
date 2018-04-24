pragma solidity ^0.4.21;
contract BettingParticipant {
    
    address admin;
    uint counter;
    struct Participant {
        address addr;
        uint id1;
        string name;
        string email;
        uint phone;
    } 
    address[] addrList;
    mapping (address => Participant) Participants;
    
    struct Fixture {
        uint matchNum;
        string matchTitle;
        uint matchDate;
        string winner;
        bool matchDrawn;
    }
    Fixture[] MatchFixtures;
    
    function BettingParticipant() public {
        admin = msg.sender;
        counter = 0;
    }
    modifier adminOnly() {
        require(msg.sender == admin);
        _;
    }
    function registerParticipant(string _name,
    string _email, uint _phone) public payable{
        
        if(Participants[msg.sender].addr != 0 || msg.value != 10){
            revert();
        }
        for(uint i=0; i<addrList.length; i++){
            if(addrList[i] == msg.sender){
                revert();
            }
        }
        
        Participant memory participant;
        participant.addr = msg.sender;
        participant.name = _name;
        participant.email = _email;
        participant.phone = _phone;
        addrList[counter] = msg.sender;
        counter++;
        participant.id1 = counter;
        
        Participants[msg.sender] = participant;
    }
    
    function addFixture(uint _matchNum, string _matchTitle, uint _matchDate) 
             public adminOnly returns(bool){
                 for(uint i=0;i<MatchFixtures.length;i++) {
                     if(MatchFixtures[i].matchNum == _matchNum || 
                        keccak256(MatchFixtures[i].matchTitle) == keccak256(_matchTitle)) {
                         revert();
                     }
                 }
                 
                 Fixture memory fixture = Fixture({matchNum: _matchNum,
                                         matchTitle: _matchTitle,
                                         matchDate: _matchDate,
                                         winner: ' ',
                                         matchDrawn: false});
                                         
                 MatchFixtures.push(fixture);
                 return true;
    }
    function modifyFixture(uint _matchNum, string _matchTitle, uint _matchDate) public adminOnly returns(bool){
        bool fixtureExists;
        for(uint i=0;i<MatchFixtures.length;i++) {
                     if(MatchFixtures[i].matchNum == _matchNum ) {
                         fixtureExists = true;
                         MatchFixtures[i].matchTitle = _matchTitle;
                         MatchFixtures[i].matchDate = _matchDate;
                     }
        }
        if(fixtureExists == false)
            return false;
        else
            return true;
    }
    
    function updateResult(uint _matchNum, string _matchTitle, string _winner) public adminOnly returns(bool){
        bool fixtureExists;
        for(uint i=0;i<MatchFixtures.length;i++) {
                     if(MatchFixtures[i].matchNum == _matchNum && 
                        keccak256(MatchFixtures[i].matchTitle) == keccak256(_matchTitle)) {
                         fixtureExists = true;
                         if(keccak256(_winner) != keccak256(' ')) {
                            MatchFixtures[i].winner = _winner;
                            MatchFixtures[i].matchDrawn = false;
                         }
                         else {
                            MatchFixtures[i].winner = ' ';
                            MatchFixtures[i].matchDrawn = true;  
                         }
                         
                     }
        }
        if(fixtureExists == false)
            return false;
        else
            return true;
    }
}
