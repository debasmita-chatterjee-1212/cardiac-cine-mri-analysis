function prediction = predict_patient_class(patientFeatures, modelFileOrBundle)
%PREDICT_PATIENT_CLASS Apply a saved Phase 2 model bundle to one patient.
%
% patientFeatures must be a one-row table containing PatientID and the raw
% LV_* predictors. The model bundle stores feature order and preprocessing.
%
% The returned score is the classifier's model score, not a calibrated
% clinical probability.

if istable(patientFeatures)
    if height(patientFeatures) ~= 1
        error('patientFeatures must contain exactly one patient row.');
    end
    if ~ismember('PatientID',patientFeatures.Properties.VariableNames)
        error('patientFeatures table must contain PatientID.');
    end
elseif ~isstruct(patientFeatures)
    error('patientFeatures must be a one-row table or a scalar struct.');
end

if ischar(modelFileOrBundle) || (isstring(modelFileOrBundle) && isscalar(modelFileOrBundle))
    S = load(modelFileOrBundle,'bundle');
    if ~isfield(S,'bundle'), error('MAT file does not contain variable "bundle".'); end
    bundle = S.bundle;
else
    bundle = modelFileOrBundle;
end
required = {'Classifier','InputFeatureNames','SelectedFeatureIndices','ClassNames', ...
            'ImputationState','ScalingState'};
for k=1:numel(required)
    if ~isfield(bundle,required{k}), error('Model bundle missing field %s.',required{k}); end
end

names = bundle.InputFeatureNames;
x = nan(1,numel(names));
for j=1:numel(names)
    nm = names{j};
    if istable(patientFeatures)
        if ~ismember(nm,patientFeatures.Properties.VariableNames)
            error('Patient feature table is missing required feature %s.',nm);
        end
        value = patientFeatures.(nm);
    else
        if ~isfield(patientFeatures,nm), error('Patient structure is missing feature %s.',nm); end
        value = patientFeatures.(nm);
    end
    if ~isnumeric(value) || ~isscalar(value) || ~isreal(value)
        error('Feature %s must be a real numeric scalar.',nm);
    end
    x(j) = double(value);
end
if any(isinf(x)), error('Infinite feature values detected.'); end

[x,~] = handle_missing_features(x,bundle.ImputationState);
[x,~] = normalise_features(x,bundle.ScalingState);
xModel = x(:,bundle.SelectedFeatureIndices);

[predictedLabel,score] = predict(bundle.Classifier,xModel);
classNames = string(bundle.ClassNames);
scoreClassNames = strings(0,1);
try
    scoreClassNames = string(bundle.Classifier.ClassNames);
catch
    % Some model wrappers do not expose ClassNames consistently.
end
if isempty(scoreClassNames)
    scoreClassNames = classNames;
end

prediction = struct();
prediction.PatientID = "";
if istable(patientFeatures), prediction.PatientID = string(patientFeatures.PatientID(1)); end
if isstruct(patientFeatures) && isfield(patientFeatures,'PatientID')
    prediction.PatientID = string(patientFeatures.PatientID);
end
prediction.PredictedLabel = string(predictedLabel);
prediction.ClassNames = classNames;
prediction.Scores = score;
prediction.ScoreClassNames = scoreClassNames;
prediction.InputFeatureNames = names;
prediction.SelectedFeatureNames = names(bundle.SelectedFeatureIndices);
prediction.Interpretation = ['Exploratory model output only; scores are not calibrated ' ...
    'clinical probabilities and must not be used as a clinical diagnosis.'];
end
