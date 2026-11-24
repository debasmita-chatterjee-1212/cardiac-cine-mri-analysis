function report = validate_data_splits(cv,patientIDs,Y)
% Check no patient overlap in each train/validation fold and report class counts.
ids=string(patientIDs(:)); Y=categorical(Y(:));
if numel(ids)~=numel(Y), error('Patient ID and label lengths differ.'); end
n=cv.NumTestSets; overlap=false(n,1); foldCounts=cell(n,1);
for f=1:n
    tr=training(cv,f); te=test(cv,f);
    overlap(f)=~isempty(intersect(ids(tr),ids(te)));
    cats=categories(Y);
    c=zeros(numel(cats),2);
    for j=1:numel(cats), c(j,1)=sum(Y(tr)==cats{j}); c(j,2)=sum(Y(te)==cats{j}); end
    foldCounts{f}=table(string(cats),c(:,1),c(:,2),'VariableNames',{'Class','TrainCount','ValidationCount'});
end
report=struct('HasPatientOverlap',any(overlap),'FoldClassCounts',{foldCounts});
if report.HasPatientOverlap, error('Patient leakage detected between train and validation.'); end
end
