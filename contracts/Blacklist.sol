pragma solidity ^0.5.2;


import "../../openzeppelin-solidity/contracts/ownership/Ownable.sol";

/// @title BlackList
/// @dev Smart contract to enable blacklisting of token holders. 
contract BlackList is Ownable {

    mapping (address => bool) public blacklist;

    event AddedBlackList(address user);
    event RemovedBlackList(address user);


    modifier isNotBlacklisted(address _from, address _to) {
        require(!blacklist[_from], "User is blacklisted");
        require(!blacklist[_to], "User is blacklisted");
        _;
    }

    function isBlacklisted(address _maker) public view returns (bool) {
        return blacklist[_maker];
    }
    
    function addBlackList (address _evilUser) public onlyOwner {
        blacklist[_evilUser] = true;
        emit AddedBlackList(_evilUser);
    }

    function removeBlackList (address _clearedUser) public onlyOwner {
        blacklist[_clearedUser] = false;
        emit RemovedBlackList(_clearedUser);
    }

}