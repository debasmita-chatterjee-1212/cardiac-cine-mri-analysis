function result = tune_svm(X,Y,kernels,boxGrid,scaleGrid,innerFolds,seed)
% Simple inner-CV grid search for SVM. X must be imputed before call.
if nargin<3||isempty(kernels), kernels={'linear','rbf'}; end
if nargin<4||isempty(boxGrid), boxGrid=[0.1 1 10]; end
if nargin<5||isempty(scaleGrid), scaleGrid={'auto',0.5,1,2}; end
if nargin<6, innerFolds=3; end
if nargin<7, seed=1; end
cv=create_patient_splits(Y,innerFolds,seed); best=-Inf; rows={};
for a=1:numel(kernels), for b=1:numel(boxGrid), for c=1:numel(scaleGrid)
    pred=categorical(strings(numel(Y),1),categories(categorical(Y)));
    for f=1:cv.NumTestSets
        tr=training(cv,f); te=test(cv,f); [xtr,st]=normalise_features(X(tr,:)); xte=normalise_features(X(te,:),st);
        m=train_svm(xtr,Y(tr),kernels{a},boxGrid(b),scaleGrid{c}); pred(te)=predict(m,xte);
    end
    acc=mean(pred==categorical(Y)); rows(end+1,:)={kernels{a},boxGrid(b),string(scaleGrid{c}),acc}; %#ok<AGROW>
    if acc>best, best=acc; bestParams={kernels{a},boxGrid(b),scaleGrid{c}}; end
end,end,end
result=struct('BestParameters',{bestParams},'BestCVAccuracy',best,'GridResults',{rows});
end
