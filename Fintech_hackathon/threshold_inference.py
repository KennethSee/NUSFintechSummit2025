import torch
from torch.utils.data import DataLoader, Dataset
from transformers import BertTokenizer, BertForSequenceClassification, AdamW
from sklearn.model_selection import train_test_split
from sklearn.metrics import accuracy_score
import pandas as pd
import nltk
from nltk.corpus import wordnet as wn
import json
import ast
import argparse

# Argument parsing
parser = argparse.ArgumentParser(description="Process sentences and predict thresholds.")
parser.add_argument('--input_csv', type=str, required=True, help="Path to the input CSV file")
parser.add_argument('--output_txt', type=str, required=True, help="Path to the output TXT file")
args = parser.parse_args()

# Check if GPU is available
device = torch.device("cuda" if torch.cuda.is_available() else "cpu")

# Load the pre-trained BERT model and tokenizer
tokenizer = BertTokenizer.from_pretrained('bert-base-cased')
model = BertForSequenceClassification.from_pretrained('bert-base-cased', num_labels=2)

# Load the checkpoint (trained model weights)
checkpoint_path = './threshold.pth'
model.load_state_dict(torch.load(checkpoint_path))

# Move the model to the appropriate device (GPU or CPU)
model = model.to(device)
model.eval()  # Set the model to evaluation mode

# Function to make a prediction
def predict_sentence(sentence):
    # Tokenize the input sentence
    encoding = tokenizer.encode_plus(
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
    input_ids = encoding['input_ids'].to(device)
    attention_mask = encoding['attention_mask'].to(device)
    
    # Perform inference
    with torch.no_grad():
        outputs = model(input_ids=input_ids, attention_mask=attention_mask)
        logits = outputs.logits
        _, prediction = torch.max(logits, dim=1)
    
    return prediction.item()  # Return 0 or 1

try:
    df = pd.read_csv(args.input_csv)
    texts = df['sent'].tolist()
    ents = df['ent'].tolist()
except:
    raise Exception("No value in CSV. End program with no blacklist.")

thresholds = []

for text, ent in zip(texts, ents):
    threshold_dict = {}
    threshold_pred = predict_sentence(text)
    ent_list = ast.literal_eval(ent)
    if threshold_pred == 1:
        for ent in ent_list:
            if ent[1] == 'MONEY':
                if any(char.isdigit() for char in ent[0]) and "$" in ent[0]:
                    thresholds.append(ent[0])

with open(args.output_txt, "w") as file:
    for item in set(thresholds):
        file.write(f"{item}\n")

print(f"Inferred thresholds have been saved to {args.output_txt}")