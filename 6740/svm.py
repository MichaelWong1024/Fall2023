import argparse
import numpy as np
import torch
import torch.nn as nn
import torch.optim as optim
from sklearn.datasets import load_breast_cancer
from sklearn.model_selection import train_test_split
from sklearn.metrics import accuracy_score
from sklearn.preprocessing import StandardScaler
from torch.utils.data import Dataset, DataLoader

# Modified Loss Function
def modified_loss(output, y, rho, c=1/3):
    yh = y * output
    loss_1 = (1 - (1-c)*yh/c) * (yh < -rho).float()
    loss_2 = (1 - yh) * ((yh >= -rho) & (yh <= rho)).float()
    total_loss = loss_1 + loss_2
    return total_loss.mean()

# SVM Model
def create_model(input_dim):
    m = nn.Linear(input_dim, 1)
    m.to(args.device)
    return m

# Data loading and preprocessing
def load_and_preprocess_data():
    data = load_breast_cancer()
    X = data.data
    y = data.target * 2 - 1  # Convert labels to +1 and -1
    
    # Splitting and normalization
    X_train, X_test, y_train, y_test = train_test_split(X, y, test_size=0.2, random_state=42)
    scaler = StandardScaler()
    X_train = scaler.fit_transform(X_train)
    X_test = scaler.transform(X_test)
    
    X_train = torch.tensor(X_train, dtype=torch.float32)
    y_train = torch.tensor(y_train, dtype=torch.float32)
    X_test = torch.tensor(X_test, dtype=torch.float32)
    y_test = torch.tensor(y_test, dtype=torch.float32)
    
    return X_train, X_test, y_train, y_test

# Dataset
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

# Training
def train_modified(X, Y, model, args, rho, c=1/3):
    optimizer = optim.SGD(model.parameters(), lr=args.lr)
    trainset = create_dataset(X, Y)
    trainloader = DataLoader(trainset, batch_size=args.batchsize, shuffle=True)
    N = len(trainset)
    model.train()
    for epoch in range(args.epoch):
        sum_loss = 0.0
        for t, (x, y) in enumerate(trainloader):
            x_g = x.to(args.device)
            y_g = y.to(args.device)
            output = model(x_g).squeeze()
            weight = model.weight.squeeze()
            loss = modified_loss(output, y_g, rho, c)
            loss += args.c * (weight.t() @ weight) / 2.0
            optimizer.zero_grad()
            loss.backward()
            optimizer.step()
            sum_loss += float(loss)
        print(f"Epoch: {epoch:4d} | Loss: {sum_loss / N:.4f}")

# Evaluation
def evaluate(model, X, Y):
    with torch.no_grad():
        predictions = model(X).squeeze()
        predictions = torch.sign(predictions).cpu().numpy()
        accuracy = accuracy_score(Y.cpu().numpy(), predictions)
    return accuracy

# Main
if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument("--c", type=float, default=0.01)
    parser.add_argument("--lr", type=float, default=0.1)
    parser.add_argument("--batchsize", type=int, default=10)
    parser.add_argument("--epoch", type=int, default=100)
    parser.add_argument("--device", default="cpu", choices=["cpu", "cuda"])
    parser.add_argument("--rho", type=float, default=0.5)
    args = parser.parse_args()
    args.device = torch.device(args.device if torch.cuda.is_available() else "cpu")

    X_train, X_test, y_train, y_test = load_and_preprocess_data()
    model = create_model(X_train.shape[1])
    train_modified(X_train, y_train, model, args, args.rho)

    train_accuracy = evaluate(model, X_train, y_train)
    test_accuracy = evaluate(model, X_test, y_test)

    print(f"Train Accuracy: {train_accuracy:.2%}")
    print(f"Test Accuracy: {test_accuracy:.2%}")
