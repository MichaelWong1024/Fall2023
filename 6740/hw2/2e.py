import torch
import torch.nn as nn
import torch.optim as optim
from torch.utils.data import DataLoader
import numpy as np
import copy
from sklearn.datasets import load_breast_cancer
from sklearn.model_selection import train_test_split

# Load the breast cancer dataset
data = load_breast_cancer()
X = data.data
y = data.target * 2 - 1  # Convert labels from {0,1} to {-1,1}
X_train, X_test, y_train, y_test = train_test_split(X, y, test_size=0.2, random_state=42)

X_train, Y_train = torch.tensor(X_train), torch.tensor(y_train)
X_test, Y_test = torch.tensor(X_test), torch.tensor(y_test)


# Define the Linear SVM model
class LinearSVM(nn.Module):
    def __init__(self, input_dim):
        super(LinearSVM, self).__init__()
        self.weight = nn.Parameter(torch.randn(input_dim))
        self.bias = nn.Parameter(torch.randn(1))

    def forward(self, x):
        return x @ self.weight + self.bias

# Arguments class for model parameters
# Arguments class for model parameters
class Args:
    lr = 0.01
    epoch = 100  # set number of epochs to 100
    batchsize = 64
    c = 0.1
    rho = 0.1

# Modified training function
def modified_train(X, Y, model, args):
    optimizer = optim.SGD(model.parameters(), lr=args.lr)
    trainset = [(X[i], Y[i]) for i in range(X.shape[0])]
    trainloader = DataLoader(trainset, batch_size=args.batchsize, shuffle=True)
    c = 1/3
    N = len(trainset)
    model.train()
    for epoch in range(args.epoch):
        sum_loss = 0.0
        for t, (x, y) in enumerate(trainloader):
            x_g = x.float()
            y_g = y.float()
            output = model(x_g).squeeze()
            weight = model.weight.squeeze()

            # Modified loss
            loss_1 = torch.mean(torch.clamp(1 - (1 - c) * y_g * output / c, min=0))
            loss_2 = torch.mean(torch.clamp(1 - y_g * output, min=0, max=1))
            loss = loss_1 + loss_2
            loss += args.c * (weight.t() @ weight) / 2.0

            sum_loss += loss.item()

            optimizer.zero_grad()
            loss.backward()
            optimizer.step()

        print("Rho: {:.2f}\tEpoch: {:4d}\tloss: {}".format(args.rho, epoch, sum_loss / N))


# Modified loss evaluation function
def modified_loss_evaluation(X, Y, model, args):
    c = 1/3
    with torch.no_grad():
        output = model(X.float()).squeeze()
        error = 0
        for i, y in enumerate(Y):
            yh = output[i]
            if y * yh < -args.rho:
                error += 1
            elif abs(yh) <= args.rho:
                error += c
    return 100 * error / len(Y)

# Function to perform grid search over rho values
def grid_search_rho(X_train, Y_train, X_test, Y_test, model, args, rho_values):
    best_rho = None
    best_error = float('inf')

    for rho in rho_values:
        args.rho = rho
        model_copy = copy.deepcopy(model)
        modified_train(X_train, Y_train, model_copy, args)
        error = modified_loss_evaluation(X_test, Y_test, model_copy, args)
        print(f"Test error with rho={rho:.2f}: {error:.2f}%")
        
        if error < best_error:
            best_error = error
            best_rho = rho

    return best_rho, best_error

# Initialize model and arguments
input_dim = X_train.shape[1]
model = LinearSVM(input_dim)
args = Args()

# Perform grid search over rho values
rho_values = [i * 0.01 for i in range(1, 100)]
best_rho, best_error = grid_search_rho(X_train, Y_train, X_test, Y_test, model, args, rho_values)
print(f"Best rho: {best_rho:.2f}")
print(f"Test error with best rho: {best_error:.2f}%")
