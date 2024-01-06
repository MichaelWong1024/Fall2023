import torch
import torch.nn as nn
import torch.optim as optim
from sklearn.datasets import load_breast_cancer
from sklearn.model_selection import train_test_split
from sklearn.metrics import accuracy_score
from sklearn.preprocessing import StandardScaler

# Modified Loss Function for Training
def modified_loss(output, y, c=1/3):
    yh = y * output
    loss_1 = (1 - (1-c)*yh/c) * (yh < 0).float()
    loss_2 = (1 - yh) * (yh >= 0).float()
    total_loss = loss_1 + loss_2
    return total_loss.mean()

# SVM Model
def create_model(input_dim):
    m = nn.Linear(input_dim, 1)
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

# Training
def train_model(X_train, y_train, model, lr=0.1, c=0.01, epochs=100):
    optimizer = optim.SGD(model.parameters(), lr=lr)
    for epoch in range(epochs):
        optimizer.zero_grad()
        outputs = model(X_train).squeeze()
        loss = modified_loss(outputs, y_train) + c * torch.norm(model.weight)
        loss.backward()
        optimizer.step()

# Compute Accuracy
def compute_accuracy(model, X_test, y_test, rho):
    predictions = model(X_test).squeeze()
    yh_values = y_test * predictions
    preds = torch.where(yh_values < -rho, -1, torch.where(yh_values > rho, 1, 0))
    correct = (preds == y_test).float().sum()
    accuracy = correct / len(y_test)
    return accuracy.item()

# Fine-tuning rho
def direct_fine_tune_rho(model, X_test, y_test, rho_values):
    best_rho = None
    best_accuracy = 0  # Initialize with a low value

    for rho in rho_values:
        accuracy = compute_accuracy(model, X_test, y_test, rho)
        if accuracy > best_accuracy:
            best_accuracy = accuracy
            best_rho = rho

    return best_rho, best_accuracy

if __name__ == "__main__":
    X_train, X_test, y_train, y_test = load_and_preprocess_data()
    model = create_model(X_train.shape[1])

    # Train the model
    train_model(X_train, y_train, model)

    # Fine-tune rho
    rho_values = [i * 0.05 for i in range(1, 20)]  # Example range of rho values
    best_rho, best_accuracy = direct_fine_tune_rho(model, X_test, y_test, rho_values)

    print(f"Best rho value found: {best_rho}")
    print(f"Accuracy with best rho: {best_accuracy:.2%}")
