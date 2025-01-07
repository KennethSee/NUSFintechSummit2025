// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

abstract contract AbstractCompliance {
    uint256 public startTime;
    uint256 public endTime;
    address public previousComplianceContract;
    address public nextComplianceContract;
    
    function setPreviousComplianceContract(address _previous) external virtual {
        previousComplianceContract = _previous;
    }

    function addNewComplianceContract(address _newComplianceContractAddress) public virtual {
        AbstractCompliance newComplianceContract = AbstractCompliance(_newComplianceContractAddress);
        require(newComplianceContract.startTime() > startTime, "New compliance contract must start later than this.");

        endTime = block.timestamp;
        nextComplianceContract = _newComplianceContractAddress;
        newComplianceContract.setPreviousComplianceContract(address(this));
    }

    function getLatestComplianceContract() public view virtual returns(address) {
        address latestContract;
        if (nextComplianceContract != address(0)) {
            AbstractCompliance complianceContract = AbstractCompliance(nextComplianceContract);
            latestContract = complianceContract.getLatestComplianceContract();
        }
        else {
            latestContract = address(this);
        }
        return latestContract;
    }

    function softCheck(
        address _payer,
        address _recipient,
        uint256 _amount,
        string memory _payerCountry,
        string memory _recipientCountry,
        address _countriesContract
    ) public view virtual returns (bool);

    function hardCheck(
        address _payer,
        address _recipient,
        uint256 _amount,
        string memory _payerCountry,
        string memory _recipientCountry,
        address _countriesContract
    ) public view virtual returns (bool);

}
