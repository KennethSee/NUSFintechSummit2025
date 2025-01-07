// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

abstract contract AbstractCompliance {
    function softCheck(address _payer, address _recipient, uint256 _amount, string memory _payerCountry, string memory _recipientCountry, address _countriesContract) public view virtual returns (bool);
    function hardCheck(address _payer, address _recipient, uint256 _amount, string memory _payerCountry, string memory _recipientCountry, address _countriesContract) public view virtual returns (bool);
}