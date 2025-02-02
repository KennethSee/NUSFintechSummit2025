// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface ICountries {
    function isValidISOCode(string memory _country) external view returns (bool);
    function getISOCode(string memory _countryName) external view returns (string memory);
}

contract Countries {

    struct Country {
        string name;
        string isoCode;
    }

    // Mapping of country names to ISO codes
    mapping(string => string) public countryToISO;

    // List of valid country ISO codes
    string[] public countryISOCodes;

    constructor() {
        Country[194] memory countries = [
            Country("Afghanistan", "AF"),
            Country("Albania", "AL"),
            Country("Algeria", "DZ"),
            Country("Andorra", "AD"),
            Country("Angola", "AO"),
            Country("Antigua and Barbuda", "AG"),
            Country("Argentina", "AR"),
            Country("Armenia", "AM"),
            Country("Australia", "AU"),
            Country("Austria", "AT"),
            Country("Azerbaijan", "AZ"),
            Country("Bahamas", "BS"),
            Country("Bahrain", "BH"),
            Country("Bangladesh", "BD"),
            Country("Barbados", "BB"),
            Country("Belarus", "BY"),
            Country("Belgium", "BE"),
            Country("Belize", "BZ"),
            Country("Benin", "BJ"),
            Country("Bhutan", "BT"),
            Country("Bolivia", "BO"),
            Country("Bosnia and Herzegovina", "BA"),
            Country("Botswana", "BW"),
            Country("Brazil", "BR"),
            Country("Brunei", "BN"),
            Country("Bulgaria", "BG"),
            Country("Burkina Faso", "BF"),
            Country("Burundi", "BI"),
            Country("Cabo Verde", "CV"),
            Country("Cambodia", "KH"),
            Country("Cameroon", "CM"),
            Country("Canada", "CA"),
            Country("Central African Republic", "CF"),
            Country("Chad", "TD"),
            Country("Chile", "CL"),
            Country("China", "CN"),
            Country("Colombia", "CO"),
            Country("Comoros", "KM"),
            Country("Congo (Congo-Brazzaville)", "CG"),
            Country("Congo (DRC)", "CD"),
            Country("Costa Rica", "CR"),
            Country("Croatia", "HR"),
            Country("Cuba", "CU"),
            Country("Cyprus", "CY"),
            Country("Czechia", "CZ"),
            Country("Denmark", "DK"),
            Country("Djibouti", "DJ"),
            Country("Dominica", "DM"),
            Country("Dominican Republic", "DO"),
            Country("Ecuador", "EC"),
            Country("Egypt", "EG"),
            Country("El Salvador", "SV"),
            Country("Equatorial Guinea", "GQ"),
            Country("Eritrea", "ER"),
            Country("Estonia", "EE"),
            Country("Eswatini", "SZ"),
            Country("Ethiopia", "ET"),
            Country("Fiji", "FJ"),
            Country("Finland", "FI"),
            Country("France", "FR"),
            Country("Gabon", "GA"),
            Country("Gambia", "GM"),
            Country("Georgia", "GE"),
            Country("Germany", "DE"),
            Country("Ghana", "GH"),
            Country("Greece", "GR"),
            Country("Grenada", "GD"),
            Country("Guatemala", "GT"),
            Country("Guinea", "GN"),
            Country("Guinea-Bissau", "GW"),
            Country("Guyana", "GY"),
            Country("Haiti", "HT"),
            Country("Honduras", "HN"),
            Country("Hungary", "HU"),
            Country("Iceland", "IS"),
            Country("India", "IN"),
            Country("Indonesia", "ID"),
            Country("Iran", "IR"),
            Country("Iraq", "IQ"),
            Country("Ireland", "IE"),
            Country("Israel", "IL"),
            Country("Italy", "IT"),
            Country("Jamaica", "JM"),
            Country("Japan", "JP"),
            Country("Jordan", "JO"),
            Country("Kazakhstan", "KZ"),
            Country("Kenya", "KE"),
            Country("Kiribati", "KI"),
            Country("Kuwait", "KW"),
            Country("Kyrgyzstan", "KG"),
            Country("Laos", "LA"),
            Country("Latvia", "LV"),
            Country("Lebanon", "LB"),
            Country("Lesotho", "LS"),
            Country("Liberia", "LR"),
            Country("Libya", "LY"),
            Country("Liechtenstein", "LI"),
            Country("Lithuania", "LT"),
            Country("Luxembourg", "LU"),
            Country("Madagascar", "MG"),
            Country("Malawi", "MW"),
            Country("Malaysia", "MY"),
            Country("Maldives", "MV"),
            Country("Mali", "ML"),
            Country("Malta", "MT"),
            Country("Marshall Islands", "MH"),
            Country("Mauritania", "MR"),
            Country("Mauritius", "MU"),
            Country("Mexico", "MX"),
            Country("Micronesia", "FM"),
            Country("Moldova", "MD"),
            Country("Monaco", "MC"),
            Country("Mongolia", "MN"),
            Country("Montenegro", "ME"),
            Country("Morocco", "MA"),
            Country("Mozambique", "MZ"),
            Country("Myanmar", "MM"),
            Country("Namibia", "NA"),
            Country("Nauru", "NR"),
            Country("Nepal", "NP"),
            Country("Netherlands", "NL"),
            Country("New Zealand", "NZ"),
            Country("Nicaragua", "NI"),
            Country("Niger", "NE"),
            Country("Nigeria", "NG"),
            Country("North Korea", "KP"),
            Country("North Macedonia", "MK"),
            Country("Norway", "NO"),
            Country("Oman", "OM"),
            Country("Pakistan", "PK"),
            Country("Palau", "PW"),
            Country("Palestine", "PS"),
            Country("Panama", "PA"),
            Country("Papua New Guinea", "PG"),
            Country("Paraguay", "PY"),
            Country("Peru", "PE"),
            Country("Philippines", "PH"),
            Country("Poland", "PL"),
            Country("Portugal", "PT"),
            Country("Qatar", "QA"),
            Country("Romania", "RO"),
            Country("Russia", "RU"),
            Country("Rwanda", "RW"),
            Country("Saint Kitts and Nevis", "KN"),
            Country("Saint Lucia", "LC"),
            Country("Saint Vincent and the Grenadines", "VC"),
            Country("Samoa", "WS"),
            Country("San Marino", "SM"),
            Country("Sao Tome and Principe", "ST"),
            Country("Saudi Arabia", "SA"),
            Country("Senegal", "SN"),
            Country("Serbia", "RS"),
            Country("Seychelles", "SC"),
            Country("Sierra Leone", "SL"),
            Country("Singapore", "SG"),
            Country("Slovakia", "SK"),
            Country("Slovenia", "SI"),
            Country("Solomon Islands", "SB"),
            Country("Somalia", "SO"),
            Country("South Africa", "ZA"),
            Country("South Korea", "KR"),
            Country("South Sudan", "SS"),
            Country("Spain", "ES"),
            Country("Sri Lanka", "LK"),
            Country("Sudan", "SD"),
            Country("Suriname", "SR"),
            Country("Sweden", "SE"),
            Country("Switzerland", "CH"),
            Country("Syria", "SY"),
            Country("Taiwan", "TW"),
            Country("Tajikistan", "TJ"),
            Country("Tanzania", "TZ"),
            Country("Thailand", "TH"),
            Country("Timor-Leste", "TL"),
            Country("Togo", "TG"),
            Country("Trinidad and Tobago", "TT"),
            Country("Tunisia", "TN"),
            Country("Turkey", "TR"),
            Country("Turkmenistan", "TM"),
            Country("Tuvalu", "TV"),
            Country("Uganda", "UG"),
            Country("Ukraine", "UA"),
            Country("United Arab Emirates", "AE"),
            Country("United Kingdom", "GB"),
            Country("United States", "US"),
            Country("Uruguay", "UY"),
            Country("Uzbekistan", "UZ"),
            Country("Vanuatu", "VU"),
            Country("Vatican City", "VA"),
            Country("Venezuela", "VE"),
            Country("Vietnam", "VN"),
            Country("Yemen", "YE"),
            Country("Zambia", "ZM"),
            Country("Zimbabwe", "ZW")
        ];

        for (uint i = 0; i < 188; i++) {
            countryToISO[countries[i].name] = countries[i].isoCode;
            countryISOCodes.push(countries[i].isoCode);
        }
        
    }

    /**
     * @dev Retrieve the ISO code for a given country name.
     * @param _countryName The name of the country.
     * @return The ISO code of the country.
     */
    function getISOCode(string memory _countryName) public view returns (string memory) {
        return countryToISO[_countryName];
    }

    function isValidISOCode(string memory _countryISOCode) public view returns (bool) {
        for (uint i = 0; i < countryISOCodes.length; i++) {
            if (keccak256(abi.encodePacked(countryISOCodes[i])) == keccak256(abi.encodePacked(_countryISOCode))) {
                return true;
            }
        }

        return false;
    }
}
