// SPDX-License-Identifier: MIT
import "./Countries.sol";

pragma solidity ^0.8.0;

interface IPayment {
    function pay() external payable;
}

contract Payment {
    // Payer and recipient details
    address public payer;
    address public recipient;
    uint256 public amount;

    // Country details as ISO codes
    string public payerCountry;
    string public recipientCountry;

    // Address of the Countries contract
    address public countriesContract;

    constructor(address _payer, address _recipient, uint256 _amount, string memory _payerCountry, string memory _recipientCountry, address _countriesContract) {
        require(_countriesContract != address(0), "Invalid Countries contract address");
        countriesContract = _countriesContract;

        // check that countries are valid ISO codes
        ICountries countries = ICountries(countriesContract);
        require(countries.isValidISOCode(_payerCountry), "Invalid payer country ISO code");
        require(countries.isValidISOCode(_recipientCountry), "Invalid recipient country ISO code");

        payer = _payer;
        recipient = _recipient;
        amount = _amount;
        payerCountry = _payerCountry;
        recipientCountry = _recipientCountry;
    }

    function pay() external payable {
        require(msg.sender == payer, "Only the payer can initiate payment");
        require(msg.value == amount, "Incorrect payment amount");
        require(recipient != address(0), "Invalid recipient address");

        // TO-DO: Compliance checks will go here

        payable(recipient).transfer(msg.value);
    }

}
