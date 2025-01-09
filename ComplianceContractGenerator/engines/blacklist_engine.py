import PyPDF2
import nltk
from nltk.tokenize import sent_tokenize
import spacy
import pandas as pd
import torch
from torch.utils.data import DataLoader, Dataset
from transformers import BertTokenizer, BertForSequenceClassification, AdamW
from sklearn.model_selection import train_test_split
from sklearn.metrics import accuracy_score
import pandas as pd
from nltk.corpus import wordnet as wn
import json
import ast


class BlacklistEngine:

    def __init__(self, pdf_file_path: str):
        # Ensure nltk sentence tokenizer is ready
        nltk.download('punkt')
        self.nlp = spacy.load("en_core_web_trf")
        # Open and load the JSON file
        with open('./nlp_models/countrycode.json', 'r') as file:
            self.countrycode = json.load(file)

        nltk.download('wordnet')
        nltk.download('omw-1.4')  # Optional: for multilingual WordNet support

        # Check if GPU is available
        self.device = torch.device("cuda" if torch.cuda.is_available() else "cpu")

        # Load the pre-trained BERT model and tokenizer
        self.tokenizer = BertTokenizer.from_pretrained('bert-base-cased')
        self.model = BertForSequenceClassification.from_pretrained('bert-base-cased', num_labels=2)

        # Load the checkpoint (trained model weights)
        checkpoint_path = './nlp_models/blacklist.pth'
        self.model.load_state_dict(torch.load(checkpoint_path))

        # Move the model to the appropriate device (GPU or CPU)
        self.model = self.model.to(self.device)
        self.model.eval()  # Set the model to evaluation mode

        self.pdf_file_path = pdf_file_path

    @staticmethod
    def _extract_sentences_from_pdf(pdf_path):
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
    
    # Function to make a prediction
    def _predict_sentence(self, sentence):
        # Tokenize the input sentence
        encoding = self.tokenizer.encode_plus(
            sentence,
            add_special_tokens=True,
            max_length=128,
            return_token_type_ids=False,
            padding='max_length',
            truncation=True,
            return_attention_mask=True,
            return_tensors='pt'
        )
        
        # Move input to device
        input_ids = encoding['input_ids'].to(self.device)
        attention_mask = encoding['attention_mask'].to(self.device)
        
        # Perform inference
        with torch.no_grad():
            outputs = self.model(input_ids=input_ids, attention_mask=attention_mask)
            logits = outputs.logits
            _, prediction = torch.max(logits, dim=1)
        
        return prediction.item()  # Return 0 or 1
    
    def extract(self) -> pd.DataFrame:
        # Extract sentences from the PDF
        sentences = self._extract_sentences_from_pdf(self.pdf_file_path)

        # Process each sentence and extract named entities
        sent_ent_list = []
        for sentence in sentences:
            sent_dict = {}
            sent_dict['sent'] = sentence
            sent_dict['ent'] = []
            doc = self.nlp(sentence)
            for ent in doc.ents:
                sent_dict['ent'].append((ent.text, ent.label_))
            sent_ent_list.append(sent_dict)

        # Filter sentences containing specific entity types
        filtered_sent_ent_list = []
        for sent_ent in sent_ent_list:
            for ent in sent_ent['ent']:
                if ent[1] == 'GPE' or ent[1] == 'NORP':
                    filtered_sent_ent_list.append(sent_ent)
                    break

        # Creating a DataFrame
        df = pd.DataFrame(filtered_sent_ent_list)

        return df

    def predict(self) -> list:
        blacklisted_countries = []
        df = self.extract()
        texts = df['sent'].tolist()
        ents = df['ent'].tolist()

        for text, ent in zip(texts, ents):
            blacklist_pred = self._predict_sentence(text)
            if isinstance(ent, str):
                try:
                    ent_list = ast.literal_eval(ent)
                except ValueError:
                    print(f'Error parsing: {ent}')
                    ent_list = []
            else:
                ent_list = ent
            if blacklist_pred == 1:
                for e in ent_list:
                    candidate_syn = wn.synsets(e[0])
                    if candidate_syn == []:
                        continue
                    else:
                        for country in self.countrycode:
                            country_syn = wn.synsets(country.replace(" ", "_"))
                            if country_syn == []:
                                continue
                            else:
                                # Compute path similarity (0 to 1, where 1 means identical)
                                similarity = candidate_syn[0].path_similarity(country_syn[0])
                                if similarity > 0.8:
                                    blacklisted_countries.append(country)
        
        return list(set(blacklisted_countries))