import json
import os
import joblib
from sklearn.feature_extraction.text import TfidfVectorizer
from sklearn.neighbors import KNeighborsClassifier


def load_data(path: str):
    """Load training examples from JSON file."""
    with open(path, "r", encoding="utf-8") as f:
        data = json.load(f)
    prompts = [d["prompt"] for d in data]
    codes = [d["code"] for d in data]
    return prompts, codes


def train_model(prompts, codes):
    """Train a simple nearest neighbor model."""
    vectorizer = TfidfVectorizer()
    X = vectorizer.fit_transform(prompts)
    # Each unique code snippet is considered a label
    y = list(range(len(codes)))
    clf = KNeighborsClassifier(n_neighbors=1)
    clf.fit(X, y)
    return vectorizer, clf, codes


def save_model(vectorizer, clf, codes, out_dir="models"):
    os.makedirs(out_dir, exist_ok=True)
    model_path = os.path.join(out_dir, "mathemagic_model.pkl")
    joblib.dump({"vectorizer": vectorizer, "classifier": clf, "codes": codes}, model_path)
    return model_path


if __name__ == "__main__":
    prompts, codes = load_data(os.path.join("ml", "training_data.json"))
    vect, clf, codes = train_model(prompts, codes)
    path = save_model(vect, clf, codes)
    print(f"Model saved to {path}")
