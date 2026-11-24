function cv = create_patient_splits(Y,k,seed)
% Stratified K-fold partition. k cannot exceed the smallest class count.
if nargin<2||isempty(k), k=5; end
if nargin<3, seed=1; end
Y=categorical(Y); cats=categories(Y);
if numel(cats)~=2, error('Binary labels required.'); end
counts=arrayfun(@(c)sum(Y==c),categorical(cats));
minCount=min(counts);
if minCount<2, error('Need at least two patients in each class for stratified CV.'); end
if k>minCount, warning('Reducing folds from %d to %d due to minority class size.',k,minCount); k=minCount; end
rng(seed);
cv=cvpartition(Y,'KFold',k);
end
