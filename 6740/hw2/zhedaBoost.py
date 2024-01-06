import numpy as np
from perceptron import myPerceptron
from sklearn.datasets import load_breast_cancer
from sklearn.model_selection import train_test_split
from sklearn.metrics import accuracy_score
import matplotlib.pyplot as plt

def invokeWL(X_train, y_train, D):
    model = myPerceptron()
    model.fitWithSampleWeight(X_train, y_train, D)
    return model

def computeError(D, X_train, y_train, WL):
    y_pred = WL.predict(X_train)
    error = np.dot(D, (y_pred != y_train).astype(np.float64))
    return error

def computeW(error):
    return 1/2 * np.log((1 / error) - 1)

def getNormalizeFactor(error):
    return 2 * np.sqrt(error * (1 - error))

def updateD(D, w, X_train, y_train, WL, error):
    nextD = np.zeros(D.shape[0])
    y_pred = WL.predict(X_train)
    for i in range(D.shape[0]):
        nextD[i] = D[i] * np.exp(-w * y_train[i] * y_pred[i])
    nextD /= nextD.sum()
    return nextD

def createData():
    data = load_breast_cancer()
    X = data.data
    y = data.target

    for i in range(y.shape[0]):
        if y[i] == 0:
            y[i] = -1

    X_train, X_test, y_train, y_test = train_test_split(X, y, test_size=0.2, random_state=42)
    return X_train, X_test, y_train, y_test

class AdaBoost:

    def __init__(self) -> None:
        self.T = None
        self.Ws = []
        self.D = []
        self.hs = []
        self.training_accuracy = []
        self.test_accuracy = []
        self.errors_t = []
        self.errors_t_minus_1 = []
        self.minhx = []

    def misclassification_rate(self, X, y, t):

        if t > len(self.hs) or t <= 0:
            return None, None

        indices = np.random.choice(len(y), size=len(y), replace=True)
        X_sampled = X[indices]
        y_sampled = y[indices]

        predictions_t = self.hs[t - 1].predict(X_sampled)
        misclassified_t = np.mean(predictions_t != y_sampled)

        if t > 1:
            predictions_t_minus_1 = self.hs[t - 2].predict(X_sampled)
            misclassified_t_minus_1 = np.mean(predictions_t_minus_1 != y_sampled)
        else:
            misclassified_t_minus_1 = None

        return misclassified_t, misclassified_t_minus_1

    def fit(self, X_train, y_train, T):
        self.T = T
        self.D.append(np.ones(len(y_train)) / len(y_train))
        
        for t in range(0, T):
            ft = invokeWL(X_train, y_train, self.D[t])
            error = computeError(self.D[t], X_train, y_train, ft)
            w = computeW(error)
            self.Ws.append(w)
            nextD = updateD(self.D[t], w, X_train, y_train, ft, error)
            self.D.append(nextD)

            if (t >= 1):
                sum1 = 0
                y_pred = ft.predict(X_train)
                for i in range(len(y_train)):
                    if y_pred[i] * y_train[i] < 0:
                        sum1 += nextD[i]

                self.errors_t.append(sum1)

                sum2 = 0
                y_pred = self.hs[-1].predict(X_train)
                for i in range(len(y_train)):
                    if y_pred[i] * y_train[i] < 0:
                        sum2 += nextD[i]

                self.errors_t_minus_1.append(sum2)

            self.hs.append(ft)

            curr_train_pred = self.currPredict(X_train, y_train, t)
            curr_test_pred = self.currPredict(X_test, y_test, t)

            margin = np.min(np.abs(curr_train_pred))
            self.minhx.append(margin)

            curr_train_pred = np.sign(curr_train_pred)
            curr_test_pred = np.sign(curr_test_pred)
            curr_train_accuracy = accuracy_score(curr_train_pred, y_train)
            curr_test_accuracy = accuracy_score(curr_test_pred, y_test)

            self.training_accuracy.append(curr_train_accuracy)
            self.test_accuracy.append(curr_test_accuracy)

    def currPredict(self, X, y, t):
        train_pred = np.zeros(X.shape[0])
        for i in range(t):
            train_pred += self.Ws[i] * self.hs[i].predict(X)

        return train_pred


X_train, X_test, y_train, y_test = createData()
model = AdaBoost()
model.fit(X_train, y_train, 50)

print(model.errors_t)
print(model.errors_t_minus_1)
training_accuracy = model.training_accuracy
test_accuracy = model.test_accuracy
margin = model.minhx

plt.figure(figsize=(10,5))
plt.plot(training_accuracy)
plt.hlines(0.5, 0, 50, colors = 'red', linestyles='dashed')
plt.title('Training accuracy by AdaBoost')
plt.xlabel('Iteration')
plt.show()

plt.figure(figsize=(10,5))
plt.plot(test_accuracy)
plt.hlines(0.5, 0, 50, colors = 'red', linestyles='dashed')
plt.title('Test accuracy by AdaBoost')
plt.xlabel('Iteration')
plt.show()

plt.figure(figsize=(10,5))
plt.plot(margin)
plt.hlines(0, 0, 50, colors = 'red', linestyles='dashed')
plt.title('Confidence margin')
plt.xlabel('Iteration')
plt.show()

plt.figure(figsize=(10,5))
plt.plot(range(1, model.T), model.errors_t, label="εt")
plt.plot(range(1, model.T), model.errors_t_minus_1, label="εt-1")
plt.xlabel("Iteration")
plt.ylabel("Error Rate")
plt.legend()
plt.show()
