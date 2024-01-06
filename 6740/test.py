import argparse
import numpy as np
import torch
import torch.nn as nn
import torch.optim as optim
from sklearn.datasets import load_breast_cancer
from sklearn.model_selection import train_test_split
from torch.utils.data import Dataset, DataLoader

def modified_loss(output, y, c=1/3):
    condition1 = (1 - (1-c)*y*output/c)
    condition2 = (1 - y*output)
    loss = torch.where(y * output < 0, condition1, 
                       torch.where((y * output >= 0) & (y * output <= 1), condition2, 0.0))
    return torch.mean(loss)

def create_model():
    m = nn.Linear(X_train.shape[1], 1)
    m.to(args.device)
    return m

def create_dataset(X, Y):
    class dataset(Dataset):
        def __init__(self, X, Y):
            self.X = X
            self.Y = Y
        def __len__(self):
            return len(self.Y)
        def __getitem__(self, idx):
            return self.X[idx], self.Y[idx]
    trainset = dataset(X,Y)
    return trainset

def compute_test_error(model, X_test, Y_test, rho):
    with torch.no_grad():
        predictions = model(X_test).squeeze()
        yh = Y_test * predictions
        
        # Diagnostic prints
        print(f"Number of yh < -rho: {(yh < -rho).sum()}")
        print(f"Number of yh > rho: {(yh > rho).sum()}")
        print(f"Number of -rho <= yh <= rho: {(yh >= -rho).sum() - (yh > rho).sum()}")
        
        costs = torch.where(yh < -rho, 1.0, 
                            torch.where(yh > rho, 0.0, 
                                        torch.where((yh >= -rho) & (yh <= rho), 1/3, 0.0)))
        return torch.mean(costs)


def train(X, Y, model, args):
    X, Y = X.to(args.device), Y.to(args.device)
    optimizer = optim.SGD(model.parameters(), lr=args.lr)
    trainset = create_dataset(X, Y)
    trainloader = DataLoader(trainset, batch_size=args.batchsize, shuffle=True)
    model.train()

    for epoch in range(args.epoch):
        for t, (x, y) in enumerate(trainloader):
            x_g = x.to(args.device)
            y_g = y.to(args.device)
            output = model(x_g).squeeze()
            weight = model.weight.squeeze()

            loss = modified_loss(output, y_g) + args.c * (weight.t() @ weight) / 2.0
            optimizer.zero_grad()
            loss.backward()
            optimizer.step()

    # Evaluate test error for specified rho values
    rho_values = [1, 3/4, 1/2, 1/4]
    for rho in rho_values:
        error = compute_test_error(model, X_test, y_test, rho)
        print(f"Rho: {rho}, Test Error: {error:.5f}")

if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument("--c", type=float, default=0.01)
    parser.add_argument("--lr", type=float, default=0.1)
    parser.add_argument("--batchsize", type=int, default=5)
    parser.add_argument("--epoch", type=int, default=100)
    parser.add_argument("--device", default="cuda", choices=["cpu", "cuda"])
    args = parser.parse_args()
    args.device = torch.device(args.device if torch.cuda.is_available() else "cpu")

    print(args)

    # Load the breast cancer dataset
    data = load_breast_cancer()
    X = data.data
    y = data.target
    X = torch.tensor(X, dtype=torch.float32)
    y = torch.tensor(y, dtype=torch.float32) * 2 - 1  # Convert to +1/-1 format

    # Splitting the dataset into training and test datasets
    X_train, X_test, y_train, y_test = train_test_split(X, y, test_size=0.2, random_state=42)
    X_train, X_test = X_train.to(args.device), X_test.to(args.device)
    y_train, y_test = y_train.to(args.device), y_test.to(args.device)

    model = create_model()
    train(X_train, y_train, model, args)
