function [Xout, state] = handle_missing_features(X, state)
% Median imputation. Fit on training data only; pass returned state to validation/test.
if ~isnumeric(X)||~isreal(X)||ismatrix(X)==false, error('X must be a numeric matrix.'); end
if nargin<2 || isempty(state)
    med=nan(1,size(X,2));
    for j=1:size(X,2)
        v=X(:,j); v=v(isfinite(v));
        if isempty(v), error('Feature column %d is entirely missing/non-finite in training data.',j); end
        med(j)=median(v);
    end
    state=struct('Median',med);
end
if size(X,2)~=numel(state.Median), error('Feature count differs from imputation state.'); end
Xout=double(X);
for j=1:size(Xout,2)
    bad=~isfinite(Xout(:,j));
    Xout(bad,j)=state.Median(j);
end
end
