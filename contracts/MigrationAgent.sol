pragma solidity ^0.5.2;

/// @title Migration Agent interface
contract MigrationAgent {

    function migrateFrom(address _from, uint256 _value) public;
}