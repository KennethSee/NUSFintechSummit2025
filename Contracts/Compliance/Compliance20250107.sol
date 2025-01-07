// SPDX-License-Identifier: MIT
import "./AbstractCompliance.sol";

pragma solidity ^0.8.0;

contract Compliance20250107 is AbstractCompliance {

    function softCheck(address _payer, address _recipient, uint256 _amount, string memory _payerCountry, string memory _recipientCountry, address _countriesContract) public view override returns (bool) {
        return false;
    }

    function hardCheck(address _payer, address _recipient, uint256 _amount, string memory _payerCountry, string memory _recipientCountry, address _countriesContract) public view override returns (bool) {
        return true;
    }

}