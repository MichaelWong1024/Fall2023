import numpy as np

def my_recommender(rate_mat, lr, with_reg):

    # Hyperparameters
    max_iter = 500
    learning_rate = 0.0001
    reg_coef = 2

    n_user, n_item = rate_mat.shape

    U = np.random.rand(n_user, lr) / lr
    V = np.random.rand(n_item, lr) / lr

    # Create a mask where ratings are non-zero
    obs = rate_mat != 0

    for i in range(max_iter):
        U -= learning_rate * 2 * np.matmul(
            np.multiply(np.matmul(U, np.transpose(V)) - rate_mat, obs), V)
        V -= learning_rate * 2 * np.matmul(
            np.multiply(np.transpose(np.matmul(U, np.transpose(V)) - rate_mat), np.transpose(obs)), U)

        if with_reg:
            U -= learning_rate * 2 * reg_coef * U
            V -= learning_rate * 2 * reg_coef * V

    return U, V
