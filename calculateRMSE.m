function rmse = calculateRMSE(actual, predicted)
    % This function calculates the root mean squared error (RMSE) 
    % between the actual and predicted matrices.

    % Convert matrices to column vectors.
    % actual = actual(:);
    % predicted = predicted(:);

    % Calculate the RMSE.
    rmse = 0;
    for i = 1:size(actual, 1)
        rmse = rmse + (actual(i, 1) - predicted(i, 1))^2 + (actual(i, 2) - predicted(i, 2))^2;
    end
    rmse = sqrt(rmse/size(actual, 1));
end