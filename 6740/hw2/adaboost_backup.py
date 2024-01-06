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

import numpy as np
import matplotlib.pyplot as plt
from sklearn.metrics import accuracy_score

# AdaBoost implementation with Perceptron as a weak learner
class AdaBoost:
    def __init__(self, M):
        self.M = M
        self.alphas = []
        self.models = []

    def fit(self, X, y):
        N, _ = X.shape
        w = np.ones(N) / N
        for m in range(self.M):
            model = CustomPerceptron()
            model.fit(X, y, sample_weight=w)
            yhat = model.predict(X)
            err_m = np.dot(w, yhat != y)
            alpha_m = 0.5 * np.log((1 - err_m) / (err_m + 1e-10))
            w = w * np.exp(-alpha_m * y * yhat)
            w = w / w.sum()
            self.alphas.append(alpha_m)
            self.models.append(model)

    def predict(self, X):
        final_prediction = np.zeros(X.shape[0])
        for alpha, model in zip(self.alphas, self.models):
            final_prediction += alpha * model.predict(X)
        return np.sign(final_prediction)

# Number of iterations
M = 100
adaboost = AdaBoost(M=M)
adaboost.fit(X_train, y_train)

# Plotting accuracy vs number of iterations
train_accuracies = []
test_accuracies = []
for m in range(1, M+1):
    predictions = np.sign(np.sum([
        alpha * model.predict(X_train) 
        for alpha, model in zip(adaboost.alphas[:m], adaboost.models[:m])
    ], axis=0))
    train_accuracies.append(accuracy_score(y_train, predictions))
    
    predictions = np.sign(np.sum([
        alpha * model.predict(X_test) 
        for alpha, model in zip(adaboost.alphas[:m], adaboost.models[:m])
    ], axis=0))
    test_accuracies.append(accuracy_score(y_test, predictions))

plt.figure(figsize=(10, 4))
plt.plot(range(1, M+1), train_accuracies, label="Training Accuracy")
plt.plot(range(1, M+1), test_accuracies, label="Test Accuracy")
plt.xlabel("Number of Iterations")
plt.ylabel("Accuracy")
plt.legend()
plt.show()

# Plotting confidence margin vs number of iterations
confidence_margins = []
for m in range(1, M+1):
    margin = np.sum([
        alpha * model.predict(X_train) 
        for alpha, model in zip(adaboost.alphas[:m], adaboost.models[:m])
    ], axis=0)
    confidence_margins.append(np.mean(margin))

plt.figure(figsize=(10, 4))
plt.plot(range(1, M+1), confidence_margins)
plt.xlabel("Number of Iterations")
plt.ylabel("Confidence Margin")
plt.show()
