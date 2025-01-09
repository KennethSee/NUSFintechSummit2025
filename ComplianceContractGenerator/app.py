import streamlit as st
import subprocess
import os
from contextlib import contextmanager

from engines import ComplianceCodeEngine, BlacklistEngine

TEMP_COUNTRY_EXCLUDED_FILE_NAME = 'temp_country_excluded.pdf'
TEMP_THRESHOLD_FILE_NAME = 'temp_threshold.pdf'

@contextmanager
def change_directory(new_directory):
    # Save the current working directory
    original_directory = os.getcwd()
    try:
        # Change to the new directory
        os.chdir(new_directory)
        yield
    finally:
        # Revert back to the original directory
        os.chdir(original_directory)

st.title('Compliance Contract Generator')

country_exclusion_file = st.file_uploader('Upload country exclusion document', type=['pdf'])
if country_exclusion_file is not None:
    # TO-DO: Read and process the file
    try:
        # Save the uploaded file as a temporary file
        with open(TEMP_COUNTRY_EXCLUDED_FILE_NAME, "wb") as temp_file:
            temp_file.write(country_exclusion_file.getbuffer())
        blacklistEngine = BlacklistEngine(TEMP_COUNTRY_EXCLUDED_FILE_NAME)
        blacklisted_countries = blacklistEngine.predict()
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
            temp_file.write(country_exclusion_file.getbuffer())
        st.success('Transaction threshold document successfully uploaded!')
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