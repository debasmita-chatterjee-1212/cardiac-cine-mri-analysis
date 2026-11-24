function bundle = save_classification_model(classifier, inputFeatureNames, classNames, ...
    imputationState, scalingState, selectedFeatureNames, outputFile, metadata)
%SAVE_CLASSIFICATION_MODEL Save a classifier and its complete preprocessing contract.
%
% bundle = save_classification_model(classifier,inputFeatureNames,classNames,...
%     imputationState,scalingState,selectedFeatureNames,outputFile,metadata)
%
% inputFeatureNames: ordered raw feature names expected from Phase 1.
% selectedFeatureNames: subset/order actually used to train classifier.
% imputationState: output state from handle_missing_features on TRAINING data.
% scalingState: output state from normalise_features on imputed TRAINING data.
%
% IMPORTANT: The classifier must have been trained using exactly the selected
% features in selectedFeatureNames, after applying these same preprocessing
% states. Never fit preprocessing on the full dataset before cross-validation.

if nargin < 7 || isempty(outputFile)
    outputFile = 'cardiac_mri_classifier.mat';
end
if nargin < 8 || isempty(metadata)
    metadata = struct();
end
inputFeatureNames = cellstr(string(inputFeatureNames));
classNames = cellstr(string(classNames));
if isempty(selectedFeatureNames)
    selectedFeatureNames = inputFeatureNames;
else
    selectedFeatureNames = cellstr(string(selectedFeatureNames));
end
if numel(unique(inputFeatureNames)) ~= numel(inputFeatureNames)
    error('Input feature names must be unique.');
end
if ~all(ismember(selectedFeatureNames,inputFeatureNames))
    error('Selected feature names must be a subset of inputFeatureNames.');
end
if numel(classNames) ~= 2
    error('Exactly two class names are required.');
end
if ~isstruct(imputationState) || ~isfield(imputationState,'Median') || ...
   ~isstruct(scalingState) || ~all(isfield(scalingState,{'Mean','Std'}))
    error('Valid imputation and scaling states are required.');
end
if numel(imputationState.Median) ~= numel(inputFeatureNames) || ...
   numel(scalingState.Mean) ~= numel(inputFeatureNames) || ...
   numel(scalingState.Std) ~= numel(inputFeatureNames)
    error('Preprocessing state dimensions do not match inputFeatureNames.');
end
if isempty(classifier)
    error('A fitted classifier is required.');
end

bundle = struct();
bundle.Classifier = classifier;
bundle.InputFeatureNames = inputFeatureNames;
bundle.SelectedFeatureNames = selectedFeatureNames;
bundle.SelectedFeatureIndices = find(ismember(inputFeatureNames,selectedFeatureNames));
% Preserve the caller's selected feature order, not input order.
[~,bundle.SelectedFeatureIndices] = ismember(selectedFeatureNames,inputFeatureNames);
bundle.ClassNames = classNames;
bundle.ImputationState = imputationState;
bundle.ScalingState = scalingState;
bundle.Metadata = metadata;
bundle.CreatedOn = datetime('now');
bundle.BundleVersion = '1.0';

outDir = fileparts(outputFile);
if ~isempty(outDir) && ~exist(outDir,'dir'), mkdir(outDir); end
save(outputFile,'bundle','-v7.3');
fprintf('Saved classifier bundle: %s\n',outputFile);
end
