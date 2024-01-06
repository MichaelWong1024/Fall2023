import numpy as np
from sklearn.datasets import load_breast_cancer
from sklearn.model_selection import train_test_split
from sklearn.metrics import accuracy_score
from sklearn.linear_model import Perceptron as SKPerceptron

# Load the dataset
data = load_breast_cancer()
X = data.data
y = data.target

# Splitting the dataset into training and test datasets
X_train, X_test, y_train, y_test = train_test_split(X, y, test_size=0.2, random_state=42)

# Custom Perceptron implementation
class CustomPerceptron:
    def __init__(self, max_iter=1000, learning_rate=0.04):
        self.weights = None
        self.max_iter = max_iter
        self.learning_rate = learning_rate

    def fit(self, X, y):
        # Adding bias to the feature matrix
        X = np.concatenate((np.ones((X.shape[0], 1)), X), axis=1)
        # Initializing weights
        self.weights = np.zeros(X.shape[1])
        for _ in range(self.max_iter):
            for i in range(len(X)):
                prediction = 1 if np.dot(X[i], self.weights) >= 0 else 0
                update = self.learning_rate * (y[i] - prediction)
                self.weights += update * X[i]

    def predict(self, X):
        X = np.concatenate((np.ones((X.shape[0], 1)), X), axis=1)
        predictions = np.where(np.dot(X, self.weights) >= 0, 1, 0)
        return predictions


# Training custom perceptron
custom_perceptron = CustomPerceptron()
custom_perceptron.fit(X_train, y_train)

# Predicting and calculating accuracy
custom_predictions = custom_perceptron.predict(X_test)
custom_accuracy = accuracy_score(y_test, custom_predictions)

# Training sklearn Perceptron
sk_perceptron = SKPerceptron(max_iter=1000, tol=1e-3, random_state=42)
sk_perceptron.fit(X_train, y_train)

# Predicting and calculating accuracy
sk_predictions = sk_perceptron.predict(X_test)
sk_accuracy = accuracy_score(y_test, sk_predictions)

# Output the accuracies
print(f"Custom Perceptron Accuracy: {custom_accuracy:.2%}")
print(f"Sklearn Perceptron Accuracy: {sk_accuracy:.2%}")
