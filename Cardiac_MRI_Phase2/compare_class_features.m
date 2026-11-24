function summary = compare_class_features(X,Y,featureNames)
% Descriptive class-wise median/IQR and Wilcoxon rank-sum p-values.
if nargin<3||isempty(featureNames), featureNames="Feature "+(1:size(X,2)); end
Y=categorical(Y); cats=categories(Y);
if numel(cats)~=2, error('Exactly two classes required.'); end
p=size(X,2); med1=nan(p,1); med2=nan(p,1); iqr1=nan(p,1); iqr2=nan(p,1); pval=nan(p,1);
for j=1:p
    a=X(Y==cats{1},j); b=X(Y==cats{2},j);
    med1(j)=median(a,'omitnan'); med2(j)=median(b,'omitnan');
    iqr1(j)=iqr(a); iqr2(j)=iqr(b);
    if exist('ranksum','file')==2, pval(j)=ranksum(a,b); end
end
summary=table(string(featureNames(:)),med1,iqr1,med2,iqr2,pval, ...
    'VariableNames',{'Feature','MedianClass1','IQRClass1','MedianClass2','IQRClass2','ExploratoryPValue'});
disp(summary);
end
