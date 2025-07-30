import pandas as pd
from sklearn.feature_extraction.text import TfidfVectorizer
from sklearn.naive_bayes import MultinomialNB
from sklearn.pipeline import Pipeline
from sklearn.model_selection import train_test_split
from sklearn.metrics import classification_report


def load_data(path: str) -> pd.DataFrame:
    """Load CSV dataset."""
    return pd.read_csv(path)


def build_pipeline():
    return Pipeline([
        ("tfidf", TfidfVectorizer()),
        ("clf", MultinomialNB()),
    ])


def train(path: str = "nlp/narratis_dataset.csv"):
    data = load_data(path)
    X_train, X_test, y_train, y_test = train_test_split(
        data["text"], data["label"], test_size=0.2, random_state=42
    )
    model = build_pipeline()
    model.fit(X_train, y_train)
    predictions = model.predict(X_test)
    print(classification_report(y_test, predictions))
    return model


if __name__ == "__main__":
    train("nlp/narratis_dataset.csv")
