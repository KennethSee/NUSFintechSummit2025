from typing import List, Dict
import textwrap

class ComplianceCodeEngine:

    def __init__(self, contract_name: str, excluded_countries: List[str], threshold: Dict[str, int] = {}):
        self.contract_name = contract_name
        self.excluded_countries = excluded_countries
        self.threshold = threshold

    def generate_contract(self) -> str:
        contract_code = f"""
// SPDX-License-Identifier: MIT
import "./AbstractCompliance.sol";

pragma solidity ^0.8.0;

contract {self.contract_name} is AbstractCompliance {{
    constructor() {{
        startTime = block.timestamp;
    }}

    {textwrap.indent(self._generate_hard_check_func(), '    ')}

    {textwrap.indent(self._generate_soft_check_func(), '    ')}
}}
"""
        return contract_code

    def _generate_soft_check_func(self):
        # Convert Python list of excluded countries to Solidity array
        excluded_countries_array = ', '.join(f'"{country}"' for country in self.excluded_countries)

        # Generate the Solidity code for the softCheck function
        soft_check_function = f"""
function softCheck(
    address _payer,
    address _recipient,
    uint256 _amount,
    string memory _payerCountry,
    string memory _recipientCountry,
    address _countriesContract
) public view override returns (bool) {{
    // Recursive retrieval of value if there is a more recent Compliance contract
    if (nextComplianceContract != address(0)) {{
        AbstractCompliance newCompliance = AbstractCompliance(nextComplianceContract);
        return newCompliance.softCheck(_payer, _recipient, _amount, _payerCountry, _recipientCountry, _countriesContract);
    }}

    // Define excluded countries
    string[] memory excludedCountries = new string[]({len(self.excluded_countries)});
    {''.join(f'excludedCountries[{i}] = "{country}";\n        ' for i, country in enumerate(self.excluded_countries))}

    // Check if either country is in the excluded list
    for (uint256 i = 0; i < excludedCountries.length; i++) {{
        if (
            keccak256(abi.encodePacked(_payerCountry)) == keccak256(abi.encodePacked(excludedCountries[i])) ||
            keccak256(abi.encodePacked(_recipientCountry)) == keccak256(abi.encodePacked(excludedCountries[i]))
        ) {{
            return false;
        }}
    }}

    return true; // Default behavior if not excluded
}}
"""
        return soft_check_function
    
    def _generate_hard_check_func(self):
        # Generate threshold checks for each country
        threshold_checks = []
        for country, limit in self.threshold.items():
            condition = f'if (keccak256(abi.encodePacked(_payerCountry)) == keccak256(abi.encodePacked("{country}"))) {{\n'
            condition += f'        if (_amount > {limit}) {{\n'
            condition += '            return false;\n'
            condition += '        }\n'
            condition += '    }\n'
            threshold_checks.append(condition)

        threshold_logic = "\n".join(threshold_checks)

        # Generate the Solidity code for the hardCheck function
        hard_check_function = f"""
function hardCheck(
    address _payer,
    address _recipient,
    uint256 _amount,
    string memory _payerCountry,
    string memory _recipientCountry,
    address _countriesContract
) public view override returns (bool) {{
    // Recursive retrieval of value if there is a more recent Compliance contract
    if (nextComplianceContract != address(0)) {{
        AbstractCompliance newCompliance = AbstractCompliance(nextComplianceContract);
        return newCompliance.hardCheck(_payer, _recipient, _amount, _payerCountry, _recipientCountry, _countriesContract);
    }}

    // Check thresholds for specific countries
    {threshold_logic}

    return true; // Default behavior if no threshold is exceeded
}}
"""
        return hard_check_function
    