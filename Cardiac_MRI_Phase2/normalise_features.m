function [Xout, state] = normalise_features(X, state)
% Z-score scaling. Fit on training data only; apply same state to held-out data.
if ~isnumeric(X)||~isreal(X)||~ismatrix(X), error('X must be a numeric matrix.'); end
if nargin<2 || isempty(state)
    mu=mean(X,1,'omitnan'); sigma=std(X,0,1,'omitnan');
    sigma(~isfinite(sigma)|sigma==0)=1;
    state=struct('Mean',mu,'Std',sigma);
end
if size(X,2)~=numel(state.Mean), error('Feature count differs from scaling state.'); end
Xout=(double(X)-state.Mean)./state.Std;
end
