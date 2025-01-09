import os

# Path to the bash file
bash_script_path = "./script.sh"

# Run the bash file
exit_code = os.system(f"bash run_nlp.sh demo_docs/FinCENgov.pdf")

print("Exit Code:", exit_code)