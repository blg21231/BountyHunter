pragma solidity >=0.5.0 <0.6.0;

import "./ownable.sol";
import "./safemath.sol";
import "./EDU.sol";

contract BountyHunter is Ownable {

  using SafeMath for uint256;
  using SafeMath32 for uint32;
  using SafeMath16 for uint16;

  uint randNonce = 0;
  
  mapping (address => boolean) public isStudent;
  mapping (address => uint) public numResponses;
  mapping (address => string) as email;
  mapping (string => uint) as code;

  event addressVerified(address _address);
  
  modifier contains (string memory what, string memory where) {
      bytes memory whatBytes = bytes (what);
      bytes memory whereBytes = bytes (where);

      require(whereBytes.length >= whatBytes.length);

      bool found = false;
      for (uint i = 0; i <= whereBytes.length - whatBytes.length; i++) {
          bool flag = true;
          for (uint j = 0; j < whatBytes.length; j++)
              if (whereBytes [i + j] != whatBytes [j]) {
                  flag = false;
                  break;
              }
          if (flag) {
              found = true;
              break;
          }
      }
      require (found);

      _;
  }
  
  function () payable {}

  function _requestVerification(string _email) private contains(".edu", _email) returns (uint) {
    email[msg.sender] = _email;
    uint random = uint(keccak256(abi.encodePacked(now, msg.sender, randNonce))) % 100000000;
    randNonce++;
    uint random2 = uint(keccak256(abi.encodePacked(now, msg.sender, randNonce))) % 100000000;
    code[_email] = random2;
    return random2;
  }
    
  function _verifyStudent(uint _code) private {
    require(keccak256(abi.encodePacked(_code)) == keccak256(abi.encodePacked(code[email[msg.sender)));
    isStudent[msg.sender] = True;
  }
  
  function _isStudent(address _address) public view returns (bool) {
    return isStudent[_address];
  }
  
  function _getNumResponses(address _address) public view returns (uint) {
    return numResponses[_address];
  }
  
  function withdraw(address _address, uint amount) private {
    transfer(_address, amount);
  }
}
