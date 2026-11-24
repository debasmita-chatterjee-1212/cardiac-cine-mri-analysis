function result = select_features_model_based(X,Y,featureNames,numTrees)
% Permutation importance from a bagged-tree model. MUST be run on training data only.
if nargin<3||isempty(featureNames), featureNames="Feature "+(1:size(X,2)); end
if nargin<4, numTrees=100; end
mdl=fitcensemble(X,Y,'Method','Bag','NumLearningCycles',numTrees,'Learners','Tree');
imp=predictorImportance(mdl);
[imp,ix]=sort(imp,'descend');
result=table(string(featureNames(ix(:))),imp(:),'VariableNames',{'Feature','Importance'});
end
