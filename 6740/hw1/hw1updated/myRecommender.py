
import numpy as np

def my_recommender(rate_mat, lr, with_reg):
    """
    :param rate_mat:
    :param lr:
    :param with_reg:
        boolean flag, set true for using regularization and false otherwise
    :return:
    """

    # Hyperparameters
    max_iter = 400
    learning_rate = 5e-5
    reg_coef = 2 if with_reg else 0

    n_user, n_item = rate_mat.shape

    U = np.random.rand(n_user, lr)
    V = np.random.rand(n_item, lr)

    # Create a mask where ratings are non-zero
    mask = np.ma.masked_where(rate_mat == 0, rate_mat).mask

    for iter in range(max_iter):
        error_matrix = rate_mat - np.dot(U, V.T)
        error_matrix = np.multiply(error_matrix, mask)  # Element-wise multiplication with mask

        # Update U and V matrices using matrix operations
        U += learning_rate * (2 * np.dot(error_matrix, V) - 2 * reg_coef * U)
        V += learning_rate * (2 * np.dot(error_matrix.T, U) - 2 * reg_coef * V)

    return U, V
