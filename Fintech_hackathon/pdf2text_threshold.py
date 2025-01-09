import PyPDF2
import nltk
from nltk.tokenize import sent_tokenize
import spacy
import pandas as pd
import argparse  # Importing argparse for command-line argument parsing

# Ensure nltk sentence tokenizer is ready
nltk.download('punkt')
nlp = spacy.load("en_core_web_trf")

def extract_sentences_from_pdf(pdf_path):
    # Open the PDF file
    with open(pdf_path, 'rb') as file:
        reader = PyPDF2.PdfReader(file)
        text = ''
        
        # Extract text from each page
        for page in reader.pages:
            text += page.extract_text() + ' '

    # Tokenize the text into sentences, removing newlines
    sentences = [sent.replace('\n', ' ') for sent in sent_tokenize(text)]
    
    return sentences

def main(pdf_file_path):
    # Extract sentences from the PDF
    sentences = extract_sentences_from_pdf(pdf_file_path)

    # Process each sentence and extract named entities
    sent_ent_list = []
    for sentence in sentences:
        sent_dict = {}
        sent_dict['sent'] = sentence
        sent_dict['ent'] = []
        doc = nlp(sentence)
        for ent in doc.ents:
            sent_dict['ent'].append((ent.text, ent.label_))
        sent_ent_list.append(sent_dict)

    # Filter sentences containing specific entity types
    filtered_sent_ent_list = []
    for sent_ent in sent_ent_list:
        for ent in sent_ent['ent']:
            if ent[1] == 'MONEY':
                filtered_sent_ent_list.append(sent_ent)
                break

    # Creating a DataFrame
    df = pd.DataFrame(filtered_sent_ent_list)

    # Exporting to CSV
    file_path = './output/sentences_with_entities_threshold.csv'
    df.to_csv(file_path, index=False, encoding='utf-8')
    print(f"Exported results to {file_path}")

if __name__ == "__main__":
    # Set up argument parsing
    parser = argparse.ArgumentParser(description="Extract sentences and named entities from a PDF file.")
    parser.add_argument('--file', type=str, required=True, help="Path to the PDF file")

    args = parser.parse_args()  # Parse the command-line arguments

    # Call the main function with the provided file path
    main(args.file)