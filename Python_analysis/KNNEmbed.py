import numpy as np
import faiss

class KNNEmbed:
    def __init__(self, k=5):
        self.index = None
        self.y = None
        self.k = k

    def fit(self, X, y):
        self.index = faiss.IndexFlatL2(X.shape[1])
        self.index.add(X.astype(np.float32))
        self.y = y

    def predict(self, X):
        print("Predicting")
        distances, indices = self.index.search(X.astype(np.float32), k=self.k)
        votes = self.y[indices]
        print(votes)
        predictions = np.mean(votes, axis=1)
        # predictions = np.array([np.argmax(np.bincount(x)) for x in votes])
        return predictions