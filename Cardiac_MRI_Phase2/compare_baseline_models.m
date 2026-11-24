function models = compare_baseline_models(X,Y)
% Fit three baselines on supplied training data. Scale/impute before calling.
models=struct();
models.Logistic=train_logistic_regression(X,Y);
models.LinearSVM=train_svm(X,Y,'linear');
models.RBFSVM=train_svm(X,Y,'rbf');
models.RandomForest=train_random_forest(X,Y,100,2);
end
