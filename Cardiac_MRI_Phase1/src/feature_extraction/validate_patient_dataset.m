function r=validate_patient_dataset(T)
if ~istable(T)||height(T)==0, error('Input must be a non-empty table.'); end
if ~all(ismember({'PatientID','Diagnosis'},T.Properties.VariableNames)), error('Missing PatientID/Diagnosis.'); end
id=string(T.PatientID); dx=string(T.Diagnosis); names=setdiff(T.Properties.VariableNames,{'PatientID','Diagnosis'},'stable');
X=zeros(height(T),numel(names)); for j=1:numel(names), v=T.(names{j}); if ~isnumeric(v)||~isreal(v), error('Non-numeric feature %s.',names{j}); end; X(:,j)=double(v); end
miss=any(isnan(X),2); infs=any(isinf(X),2); dup=false(height(T),1); for i=1:height(T), dup(i)=sum(id==id(i))>1; end
unlab=ismissing(dx)|strlength(strtrim(dx))==0|strcmpi(strtrim(dx),'Unlabelled'); classes=unique(dx(~unlab));
r=struct('NumberOfPatients',height(T),'NumberOfFeatures',numel(names),'MissingFeature',miss,'InfiniteFeature',infs,'DuplicateID',dup, ...
'Unlabelled',unlab,'StructurallyValid',~any(miss|infs|dup|ismissing(id)|strlength(strtrim(id))==0), ...
'ReadyForExploratoryClassification',~any(miss|infs|dup|unlab|ismissing(id))&&numel(classes)==2, ...
'PatientFlags',table(id,dup,miss,infs,unlab,'VariableNames',{'PatientID','DuplicateID','MissingFeature','InfiniteFeature','Unlabelled'}));
r.ClassDistribution=groupcounts(table(dx(~unlab),'VariableNames',{'Diagnosis'}),'Diagnosis');
fprintf('N=%d patients; %d features; missing rows=%d; unlabelled=%d; ready=%d\n',height(T),numel(names),sum(miss),sum(unlab),r.ReadyForExploratoryClassification);
if height(T)<50, warning('Small cohort: classification results are exploratory and uncertain.'); end
end
