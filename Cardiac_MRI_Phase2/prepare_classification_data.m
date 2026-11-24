function D = prepare_classification_data(T, featureNames)
% Prepare patient-level predictor matrix, labels and IDs.
% Default predictors: numeric columns beginning LV_.
if ~istable(T) || height(T)<1, error('Input must be a non-empty patient-level table.'); end
required={'PatientID','Diagnosis'};
if ~all(ismember(required,T.Properties.VariableNames)), error('Table needs PatientID and Diagnosis.'); end
ids=string(T.PatientID); if any(ismissing(ids)|strlength(strtrim(ids))==0), error('Missing PatientID.'); end
if numel(unique(ids))~=numel(ids), error('PatientID values must be unique (one row per patient).'); end
if nargin<2 || isempty(featureNames)
    vars=T.Properties.VariableNames;
    featureNames=vars(startsWith(vars,'LV_'));
end
if isempty(featureNames), error('No predictor columns selected.'); end
if any(ismember(featureNames,required)), error('PatientID/Diagnosis cannot be predictors.'); end
if ~all(ismember(featureNames,T.Properties.VariableNames)), error('Unknown feature column requested.'); end
X=zeros(height(T),numel(featureNames));
for j=1:numel(featureNames)
    v=T.(featureNames{j});
    if ~isnumeric(v)||~isreal(v)||~isvector(v), error('Feature %s must be a real numeric column.',featureNames{j}); end
    X(:,j)=double(v(:));
end
[Y,classNames]=encode_diagnosis_labels(T.Diagnosis);
if numel(classNames)~=2, error('Expected exactly two diagnosis classes; found %d.',numel(classNames)); end
if any(isinf(X(:))), error('Infinite predictors detected. Resolve them before modelling.'); end
D=struct('X',X,'Y',Y,'PatientIDs',ids,'FeatureNames',{featureNames}, ...
    'ClassNames',classNames,'N',height(T),'P',size(X,2));
end
