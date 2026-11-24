function result = tune_random_forest(X,Y,treeGrid,leafGrid,innerFolds,seed)
% Inner-CV grid search for bagged trees. X must be imputed; no scaling required.
if nargin<3||isempty(treeGrid), treeGrid=[50 100 200]; end
if nargin<4||isempty(leafGrid), leafGrid=[1 2 4]; end
if nargin<5, innerFolds=3; end
if nargin<6, seed=1; end
cv=create_patient_splits(Y,innerFolds,seed); best=-Inf; rows={};
for a=1:numel(treeGrid), for b=1:numel(leafGrid)
    pred=categorical(strings(numel(Y),1),categories(categorical(Y)));
    for f=1:cv.NumTestSets
        tr=training(cv,f); te=test(cv,f); m=train_random_forest(X(tr,:),Y(tr),treeGrid(a),leafGrid(b)); pred(te)=predict(m,X(te,:));
    end
    acc=mean(pred==categorical(Y)); rows(end+1,:)={treeGrid(a),leafGrid(b),acc}; %#ok<AGROW>
    if acc>best, best=acc; bestParams=[treeGrid(a),leafGrid(b)]; end
end,end
result=struct('BestParameters',bestParams,'BestCVAccuracy',best,'GridResults',{rows});
end
