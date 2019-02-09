pragma solidity ^0.5.2;


import "../../openzeppelin-solidity/contracts/ownership/Ownable.sol";

/// @title BlackList
/// @dev Smart contract to enable blacklisting of token holders. 
contract BlackList is Ownable {

    mapping (address => bool) public blacklist;

    event AddedBlackList(address user);
    event RemovedBlackList(address user);


    /// @dev terminate transaction if any of the participants is blacklisted
    /// @param _from - user initiating process
    /// @param _to  - user involved in process
    modifier isNotBlacklisted(address _from, address _to) {
        require(!blacklist[_from], "User is blacklisted");
        require(!blacklist[_to], "User is blacklisted");
        _;
    }

    /// @dev check if user has been black listed
    /// @param _user - usr to check
    /// @return true or false
    function isBlacklisted(address _user) public view returns (bool) {
        return blacklist[_user];
    }
    
    /// @dev add user to black list
    /// @param _user to blacklist
    function addBlackList (address _user) public onlyOwner {
        blacklist[_user] = true;
        emit AddedBlackList(_user);
    }

    /// @dev remove user from black list
    /// @param _user - user to be removed from black list
    function removeBlackList (address _user) public onlyOwner {
        blacklist[_user] = false;
        emit RemovedBlackList(_user);
    }

}