import numpy as np

def my_recommender(rate_mat, lr, with_reg):

    max_iter = 250
    learning_rate = 0.0001
    reg_coef = 2 if with_reg else 0

    n_user, n_item = rate_mat.shape

    U = np.random.rand(n_user, lr)
    V = np.random.rand(n_item, lr)

    mask = np.ma.masked_where(rate_mat != 0, rate_mat).mask

    for i in range(max_iter):
        U -= learning_rate * 2 * np.matmul(np.multiply(np.matmul(U, np.transpose(V)) - rate_mat, mask), V)
        V -= learning_rate * 2 * np.matmul(np.multiply(np.transpose(np.matmul(U, np.transpose(V)) - rate_mat), np.transpose(mask)), U)

        U -= learning_rate * 2 * reg_coef * U
        V -= learning_rate * 2 * reg_coef * V

    return U, V