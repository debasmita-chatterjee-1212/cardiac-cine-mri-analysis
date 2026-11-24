function result = extract_feature_importance(model,featureNames,method)
% Extract predictor importance from supported tree ensembles or linear models.
if nargin<3||isempty(method), method='auto'; end
if nargin<2||isempty(featureNames), error('Supply feature names in model input order.'); end
imp=[];
if isprop(model,'PredictorImportance') && ~isempty(model.PredictorImportance)
    imp=model.PredictorImportance;
elseif isprop(model,'Beta') && ~isempty(model.Beta)
    imp=abs(model.Beta(:))';
elseif isprop(model,'Trained') && ~isempty(model.Trained)
    try, imp=predictorImportance(model); catch, end
end
if isempty(imp), error('Importance unavailable for this model type; use coefficients or permutation importance.'); end
imp=double(imp(:)); if numel(imp)~=numel(featureNames), error('Feature name count mismatch.'); end
[imp,ix]=sort(imp,'descend');
result=table(string(featureNames(ix(:))),imp,'VariableNames',{'Feature','Importance'});
end
