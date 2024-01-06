# implement support vector classifier
# Modified from https://github.com/kazuto1011/svm-pytorch/blob/master/main.py (Kazuto Nakashima) MIT License


import argparse
import matplotlib.pyplot as plt
import numpy as np
import torch
import torch.nn as nn
import torch.optim as optim
from sklearn.datasets import make_blobs
from torch.utils.data import Dataset, DataLoader
from sklearn.datasets import load_breast_cancer
from sklearn.model_selection import train_test_split


def create_model():
    m = nn.Linear(30, 1)
    m.to(args.device)
    return m


def create_data():
    X, Y = make_blobs(n_samples=100, n_features=2, centers=2, random_state=2)
    Y[Y == 0] = -1
    X = torch.tensor(X, dtype=torch.float32)
    Y = torch.tensor(Y, dtype=torch.float32)
    return X, Y


def create_dataset(X, Y):
    class dataset(Dataset):
        def __init__(self, X, Y):
            self.X = X
            self.Y = Y

        def __len__(self):
            return len(self.Y)

        def __getitem__(self, idx):
            return self.X[idx], self.Y[idx]

    trainset = dataset(X, Y)
    return trainset


def train(X, Y, model, args, X_test, y_test):
    optimizer = optim.SGD(model.parameters(), lr=args.lr)
    trainset = create_dataset(X, Y)
    testset = create_dataset(X_test, y_test)

    trainloader = DataLoader(trainset, batch_size=args.batchsize, shuffle=True)
    testloader = DataLoader(testset, batch_size=1, shuffle=False)

    N = len(trainset)
    model.train()

    for epoch in range(args.epoch):
        sum_loss = 0.0
        for t, (x, y) in enumerate(trainloader):
            x_g = x.to(args.device)
            y_g = y.to(args.device)
            output = model(x_g.float()).squeeze()
            weight = model.weight.squeeze()

            # plug in loss function here
            y_output = y_g * output
            minus_zero_mask = (y_output < 0)
            between_zero_one_mask = ((y_output <= 1) & (y_output >= 0))

            loss_minus_zero = (1 - 2 * y_output) * minus_zero_mask
            loss_between_zero_one = (1 - y_output) * between_zero_one_mask

            loss = torch.mean(loss_minus_zero + loss_between_zero_one)
            loss += args.c * (weight.t() @ weight) / 2.0

            optimizer.zero_grad()
            loss.backward()
            optimizer.step()

            sum_loss += float(loss)

        print("Epoch: {:4d}\tloss: {}".format(epoch, sum_loss / N))

    test(model, testloader, testset, 2 / 3., args)
    test(model, testloader, testset, 1 / 2., args)
    test(model, testloader, testset, 1 / 3., args)
    test(model, testloader, testset, 1.0, args)
    test(model, testloader, testset, 0.25, args)
    test(model, testloader, testset, 0.75, args)


def test(model, testloader, testset, rho, args):
    model.eval()
    c = 1 / 3.
    error = 0
    for t, (x, y) in enumerate(testloader):
        x_g = x.to(args.device)
        y_h_x = y * (model(x_g.float()).squeeze())
        if torch.abs(y_h_x) <= rho:
            error += c
        elif y_h_x < -rho:
            error += 1

    error /= len(testset)
    print('test error', error)


def visualize(X, Y, model):
    W = model.weight.squeeze().detach().cpu().numpy()
    b = model.bias.squeeze().detach().cpu().numpy()

    delta = 0.001
    x1 = np.linspace(X[:, 0].min(), X[:, 0].max(), 200)
    x2 = -b / W[1] - W[0] / W[1] * x1
    x2_p = (1 - b) / W[1] - W[0] / W[1] * x1
    x2_m = (-1 - b) / W[1] - W[0] / W[1] * x1

    x1_data = X[:, 0].detach().cpu().numpy()
    x2_data = X[:, 1].detach().cpu().numpy()
    y_data = Y.detach().cpu().numpy()

    x1_c1 = x1_data[np.where(y_data == 1)]
    x1_c2 = x1_data[np.where(y_data == -1)]
    x2_c1 = x2_data[np.where(y_data == 1)]
    x2_c2 = x2_data[np.where(y_data == -1)]

    plt.figure(figsize=(10, 10))
    plt.plot(x1_c1, x2_c1, "P", c="b", ms=10)
    plt.plot(x1_c2, x2_c2, "o", c="r", ms=10)
    plt.plot(x1, x2, "k", lw=3)
    plt.plot(x1, x2_p, "b--", lw=3)
    plt.plot(x1, x2_m, "r--", lw=3)
    plt.tight_layout()
    plt.show()


if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument("--c", type=float, default=0.01)
    parser.add_argument("--lr", type=float, default=0.1)
    parser.add_argument("--batchsize", type=int, default=5)
    parser.add_argument("--epoch", type=int, default=100)
    parser.add_argument("--device", default="cpu", choices=["cpu", "cuda"])
    args = parser.parse_args()
    args.device = torch.device(args.device if torch.cuda.is_available() else "cpu")

    print(args)

    # X, Y = create_data()
    # model = create_model()
    # train(X, Y, model, args)
    # visualize(X, Y, model)

    data = load_breast_cancer()
    X = data.data
    X = (X - X.mean(axis=0)) / X.std(axis=0)
    y = data.target
    y[y == 0] = -1
    X_train, X_test, y_train, y_test = train_test_split(X, y, test_size=0.2, random_state=42)

    model = create_model()
    train(X_train, y_train, model, args, X_test, y_test)
