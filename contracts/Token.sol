pragma solidity ^0.5.2;


import "../../openzeppelin-solidity/contracts/lifecycle/Pausable.sol";
import "../../openzeppelin-solidity/contracts/token/ERC20/ERC20Detailed.sol";
import "../../openzeppelin-solidity/contracts/token/ERC20/ERC20Burnable.sol";
import "../../openzeppelin-solidity/contracts/token/ERC20/ERC20Capped.sol";
import "../../openzeppelin-solidity/contracts/ownership/Ownable.sol";
import "./MigrationAgent.sol";
import "./Blacklist.sol";



/**
 * @title Token
 * @dev No tokens are minted during the deployment.
 * Note they can later distribute these tokens as they wish using `transfer` and other
 * `ERC20` functions.
 */
contract Token is Pausable, ERC20Detailed, ERC20Capped, Ownable, ERC20Burnable, BlackList {
    uint8 public constant DECIMALS = 18;    
    uint256 public constant MAX_SUPPLY = 5000000000 * (10 ** uint256(DECIMALS));
    address public migrationAgent;
    uint256 public totalMigrated;

    event Migrate(address indexed from, address indexed to, uint256 value);
    event BlacklistedFundsBurned(address indexed from, uint256 value);

    /// @dev prevent accidental sending of tokens to this token contract
    /// @param _self - address of this contract
    modifier notSelf(address _self) {
        require(_self != address(this), "You are trying to send tokens to token contract");
        _;
    }

    /// @dev Constructor which initiates name, ticker and max supply for the token. 
    constructor () public ERC20Detailed("CannDollar", "CDAG", DECIMALS) ERC20Capped(MAX_SUPPLY) {           
    }
   

    /// @notice Migrate tokens to the new token contract.
    /// @param _value The amount of token to be migrated
    function migrate(uint256 _value) external whenNotPaused() {       
        require(migrationAgent != address(0), "Enter migration agent address");
        
        // Validate input value.
        require(_value > 0, "Amount of tokens is required");
        require(_value <= balanceOf(msg.sender), "You entered more tokens than available");
       
        burn(balanceOf(msg.sender));
        totalMigrated += _value;
        MigrationAgent(migrationAgent).migrateFrom(msg.sender, _value);
        emit Migrate(msg.sender, migrationAgent, _value);
    }

    /// @notice Set address of migration target contract and enable migration
    /// process.
    /// @param _agent The address of the MigrationAgent contract
    function setMigrationAgent(address _agent) external onlyOwner() {        
        
        require(migrationAgent == address(0), "Migration agent can't be 0");       
        migrationAgent = _agent;
    }

    /// @notice burns funds of blacklisted user
    /// @param _blacklistedUser The address of user who is blacklisted
    function burnBlacklistedFunds (address _blacklistedUser) public onlyOwner {
        require(blacklist[_blacklistedUser], "These user is not blacklisted");
        uint dirtyFunds = balanceOf(_blacklistedUser);
        _burn(_blacklistedUser, dirtyFunds);        
        emit BlacklistedFundsBurned(_blacklistedUser, dirtyFunds);
    }

    /// @notice Overwrite parent implementation to add blacklisted modifier
    function transfer(address to, uint256 value) public 
                                                    isNotBlacklisted(msg.sender, to) 
                                                    notSelf(to) 
                                                    returns (bool) {
        return super.transfer(to, value);
    }

    /// @notice Overwrite parent implementation to add blacklisted and notSelf modifiers
    function transferFrom(address from, address to, uint256 value) public 
                                                                    isNotBlacklisted(from, to) 
                                                                    notSelf(to) 
                                                                    returns (bool) {
        return super.transferFrom(from, to, value);
    }

    /// @notice Overwrite parent implementation to add blacklisted and notSelf modifiers
    function approve(address spender, uint256 value) public 
                                                        isNotBlacklisted(msg.sender, spender) 
                                                        notSelf(spender) 
                                                        returns (bool) {
        return super.approve(spender, value);
    }

    /// @notice Overwrite parent implementation to add blacklisted and notSelf modifiers
    function increaseAllowance(address spender, uint addedValue) public 
                                                                isNotBlacklisted(msg.sender, spender) 
                                                                notSelf(spender) 
                                                                returns (bool success) {
        return super.increaseAllowance(spender, addedValue);
    }

    /// @notice Overwrite parent implementation to add blacklisted and notSelf modifiers
    function decreaseAllowance(address spender, uint subtractedValue) public 
                                                                        isNotBlacklisted(msg.sender, spender) 
                                                                        notSelf(spender) 
                                                                        returns (bool success) {
        return super.decreaseAllowance(spender, subtractedValue);
    }

    /// @notice Overwrite parent implementation to add blacklisted check and notSelf modifiers
    function mint(address to, uint256 value) public onlyOwner() notSelf(to) returns (bool) {       

        require(!isBlacklisted(to), "User is blacklisted"); 
        return super.mint(to, value);
    }
    
}