// SPDX-License-Identifier: MIT
import "./AbstractCompliance.sol";

pragma solidity ^0.8.0;

contract Compliance20250107 is AbstractCompliance {
    constructor() {
        startTime = block.timestamp;
    }

    function softCheck(
        address _payer,
        address _recipient,
        uint256 _amount,
        string memory _payerCountry,
        string memory _recipientCountry,
        address _countriesContract
    ) public view override returns (bool) {
        // Recursive retrieval of value if there is a more recent Compliance contract
        if (nextComplianceContract != address(0)) {
            AbstractCompliance newCompliance = AbstractCompliance(nextComplianceContract);
            return newCompliance.softCheck(_payer, _recipient, _amount, _payerCountry, _recipientCountry, _countriesContract);
        }
        return false; // Default behavior if nextComplianceContract is not set
    }

    function hardCheck(
        address _payer,
        address _recipient,
        uint256 _amount,
        string memory _payerCountry,
        string memory _recipientCountry,
        address _countriesContract
    ) public view override returns (bool) {
        // Recursive retrieval of value if there is a more recent Compliance contract
        if (nextComplianceContract != address(0)) {
            AbstractCompliance newCompliance = AbstractCompliance(nextComplianceContract);
            return newCompliance.hardCheck(_payer, _recipient, _amount, _payerCountry, _recipientCountry, _countriesContract);
        }
        return false; // Default behavior if nextComplianceContract is not set
    }
}
