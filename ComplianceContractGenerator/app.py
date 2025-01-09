import streamlit as st
import subprocess

from engines import ComplianceCodeEngine, BlacklistEngine, ThresholdEngine

TEMP_COUNTRY_EXCLUDED_FILE_NAME = 'temp_country_excluded.pdf'
TEMP_THRESHOLD_FILE_NAME = 'temp_threshold.pdf'


st.title('Compliance Contract Generator')

country_exclusion_file = st.file_uploader('Upload country exclusion document', type=['pdf'])
if country_exclusion_file is not None:
    try:
        # Save the uploaded file as a temporary file
        with open(TEMP_COUNTRY_EXCLUDED_FILE_NAME, "wb") as temp_file:
            temp_file.write(country_exclusion_file.getbuffer())
        # Run Blacklist engine
        blacklist_engine = BlacklistEngine(TEMP_COUNTRY_EXCLUDED_FILE_NAME)
        blacklisted_countries = blacklist_engine.predict()
        st.success('Country exclusino document successfully uploaded!')
        st.write(f'Blacklisted countries: {", ".join(blacklisted_countries)}')
    except Exception as e:
        st.error(f'Error saving file: {e}')

transaction_threshold_file = st.file_uploader('Upload transaction threshold document', type=['pdf'])
if transaction_threshold_file is not None:
    # TO-DO: Read and process the file
    try:
        # Save the uploaded file as a temporary file
        with open(TEMP_THRESHOLD_FILE_NAME, "wb") as temp_file:
            temp_file.write(transaction_threshold_file.getbuffer())
        # Run Threshold engine
        threshold_engine = ThresholdEngine(TEMP_THRESHOLD_FILE_NAME)
        threshold = threshold_engine.predict()
        st.success('Transaction threshold document successfully uploaded!')
        st.write(threshold)
    except Exception as e:
        st.error(f'Error saving file: {e}')


generate_button = st.button('Generate contract')
if generate_button:
    if (country_exclusion_file is None) or (transaction_threshold_file is None):
        st.error('Please upload the required files')
    else:
        # TO-DO: Modify code generation input
        compliance_contract_name = 'CompliancePlaceholderName'
        compliance_contract_code = ComplianceCodeEngine(compliance_contract_name, ['IR', 'MR'], {'SG': 20000, 'US': 15000}).generate_contract()
        st.header('Compliance contract solidity code')
        st.code(compliance_contract_code, language='solidity')