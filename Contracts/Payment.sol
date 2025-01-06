// SPDX-License-Identifier: MIT
import "./Countries.sol";
import "./SimpleERC20.sol";

pragma solidity ^0.8.0;

interface IPayment {
    function pay() external;
}

contract Payment {
    // Payer and recipient details
    address public payer;
    address public recipient;
    uint256 public amount;

    // Country details as ISO codes
    string public payerCountry;
    string public recipientCountry;

    // Address of contracts
    address public countriesContract;
    address public ERC20Contract;

    constructor(address _payer, address _recipient, uint256 _amount, string memory _payerCountry, string memory _recipientCountry, address _countriesContract, address _ERC20Contract) {
        require(_countriesContract != address(0), "Invalid Countries contract address");
        countriesContract = _countriesContract;
        require(_ERC20Contract != address(0), "Invalid ERC20 contract address");
        ERC20Contract = _ERC20Contract;

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

    function pay() external {
        ISimpleERC20 erc20 = ISimpleERC20(ERC20Contract);
        require(erc20.checkBalance(payer) >= amount, "Insufficient balance");
        require(recipient != address(0), "Invalid recipient address");

        erc20.transferFrom(payer, recipient, amount);
    }

}
