import streamlit as st

from engines import ComplianceCodeEngine

st.title('Compliance Contract Generator')

country_exclusion_file = st.file_uploader('Upload country exclusion document', type=['pdf','doc','docx'])
if country_exclusion_file is not None:
    # TO-DO: Read and process the file
    st.success('Country exclusino document successfully uploaded!')

transaction_threshold_file = st.file_uploader('Upload transaction threshold document', type=['pdf','doc','docx'])
if transaction_threshold_file is not None:
    # TO-DO: Read and process the file
    st.success('Transaction threshold document successfully uploaded!')

generate_button = st.button('Generate contract')
if generate_button:
    if (country_exclusion_file is None) or (transaction_threshold_file is None):
        st.error('Please upload the required files')
    else:
        # TO-DO: Modify code generation input
        compliance_contract_name = 'CompliancePlaceholderName'
        compliance_contract_code = ComplianceCodeEngine(compliance_contract_name, ['IR', 'MR'], 1000).generate_contract()
        st.header('Compliance contract solidity code')
        st.code(compliance_contract_code, language='solidity')