function T = analyse_model_coefficients(model,featureNames)
% Report coefficients for a fitted binary linear classifier where available.
if nargin<2||isempty(featureNames), error('Supply feature names in model input order.'); end
if ~isprop(model,'Beta')||isempty(model.Beta), error('Model does not expose linear Beta coefficients.'); end
b=double(model.Beta(:));
if numel(b)~=numel(featureNames), error('Feature count does not match coefficient count.'); end
T=table(string(featureNames(:)),b,abs(b),'VariableNames',{'Feature','Coefficient','AbsoluteCoefficient'});
T=sortrows(T,'AbsoluteCoefficient','descend'); disp(T);
end
