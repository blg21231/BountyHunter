pragma solidity >=0.5.0 <0.6.0;

import "./Ownable.sol";
import "./safemath.sol";
import "./BountyHunter.sol";
import "./EDU.sol";

contract eduInterface {
  function transfer(address to, uint256 amount) external returns (bool);
}

contract BountyHunterInterface {
  function getAddress() external view returns (address);
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
    uint bounty_reward;
    uint voters_reward;
    string subject;
    uint difficulty;
    Response[] responses;
  }
  
  Bounty[] public Bounties;
  EDU edu;
  BountyHunter bh;
  
  mapping (address => uint) numResponses;

  modifier validBounty(uint _bountyNum) {
    require((_bountyNum > 0) && (_bountyNum < Bounties.length));
    _;
  }
  
  function getAddress() public {
    return address(this);
  }
  
  function _createBounty_ETH(string _name, string _description, uint _expiration, string _subject, uint _difficulty) internal payable {
    require(msg.value >= 0.001 ether);
    Bounties.push(Bounty(msg.sender, _name, _description, _expiration, msg.value / 0.001 * 100, 0,  _subject, _difficulty, []));
    bh.getAddress().send(msg.value);
    emit bountyCreated(msg.sender, _name, _description, _expiration, msg.value / 0.001 * 100, 0, _subject, _difficulty, []); 
  }

  function _createBounty_EDU(string _name, string _description, uint _expiration, string _subject, uint _difficulty) internal payable {
    require(msg.value >= 100 EDU);
    Bounties.push(Bounty(msg.sender, _name, _description, _expiration, "EDU", msg.value, _subject, _difficulty, []));
    edu.burn(address(this), msg.value);
    emit bountyCreated(msg.sender, _name, _description, _expiration, "EDU", msg.value, _subject, _difficulty, []); 
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
    
    edu.mint(Bounties[_bountyNum].responses[r].responder, Bounties[_bountyNum].bounty_quantity);
    for (uint v = 0; v < Bounties[_bountyNum].responses[winningResponse].votes.length; v++) {
      edu.mint(Bounties[_bountyNum].responses[winningResponse].votes[v].voter, (totalVotes - winningVotes) * Bounties[_bountyNum].responses[winningResponse].votes[v].numVotes / winningVotes);
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
  
  function createResponse_ETH(uint _bountyNum, string _response) public payable {
    if ((isStudent[msg.sender] == False) || (numResponses[msg.sender] >= 5)) {
        require(msg.value == 0.001 ether);
    }
    Vote[] initVotes = [];
    Response response = Response(msg.sender, _response, initVotes);
    Bounties[_bountyNum].responses.push(response);
    numResponses[msg.sender]++;
    Bounties[_bountyNum].bounty_reward = uint(Bounties[_bountyNum].bounty_reward) + msg.value / 0.001 * 100 / 2;
    Bounties[_bountyNum].voters_reward = uint(Bounties[_bountyNum].voters_reward) + msg.value / 0.001 * 100 / 2;
    bh.getAddress().send(msg.value);
    emit responseCreated(_bountyNum, Bounties[_bountyNum].responses.length - 1);
  }
  
  function createResponse_EDU(uint _bountyNum, string _response) public payable {
    if ((isStudent[msg.sender] == False) || (numResponses[msg.sender] >= 5)) {
        require(msg.value == 100 EDU);
    }
    Vote[] initVotes = [];
    Response response = Response(msg.sender, _response, initVotes);
    Bounties[_bountyNum].responses.push(response);
    numResponses[msg.sender]++;
    Bounties[_bountyNum].bounty_reward = uint(Bounties[_bountyNum].bounty_reward) + msg.value / 2;
    Bounties[_bountyNum].voters_reward = uint(Bounties[_bountyNum].voters_reward) + msg.value / 2;
    edu.burn(address(this), msg.value);
    emit responseCreated(_bountyNum, Bounties[_bountyNum].responses.length - 1);
  }
  
  function createVote_ETH(uint _bountyNum, uint _responseNum) public payable {
    if ((isStudent[msg.sender] == False) || (numResponses[msg.sender] >= 5)) {
        require(msg.value >= 0.001 ether;
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
    Bounties[_bountyNum].bounty_reward = uint(Bounties[_bountyNum].bounty_reward) + msg.value / 0.001 * 100 / 2;
    Bounties[_bountyNum].voters_reward = uint(Bounties[_bountyNum].bounty_reward) + msg.value / 0.001 * 100 / 2;
    bh.getAddress().send(msg.value);
    uint refund = msg.value - votesPurchased * 0.001;
    msg.sender.send(refund);
    emit responseCreated(_bountyNum, Bounties[_bountyNum].responses.length - 1);
  }
  
  function createVote_EDU(uint _bountyNum, uint _responseNum) public payable {
    if ((isStudent[msg.sender] == False) || (numResponses[msg.sender] >= 5)) {
        require(msg.value >= 100 EDU);
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
    Bounties[_bountyNum].bounty_reward = uint(Bounties[_bountyNum].bounty_reward) + msg.value / 2;
    Bounties[_bountyNum].voters_reward = uint(Bounties[_bountyNum].bounty_reward) +  msg.value / 2;
    edu.burn(address(this), msg.value);
    uint refund = msg.value - votesPurchased * 100;
    edu.transfer(msg.sender, refund);
    emit responseCreated(_bountyNum, Bounties[_bountyNum].responses.length - 1);
  }
}
    
    
    
