function mdl = train_logistic_regression(X,Y,lambda)
% Binary logistic regression with ridge regularisation.
if nargin<3||isempty(lambda), lambda=1e-3; end
Y=categorical(Y); if numel(categories(Y))~=2, error('Binary labels required.'); end
mdl=fitclinear(X,Y,'Learner','logistic','Regularization','ridge','Lambda',lambda,'Solver','lbfgs','ClassNames',categories(Y));
end
