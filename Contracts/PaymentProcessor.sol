// SPDX-License-Identifier: MIT
import "./Countries.sol";
import "./Payment.sol";

pragma solidity ^0.8.0;

contract PaymentProcessor {

    address public countriesContract;
    address public owner;
    address[] private addressesWithTxns;
    address[] private stagedPayments;
    mapping(address => uint256) private cumulativeTxnVolMapping; // track cumulative transactions for each user
    mapping(address => uint8) private paymentStatusMapping; // track status of staged payment contracts
    mapping(uint8 => string) public statusMapping;

    // Event to emit payment details
    event PaymentStaged(address indexed payer, address indexed recipient, uint256 amount, string status);

    constructor(address _countriesContract) {
        require(_countriesContract != address(0), "Invalid Countries contract address");
        countriesContract = _countriesContract;

        // assing status mapping
        statusMapping[0] = "Failed";
        statusMapping[1] = "Manual Compliance Check Required";
        statusMapping[2] = "Ready for Processing";
        statusMapping[3] = "Success";

        owner = msg.sender; // Set the contract creator as the owner
    }

    modifier ownerOnly() {
        require(msg.sender == owner, "Only the owner can perform this action");
        _;
    }

    function stagePayment(address _payer, address _recipient, uint256 _amount, string memory _payerCountry, string memory _recipientCountry) public ownerOnly {
        // check that countries are valid ISO codes
        ICountries countries = ICountries(countriesContract);
        require(countries.isValidISOCode(_payerCountry), "Invalid payer country ISO code");
        require(countries.isValidISOCode(_recipientCountry), "Invalid recipient country ISO code");

        // create payment contract
        Payment payment = new Payment(_payer, _recipient, _amount, _payerCountry, _recipientCountry, countriesContract);

        // run compliance check
        // TO-DO
        uint8 paymentStatus = 2;

        // stage the payment
        address paymentAddress = address(payment);
        paymentStatusMapping[paymentAddress] = paymentStatus;
        stagedPayments.push(paymentAddress);

        // add to cumulative amount
        if (cumulativeTxnVolMapping[_payer] == 0) {
            addressesWithTxns.push(_payer);
        }
        cumulativeTxnVolMapping[_payer] += _amount;

        // Emit payment details
        emit PaymentStaged(_payer, _recipient, _amount, statusMapping[paymentStatus]);
    }

    function executeStagedPayments() public ownerOnly {

    }

    function clearCumulativeTxns() public ownerOnly {
        for (uint256 i = 0; i < addressesWithTxns.length; i++) {
            delete cumulativeTxnVolMapping[addressesWithTxns[i]];
        }
        delete addressesWithTxns;
    }
}