matrix = weights_fused_sumc';
matrixs = standardize(matrix);
matrixinv = pinv(matrixs);