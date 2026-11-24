function result = run_integrated_patient(patientID, rootDir, modelFile, ed2, es2, ed4, es4, outputDir)
%RUN_INTEGRATED_PATIENT Run Phase 1 and optionally Phase 2 inference for one patient.
%
% result = run_integrated_patient(patientID,rootDir,modelFile,ed2,es2,ed4,es4,outputDir)
%
% Required Phase 1 functions must be on the MATLAB path. The function calls
% run_phase1_patient, which uses manual ED/ES anchor contours and review.
% Supply [] for an anchor pair to let the Phase 1 function prompt for it.
% If modelFile is empty, image processing and feature extraction run without
% classification. A saved bundle from save_classification_model is required
% for classification.
%
% This is a research workflow, not an automated clinical diagnostic system.

if nargin < 2 || isempty(rootDir), error('Provide the parent directory containing Patient XXXX folders.'); end
if nargin < 3, modelFile = ''; end
if nargin < 4, ed2 = []; end
if nargin < 5, es2 = []; end
if nargin < 6, ed4 = []; end
if nargin < 7, es4 = []; end
if nargin < 8 || isempty(outputDir), outputDir = fullfile(rootDir,'results'); end

% Check Phase 1 entry point.
if exist('run_phase1_patient','file') ~= 2
    error(['run_phase1_patient.m is not on the MATLAB path. Run setup_project ' ...
           'from the integrated project root first.']);
end

fprintf('\n=== CARDIAC MRI INTEGRATED PIPELINE ===\n');
fprintf('Patient: %s\n',string(patientID));
fprintf('Step 1/4: Phase 1 image processing and feature extraction...\n');
phase1Out = run_phase1_patient(patientID,rootDir,ed2,es2,ed4,es4);

fprintf('Step 2/4: Creating standardised patient feature row...\n');
[featureTable,featureNames] = generate_patient_feature_vector(phase1Out);

prediction = [];
if ~isempty(modelFile)
    if ~exist(modelFile,'file'), error('Classifier bundle not found: %s',modelFile); end
    fprintf('Step 3/4: Applying saved classifier...\n');
    prediction = predict_patient_class(featureTable,modelFile);
else
    fprintf('Step 3/4: Classification skipped (no model file supplied).\n');
end

fprintf('Step 4/4: Generating research report...\n');
reportFile = generate_patient_report(phase1Out,featureTable,prediction,outputDir);

result = struct();
result.PatientID = string(patientID);
result.Phase1 = phase1Out;
result.FeatureTable = featureTable;
result.FeatureNames = featureNames;
result.Prediction = prediction;
result.ReportFile = reportFile;
result.CompletedOn = datetime('now');
fprintf('Integrated workflow complete.\n');
end
