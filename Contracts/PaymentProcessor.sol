// SPDX-License-Identifier: MIT
import "./Countries.sol";
import "./Payment.sol";
import "./Compliance/AbstractCompliance.sol";

pragma solidity ^0.8.0;

contract PaymentProcessor {

    address public countriesContract;
    address public ERC20Contract;
    address public complianceContract;
    address public owner;
    address[] private addressesWithTxns;
    address[] private stagedPayments;
    address[] private paymentsToProcess;
    mapping(address => uint256) private cumulativeTxnVolMapping; // track cumulative transactions for each user
    mapping(address => uint8) private paymentStatusMapping; // track status of staged payment contracts
    mapping(uint8 => string) public statusMapping;

    // Event to emit payment details
    event PaymentStaged(address indexed payer, address indexed recipient, uint256 amount, string status, address indexed paymentContract);

    constructor(address _countriesContract, address _ERC20Contract, address _complianceContract) {
        require(_countriesContract != address(0), "Invalid Countries contract address");
        countriesContract = _countriesContract;
        require(_ERC20Contract != address(0), "Invalid ERC20 contract address");
        ERC20Contract = _ERC20Contract;
        require(_complianceContract != address(0), "Invalid Compliance contract address");
        complianceContract = _complianceContract;

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
        Payment payment = new Payment(_payer, _recipient, _amount, _payerCountry, _recipientCountry, countriesContract, ERC20Contract);

        // run compliance check
        uint8 paymentStatus;
        AbstractCompliance compliance = AbstractCompliance(complianceContract);
        bool hardCheckPass = compliance.hardCheck(_payer, _recipient, _amount, _payerCountry, _recipientCountry, countriesContract);
        bool softCheckPass = compliance.softCheck(_payer, _recipient, _amount, _payerCountry, _recipientCountry, countriesContract);

        if (softCheckPass) {
            paymentStatus = 2;
        }
        else {
            paymentStatus = 1;
        }

        if (!hardCheckPass) {
            paymentStatus = 0;
        }

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
        emit PaymentStaged(_payer, _recipient, _amount, statusMapping[paymentStatus], paymentAddress);
    }

    function executeStagedPayments() public ownerOnly {
        // identify staged payments which are ready for processing
        for (uint256 i = 0; i < stagedPayments.length; i++) {
            address paymentAddress = stagedPayments[i];
            uint8 statusCode = paymentStatusMapping[paymentAddress];
            if (statusCode == 2) {
                paymentsToProcess.push(paymentAddress);
            }
        }

        // execute payments
        for (uint256 j = 0; j < paymentsToProcess.length; j++) {
            address processingPaymentAddress = paymentsToProcess[j];
            delete paymentStatusMapping[processingPaymentAddress];
            for (uint256 k = 0; k < stagedPayments.length; k++) {
                if (stagedPayments[k] == processingPaymentAddress) {
                    // swap and pop
                    stagedPayments[k] = stagedPayments[stagedPayments.length - 1];
                    stagedPayments.pop();
                }
            }

            IPayment payment = IPayment(processingPaymentAddress);
            payment.pay();
        }
        delete paymentsToProcess;
    }

    function clearCumulativeTxns() public ownerOnly {
        for (uint256 i = 0; i < addressesWithTxns.length; i++) {
            delete cumulativeTxnVolMapping[addressesWithTxns[i]];
        }
        delete addressesWithTxns;
    }

    function getPaymentsRequiringManualCheck() public view ownerOnly returns(address[] memory){
        // Count the payments requiring manual checks
        uint256 manualCheckCount = 0;
        for (uint256 i = 0; i < stagedPayments.length; i++) {
            if (paymentStatusMapping[stagedPayments[i]] == 1) {
                manualCheckCount++;
            }
        }

        // Create a memory array to store the addresses
        address[] memory manualCheckPayments = new address[](manualCheckCount);
        uint256 index = 0;
        for (uint256 i = 0; i < stagedPayments.length; i++) {
            if (paymentStatusMapping[stagedPayments[i]] == 1) {
                manualCheckPayments[index] = stagedPayments[i];
                index++;
            }
        }

        return manualCheckPayments;
    }

    function manuallyClearPayment(address _paymentContractAddress) public ownerOnly {
        require(paymentStatusMapping[_paymentContractAddress] == 1, "Payment must be in the 'Require Manual Check' status.");
        paymentStatusMapping[_paymentContractAddress] = 2;
    }

    function getPaymentStatus(address _paymentContractAddress) public view ownerOnly returns(string memory) {
        uint8 statusCode = paymentStatusMapping[_paymentContractAddress];
        string memory status = statusMapping[statusCode];
        return status;
    }
}