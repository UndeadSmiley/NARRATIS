import sys
import joblib
from sklearn.metrics.pairwise import cosine_similarity

MODEL_PATH = 'models/mathemagic_model.pkl'

def load_model(path=MODEL_PATH):
    return joblib.load(path)


def query(prompt: str):
    model = load_model()
    vect = model['vectorizer'].transform([prompt])
    pred = model['classifier'].predict(vect)[0]
    code = model['codes'][pred]
    return code


if __name__ == '__main__':
    if len(sys.argv) < 2:
        print('Usage: python ml/use_model.py "your prompt"')
        sys.exit(1)
    prompt = ' '.join(sys.argv[1:])
    print(query(prompt))
