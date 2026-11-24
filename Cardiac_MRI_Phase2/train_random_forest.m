function mdl = train_random_forest(X,Y,numTrees,minLeaf)
% Bagged decision trees (Random Forest-style ensemble).
if nargin<3||isempty(numTrees), numTrees=100; end
if nargin<4||isempty(minLeaf), minLeaf=2; end
Y=categorical(Y); if numel(categories(Y))~=2, error('Binary labels required.'); end
t=templateTree('MinLeafSize',minLeaf);
mdl=fitcensemble(X,Y,'Method','Bag','NumLearningCycles',numTrees,'Learners',t,'ClassNames',categories(Y));
end
