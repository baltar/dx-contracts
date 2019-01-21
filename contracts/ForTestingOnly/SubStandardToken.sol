pragma solidity ^0.5.2;
import "./BadToken.sol";
import "@gnosis.pm/util-contracts/contracts/Math.sol";
import "@gnosis.pm/util-contracts/contracts/Proxy.sol";
import {StandardTokenData} from "@gnosis.pm/util-contracts/contracts/GnosisStandardToken.sol";


/// @title Standard token contract with overflow protection
contract SubStandardToken is BadToken, StandardTokenData {
    using GnosisMath for *;

    /*
     *  Public functions
     */
    /// @dev Transfers sender's tokens to a given address. Returns success
    /// @param to Address of token receiver
    /// @param value Number of tokens to transfer
    /// @return Was transfer successful?
    function transfer(address to, uint value)
        public
    {
        if (    !balances[msg.sender].safeToSub(value) ||
                !balances[to].safeToAdd(value))
            return;
        balances[msg.sender] -= value;
        balances[to] += value;
        emit Transfer(msg.sender, to, value);
    }

    /// @dev Allows allowed third party to transfer tokens from one address to another. Returns success
    /// @param from Address from where tokens are withdrawn
    /// @param to Address to where tokens are sent
    /// @param value Number of tokens to transfer
    /// @return Was transfer successful?
    function transferFrom(address from, address to, uint value)
        public
    {
        if (    !balances[from].safeToSub(value) ||
                !allowances[from][msg.sender].safeToSub(value) ||
                !balances[to].safeToAdd(value))
            return;
        balances[from] -= value;
        allowances[from][msg.sender] -= value;
        balances[to] += value;
        emit Transfer(from, to, value);
    }

    /// @dev Sets approved amount of tokens for spender. Returns success
    /// @param spender Address of allowed account
    /// @param value Number of approved tokens
    /// @return Was approval successful?
    function approve(address spender, uint value)
        public
        returns (bool)
    {
        allowances[msg.sender][spender] = value;
        emit Approval(msg.sender, spender, value);
        return true;
    }

    /// @dev Returns number of allowed tokens for given address
    /// @param owner Address of token owner
    /// @param spender Address of token spender
    /// @return Remaining allowance for spender
    function allowance(address owner, address spender)
        public
        view
        returns (uint)
    {
        return allowances[owner][spender];
    }

    /// @dev Returns number of tokens owned by given address
    /// @param owner Address of token owner
    /// @return Balance of owner
    function balanceOf(address owner)
        public
        view
        returns (uint)
    {
        return balances[owner];
    }

    /// @dev Returns total supply of tokens
    /// @return Total supply
    function totalSupply()
        public
        view
        returns (uint)
    {
        return totalTokens;
    }
}