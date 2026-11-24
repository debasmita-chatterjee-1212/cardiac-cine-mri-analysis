function R = analyse_feature_correlations(X, featureNames, method)
% Correlation matrix for EDA. Compute on a clearly defined cohort subset.
if nargin<2||isempty(featureNames), featureNames="Feature "+(1:size(X,2)); end
if nargin<3, method='Spearman'; end
if any(~isfinite(X(:))), warning('Non-finite values present; pairwise rows are used.'); end
R=corr(X,'Type',method,'Rows','pairwise');
figure('Color','w'); h=heatmap(string(featureNames),string(featureNames),R);
h.Title=method+" feature correlation"; h.ColorLimits=[-1 1];
end
