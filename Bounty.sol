pragma solidity >=0.5.0 <0.6.0;

import "./Ownable.sol";
import "./safemath.sol";
import "./Account.sol";
import "./EDU.sol";

contract eduInterface {
  function transfer(address to, uint256 amount) external returns (bool);
}

contract Bounty is Ownable {

  using SafeMath for uint256;
  using SafeMath32 for uint32;
  using SafeMath16 for uint16;

  event bountyCreated(string sponsor, string name, string description, uint expiration, string bounty_asset, uint bounty_quantity, string subject, uint difficulty, Response[] responses);
  event sufficientBalance(uint accountNum, string asset, uint quantity, boolean value);
  
    struct Vote {
    address voter;
    uint numVotes;
  }
  
    struct Response {
    address responder;
    string response;
    Vote[] votes;
  }
  
    struct Bounty {
    address sponsor;
    string name;
    string description;
    uint expiration;
    string bounty_asset;
    uint bounty_quantity;
    string subject;
    uint difficulty;
    Response[] responses;
  }
  
  Bounty[] public Bounties;
  eduInterface edu;

  modifier validBounty(uint _bountyNum) {
    require((_bountyNum > 0) && (_bountyNum < Bounties.length));
    _;
  }

  function _createBounty(string _name, string _description, uint _expiration, string _bounty_asset, uint _bounty_quantity, string _subject, uint _difficulty) internal payable {
    require(msg.value >= 0.001 ether or msg.value >= 100 EDU);
    Bounties.push(Bounty(msg.sender, _name, _description, _expiration, _bounty_asset, _bounty_quantity, _subject, _difficulty, []));
    emit bountyCreated(msg.sender, _name, _description, _expiration, _bounty_asset, _bounty_quantity, _subject, _difficulty, []); 
  }
  
  function closeBounty(uint _bountyNum) private {
    uint totalVotes = 0;
    uint winningVotes = 0;
    uint winningResponse = 0;
    
    for (uint r = 0; r < Bounties[_bountyNum].responses.length; r++) {
      uint currentVotes = 0;
      for (uint v = 0; v < Bounties[_bountyNum].responses[r].votes.length; v++) {
        currentVotes = currentVotes + Bounties[_bountyNum].responses[r].votes[v].numVotes;
      }
      if (currentVotes > winningVotes) {
        winningVotes = currentVotes;
        winningResponse = r;
      }
      totalVotes = totalVotes + currentVotes;
    }
    
    emit winningResponse(_bountyNum, winningResponse);
    
    edu.transfer(Bounties[_bountyNum].responses[r].responder, Bounties[_bountyNum].bounty_quantity);
    
    for (uint v = 0; v < Bounties[_bountyNum].responses[winningResponse].votes.length; v++) {
      edu.transfer(Bounties[_bountyNum].responses[winningResponse].votes[v].voter, (totalVotes - winningVotes) * Bounties[_bountyNum].responses[winningResponse].votes[v].numVotes / winningVotes);
    }
  }
  
  function getBounties(string _sortBy, boolean asc) public {
    if (_sortBy == 'expiration') {
    }
    elif (_sortBy == 'votes') {
    }
    elif (_sortBy == 'bounty_asset') {
    }
    elif (_sortBy == 'bounty_quantity') {
    }
  }
  
  function createResponse(uint _bountyNum, string _response) public payable {
    if ((isStudent[msg.sender] == False) || (numResponses[msg.sender] >= 5)) {
        require((msg.value == 0.001 ether) || (msg.value == 100 EDU));
    }
    Vote[] initVotes = [];
    Response response = Response(msg.sender, _response, initVotes);
    Bounties[_bountyNum].responses.push(response);
    numResponses[msg.sender]++;
    if msg.value >= 0.001 ether) {
      uint refund = msg.value - votesPurchased * 0.001;
      msg.sender.transfer(msg.sender, );
    }
    else {
      uint refund = msg.value - votesPurchased * 100;
      msg.sender.transfer(refund EDU);
    }
    emit responseCreated(_bountyNum, Bounties[_bountyNum].responses.length - 1);
  }
  
  function createVote(uint _bountyNum, uint _responseNum) public payable {
    if ((isStudent[msg.sender] == False) || (numResponses[msg.sender] >= 5)) {
        require((msg.value >= 0.001 ether) || (msg.value >= 100 EDU));
    }
    uint startingVotes = 0;
    for (uint v = 0; v < Bounties[_bountyNum].responses[_responseNum].votes.length; v++) {
      if (Bounties[_bountyNum].responses[_responseNum].votes[v].voter == msg.sender) {
        startingVotes = startingVotes + Bounties[_bountyNum].responses[_responseNum].votes[v].votes;
      }
    }
    uint votesPurchased = (2 * msg.value + startingVotes**2) ** (1/2);
    Vote vote = Vote(msg.sender, votesPurchased);
    Bounties[_bountyNum].responses[_responseNum].votes.push(vote);
    if msg.value >= 0.001 ether) {
      uint refund = msg.value - votesPurchased * 0.001;
      msg.sender.transfer(refund ether);
    }
    else {
      uint refund = msg.value - votesPurchased * 100;
      msg.sender.transfer(refund EDU);
    }
    emit responseCreated(_bountyNum, Bounties[_bountyNum].responses.length - 1);
  }
}
    
    
    
