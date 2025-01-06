// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Payment {
    // Payer and recipient details
    address public payer;
    address public recipient;
    uint256 public amount;

    // Country details as ISO codes
    string public payerCountry;
    string public recipientCountry;

    // Mapping of valid ISO codes (example subset for demonstration)
    mapping(string => bool) public validISO;

    constructor() {
        // Initialize a subset of valid ISO country codes (static list for demonstration)
        validISO["US"] = true;
        validISO["SG"] = true;
        validISO["PH"] = true;
        validISO["FR"] = true;
        validISO["DE"] = true;
    }

    /**
     * @dev Function to set up a payment.
     * @param _payer The address of the payer.
     * @param _recipient The address of the recipient.
     * @param _amount The amount to be transferred.
     * @param _payerCountry ISO country code of the payer.
     * @param _recipientCountry ISO country code of the recipient.
     */
    function setPayment(
        address _payer,
        address _recipient,
        uint256 _amount,
        string memory _payerCountry,
        string memory _recipientCountry
    ) public {
        require(validISO[_payerCountry], "Invalid ISO code for payer country");
        require(validISO[_recipientCountry], "Invalid ISO code for recipient country");
        require(_amount > 0, "Amount must be greater than 0");
        
        payer = _payer;
        recipient = _recipient;
        amount = _amount;
        payerCountry = _payerCountry;
        recipientCountry = _recipientCountry;
    }

    /**
     * @dev Function to execute payment (for demonstration purposes, no actual payment logic).
     */
    function executePayment() public view returns (string memory) {
        require(msg.sender == payer, "Only the payer can execute the payment");
        return "Payment executed successfully";
    }
}
