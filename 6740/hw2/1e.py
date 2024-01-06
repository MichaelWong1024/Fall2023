import numpy as np
import matplotlib.pyplot as plt
from sklearn.base import BaseEstimator, clone
from sklearn.model_selection import train_test_split
from sklearn.datasets import load_breast_cancer


# Perceptron Class
class Perceptron(BaseEstimator):
    def __init__(self, learning_rate=0.01, epochs=100):
        self.learning_rate = learning_rate
        self.epochs = epochs
        self.weights = None
        self.bias = None

    def fit(self, X, y, sample_weight=None):
        n_samples, n_features = X.shape
        self.weights = np.zeros(n_features)
        self.bias = 0
        if sample_weight is None:
            sample_weight = np.ones(n_samples)
        for _ in range(self.epochs):
            for i in range(n_samples):
                linear_output = np.dot(X[i], self.weights) + self.bias
                y_pred = np.where(linear_output >= 0, 1, -1)
                update = self.learning_rate * sample_weight[i] * (y[i] - y_pred)
                self.weights += update * X[i]
                self.bias += update

    def predict(self, X):
        linear_output = np.dot(X, self.weights) + self.bias
        return np.where(linear_output >= 0, 1, -1)


# AdaBoost Class
class AdaBoost:
    def __init__(self, base_estimator, n_estimators=20):
        self.base_estimator = base_estimator
        self.n_estimators = n_estimators
        self.alphas = []
        self.classifiers = []
        self.margins = []
        self.train_accuracies = []
        self.test_accuracies = []

    # def fit(self, X, y, X_test=None, y_test=None):
    #     n_samples, _ = X.shape
    #     w = np.ones(n_samples) / n_samples
    #     for _ in range(self.n_estimators):
    #         classifier = clone(self.base_estimator)
    #         classifier.fit(X, y, sample_weight=w)
    #         y_pred = classifier.predict(X)
    #         err = np.dot(w, (y_pred != y).astype(float))
    #         err = max(err, 1e-10)
    #         alpha = 0.5 * np.log((1 - err) / err)
    #         self.alphas.append(alpha)
    #         self.classifiers.append(classifier)
    #         w *= np.exp(-alpha * y * y_pred)
    #         w /= np.sum(w)
    #         y_train_pred = self.predict(X)
    #         train_accuracy = np.mean(y_train_pred == y)
    #         self.train_accuracies.append(train_accuracy)
    #         if X_test is not None and y_test is not None:
    #             y_test_pred = self.predict(X_test)
    #             test_accuracy = np.mean(y_test_pred == y_test)
    #             self.test_accuracies.append(test_accuracy)
    #         margin = self.compute_margin(X, y)
    #         self.margins.append(margin)
    def fit(self, X, y, X_test=None, y_test=None):
        n_samples, _ = X.shape
        w = np.ones(n_samples) / n_samples
        for _ in range(self.n_estimators):
            classifier = clone(self.base_estimator)
            classifier.fit(X, y, sample_weight=w)
            y_pred = classifier.predict(X)
            err = np.dot(w, (y_pred != y).astype(float))
            err = max(err, 1e-10)  # ensure error is not zero
            alpha = 0.5 * np.log((1 - err) / err)
            self.alphas.append(alpha)
            self.classifiers.append(classifier)
            w *= np.exp(-alpha * y * y_pred)
            w /= np.sum(w)
            y_train_pred = self.predict(X)
            train_accuracy = np.mean(y_train_pred == y)
            self.train_accuracies.append(train_accuracy)
            if X_test is not None and y_test is not None:
                y_test_pred = self.predict(X_test)
                test_accuracy = np.mean(y_test_pred == y_test)
                self.test_accuracies.append(test_accuracy)
            margin = self.compute_margin(X, y)
            self.margins.append(margin)


    def predict(self, X):
        classifier_preds = np.array([classifier.predict(X) for classifier in self.classifiers])
        return np.sign(np.dot(self.alphas, classifier_preds))

    def compute_margin(self, X, y):
        classifier_preds = np.array([classifier.predict(X) for classifier in self.classifiers])
        correct_preds = (classifier_preds == y) * 2 - 1
        margins = np.dot(self.alphas, correct_preds)
        return np.min(np.abs(margins))


# Load the dataset
data = load_breast_cancer()
X = data.data
y = data.target
y = np.where(y == 1, 1, -1)
X_train, X_test, y_train, y_test = train_test_split(X, y, test_size=0.2, random_state=42)

# Training AdaBoost with Perceptron as a weak learner
adaboost = AdaBoost(base_estimator=Perceptron(learning_rate=0.01, epochs=100), n_estimators=40)
adaboost.fit(X_train, y_train, X_test, y_test)

# Plotting the accuracies as a function of the number of iterations
iterations = range(1, adaboost.n_estimators + 1)
plt.figure(figsize=(10, 6))
plt.plot(iterations, adaboost.train_accuracies, label="Training Accuracy")
plt.plot(iterations, adaboost.test_accuracies, label="Test Accuracy")
plt.xlabel("Number of Iterations")
plt.ylabel("Accuracy")
plt.legend()
plt.grid(True)
plt.title("Accuracy (Training and Test) as a function of Number of Iterations")
plt.show()
plt.savefig('accuracy_plot.png')

# Plotting the minimum margin values as a function of the number of iterations
plt.figure(figsize=(10, 6))
plt.plot(iterations, adaboost.margins, label="Minimum Margin Values")
plt.xlabel("Number of Iterations")
plt.ylabel("Minimum Margin Values")
plt.legend()
plt.grid(True)
plt.title("Minimum Margin Values as a function of Number of Iterations")
plt.show()
plt.savefig('minimum_margin_plot.png')