function result = select_features_univariate(X,Y,featureNames,k)
% Rank features by absolute standardized mean difference; descriptive ranking only.
% MUST be run on training data only. Does not imply clinical importance.
if nargin<3||isempty(featureNames), featureNames="Feature "+(1:size(X,2)); end
if nargin<4, k=min(5,size(X,2)); end
Y=categorical(Y); cats=categories(Y); if numel(cats)~=2, error('Binary labels required.'); end
score=zeros(1,size(X,2));
for j=1:size(X,2)
    a=X(Y==cats{1},j); b=X(Y==cats{2},j);
    pooled=sqrt((var(a,0,'omitnan')+var(b,0,'omitnan'))/2);
    if pooled>0, score(j)=abs(mean(a,'omitnan')-mean(b,'omitnan'))/pooled; else, score(j)=0; end
end
[sorted,ix]=sort(score,'descend'); k=min(max(1,k),numel(ix));
result=table(string(featureNames(ix(:))),sorted(:),'VariableNames',{'Feature','AbsStandardisedDifference'});
result= result(1:k,:); disp(result);
end
