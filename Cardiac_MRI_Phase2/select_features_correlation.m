function [selected, dropped, R] = select_features_correlation(X, featureNames, threshold)
% Greedy redundancy filter. MUST be run on training data only.
if nargin<2||isempty(featureNames), featureNames="Feature "+(1:size(X,2)); end
if nargin<3, threshold=0.90; end
if threshold<=0||threshold>=1, error('threshold must be between 0 and 1.'); end
R=corr(X,'Type','Spearman','Rows','pairwise');
keep=true(1,size(X,2));
for i=1:size(X,2)
    if ~keep(i), continue; end
    for j=i+1:size(X,2)
        if keep(j)&&isfinite(R(i,j))&&abs(R(i,j))>=threshold, keep(j)=false; end
    end
end
selected=string(featureNames(keep)); dropped=string(featureNames(~keep));
end
