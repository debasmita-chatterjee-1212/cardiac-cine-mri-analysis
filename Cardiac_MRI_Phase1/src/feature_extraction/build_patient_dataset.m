function T=build_patient_dataset(records,labels)
% One row per patient; optional labels table has PatientID and Diagnosis.
if nargin<2, labels=[]; end
if iscell(records), records=[records{:}]; end
if ~isstruct(records)||isempty(records), error('Provide non-empty feature records.'); end
names={'EDArea','ESArea','FAC','MeanArea','AreaSD','AreaCV','MaxArea','MinArea','AreaRange','MeanAbsAreaChange'};
ids=strings(numel(records),1); X=nan(numel(records),20);
for i=1:numel(records)
 ids(i)=string(records(i).PatientID);
 for v=1:2
  suffix=sprintf('_%dCH',2*v);
  for j=1:10
   fn=['LV_' names{j} suffix];
   if ~isfield(records(i),fn), error('Record missing %s.',fn); end
   X(i,(v-1)*10+j)=double(records(i).(fn));
  end
 end
end
if any(ismissing(ids)|strlength(ids)==0)||numel(unique(ids))~=numel(ids), error('Patient IDs must be present and unique.'); end
vars=cell(1,20); for v=1:2, for j=1:10, vars{(v-1)*10+j}=['LV_' names{j} sprintf('_%dCH',2*v)]; end, end
T=array2table(X,'VariableNames',vars); T=addvars(T,ids,'Before',1,'NewVariableNames','PatientID');
T.Diagnosis=repmat("Unlabelled",height(T),1);
if ~isempty(labels)
 if ~istable(labels)||~all(ismember({'PatientID','Diagnosis'},labels.Properties.VariableNames)), error('Labels table needs PatientID and Diagnosis.'); end
 lid=string(labels.PatientID); dx=string(labels.Diagnosis);
 if numel(unique(lid))~=numel(lid)||any(~ismember(lid,ids)), error('Duplicate or unmatched label IDs.'); end
 [tf,loc]=ismember(ids,lid); T.Diagnosis(tf)=dx(loc(tf));
end
end
