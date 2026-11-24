function result = tune_logistic_regression(X,Y,lambdaGrid,innerFolds,seed)
% Inner CV tuning; X must already be imputed. Scaling is fitted within each inner fold.
if nargin<3||isempty(lambdaGrid), lambdaGrid=logspace(-4,1,8); end
if nargin<4, innerFolds=3; end
if nargin<5, seed=1; end
cv=create_patient_splits(Y,innerFolds,seed); scores=nan(numel(lambdaGrid),1);
for g=1:numel(lambdaGrid)
    pred=categorical(strings(numel(Y),1),categories(categorical(Y)));
    for f=1:cv.NumTestSets
        tr=training(cv,f); te=test(cv,f);
        [xtr,st]=normalise_features(X(tr,:)); xte=normalise_features(X(te,:),st);
        m=train_logistic_regression(xtr,Y(tr),lambdaGrid(g)); pred(te)=predict(m,xte);
    end
    scores(g)=mean(pred==categorical(Y));
end
[best,ix]=max(scores); result=struct('BestLambda',lambdaGrid(ix),'CVAccuracy',best,'Grid',lambdaGrid,'Scores',scores);
end
