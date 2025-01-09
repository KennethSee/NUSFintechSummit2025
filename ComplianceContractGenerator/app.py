import streamlit as st
import subprocess

from engines import ComplianceCodeEngine, BlacklistEngine, ThresholdEngine

TEMP_COUNTRY_EXCLUDED_FILE_NAME = 'temp_country_excluded.pdf'
TEMP_THRESHOLD_FILE_NAME = 'temp_threshold.pdf'

if 'thresholds' not in st.session_state:
    st.session_state['thresholds'] = {}

if 'processed_country_file' not in st.session_state:
    st.session_state['processed_country_file'] = None

if 'processed_threshold_file' not in st.session_state:
    st.session_state['processed_threshold_file'] = None


st.title('Compliance Contract Generator')

st.header('Country Exclusion Document Upload')
country_exclusion_file = st.file_uploader('Upload country exclusion document', type=['pdf'])
if country_exclusion_file is not None:
    if st.session_state['processed_country_file'] != country_exclusion_file.name:
        try:
            with st.status('Analyzing document...'):
                # Save the uploaded file as a temporary file
                st.write('Parsing file...')
                with open(TEMP_COUNTRY_EXCLUDED_FILE_NAME, "wb") as temp_file:
                    temp_file.write(country_exclusion_file.getbuffer())
                # Run Blacklist engine
                st.write('Identifying blacklisted countries...')
                blacklist_engine = BlacklistEngine(TEMP_COUNTRY_EXCLUDED_FILE_NAME)
                blacklisted_countries = blacklist_engine.predict()
            st.success('Country exclusino document successfully uploaded!')
            st.write(f'Blacklisted countries: {", ".join(blacklisted_countries)}')
        except Exception as e:
            st.error(f'Error saving file: {e}')

st.header('Transaction Threshold Document Upload')
country_code = st.text_input('Country Code', max_chars=2)
transaction_threshold_file = st.file_uploader('Upload transaction threshold document', type=['pdf'])
if transaction_threshold_file is not None:
    if st.session_state['processed_threshold_file'] != transaction_threshold_file.name:
        try:
            with st.status('Analyzing document...'):
                # Save the uploaded file as a temporary file
                st.write('Parsing file...')
                with open(TEMP_THRESHOLD_FILE_NAME, "wb") as temp_file:
                    temp_file.write(transaction_threshold_file.getbuffer())
                # Run Threshold engine
                st.write('Predicting threshold...')
                threshold_engine = ThresholdEngine(TEMP_THRESHOLD_FILE_NAME)
                threshold = threshold_engine.predict()
            st.success('Transaction threshold document successfully uploaded!')
            st.session_state['thresholds'][country_code] = threshold
        except Exception as e:
            st.error(f'Error saving file: {e}')
        
    if 'thresholds' in st.session_state:
        st.write(st.session_state['thresholds'])


generate_button = st.button('Generate contract')
if generate_button:
    if (country_exclusion_file is None) or (transaction_threshold_file is None):
        st.header('Compliance Contract')
        st.error('Please upload the required files')
    else:
        compliance_contract_name = 'CompliancePlaceholderName'
        compliance_contract_code = ComplianceCodeEngine(compliance_contract_name, blacklisted_countries, st.session_state['thresholds']).generate_contract()
        st.header('Compliance contract solidity code')
        st.code(compliance_contract_code, language='solidity')