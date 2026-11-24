# Cardiac MRI Study — Phase 3 Integrated MATLAB Modules (Codes 37–42)

Phase 3 connects the existing Phase 1 image-processing workflow to a saved Phase 2 classifier.
It is a research integration layer, not a clinically validated diagnostic system.

## Included modules

| Code | File | Purpose |
|---:|---|---|
| 37 | `src/pipeline/run_integrated_patient.m` | Run Phase 1, create features, optionally classify, and write a report |
| 38 | `src/feature_extraction/generate_patient_feature_vector.m` | Convert Phase 1 feature structure into a one-row table |
| 39 | `src/classification/save_classification_model.m` | Save classifier with feature order and preprocessing states |
| 40 | `src/classification/predict_patient_class.m` | Apply the saved model to one patient |
| 41 | `src/reporting/generate_patient_report.m` | Write a text report and MAT results file |
| 42 | `src/pipeline/validate_complete_pipeline.m` | Check structural consistency of one patient's outputs |

## Important compatibility note

The Phase 1 `extract_lv_features.m` produces fields such as `EDArea_2CH` and
`FAC_4CH`. The Phase 1 `build_patient_dataset.m` adds the `LV_` prefix in its
table columns (for example `LV_EDArea_2CH`). Module 38 deliberately maps the
Phase 1 feature structure to those same `LV_` table column names.

## Project setup

1. Extract the complete project package so that the folders `Cardiac_MRI_Phase1`,
   `Cardiac_MRI_Phase2`, and `Cardiac_MRI_Phase3` are together.
2. Copy the Phase 3 `src` contents into the common project `src` tree, or use the
   integrated package's folder structure.
3. In MATLAB, set the Current Folder to the project root and run:

```matlab
addpath(genpath(fullfile(pwd,'Cardiac_MRI_Phase1','src')));
addpath(genpath(fullfile(pwd,'Cardiac_MRI_Phase2')));
addpath(genpath(fullfile(pwd,'Cardiac_MRI_Phase3','src')));
```

If you have merged the folders into one common `src` tree, simply run:

```matlab
addpath(genpath(fullfile(pwd,'src')));
```

## Run image processing and feature extraction only

```matlab
result = run_integrated_patient( ...
    '0912', ...
    'E:\YOUR_DATA_PARENT_FOLDER', ...
    '', ...       % no classifier yet
    2, 11, ...    % 2CH ED and ES frame indices (example only)
    3, 12);       % 4CH ED and ES frame indices (example only)
```

The Phase 1 entry point uses manual anchor contours and review dialogs.
The frame numbers above are examples only; choose and verify phases for each subject.
Use `[]` for a phase argument to let Phase 1 prompt for it.

## Train and save a model bundle for later inference

The model bundle must be built from training-only preprocessing states. For example,
inside a training fold after selecting features:

```matlab
[Ximp, impState] = handle_missing_features(Xtrain);
[Xscaled, scaleState] = normalise_features(Ximp);
selectedNames = D.FeatureNames(selectedIdx);

mdl = train_svm(Xscaled(:,selectedIdx), Ytrain, 'linear', 1, 'auto');

bundle = save_classification_model( ...
    mdl, D.FeatureNames, D.ClassNames, ...
    impState, scaleState, selectedNames, ...
    fullfile(pwd,'results','svm_model_bundle.mat'));
```

This snippet assumes `Xtrain`, `Ytrain`, `D.FeatureNames`, `D.ClassNames`, and
`selectedIdx` have been created correctly for the training fold. The saved model
is suitable for applying the same learned transformation to new patients, but
the final model for deployment-like use should be retrained on the full labelled
development cohort only after model selection and internal validation are complete.
Document the training cohort and validation procedure in `metadata`.

## Run the complete patient workflow with a saved model

```matlab
result = run_integrated_patient( ...
    '0912', ...
    'E:\YOUR_DATA_PARENT_FOLDER', ...
    fullfile(pwd,'results','svm_model_bundle.mat'), ...
    2, 11, 3, 12);

qc = validate_complete_pipeline( ...
    result.Phase1, result.FeatureTable, ...
    fullfile(pwd,'results','svm_model_bundle.mat'));
disp(qc);
```

The integrated run saves the Phase 1 MAT output in the data parent directory
(as the existing Phase 1 code does) and writes a text report plus a MAT results
file into the `results` folder.

## Manual review is still required

- Phase 1 segmentation is semi-automatic and needs contour review.
- The current Phase 1 runner reviews ED and ES anchors but does not replace
  expert review of all propagated frames.
- Do not classify a patient if segmentation or measurements fail quality review.
- Use the same approved feature definitions, units, feature order, imputation
  state and scaling state during training and inference.
- Module 42 checks structure and consistency; it does not establish clinical
  correctness, segmentation accuracy or generalisability.

## Scientific limitations

- Cine FIESTA-derived features are not direct LGE infarct-scar measurements.
- Two 2D views do not provide full 3D LV volumes; FAC is not ejection fraction.
- MI labels must be clinically confirmed and their definition documented.
- With approximately 20–50 subjects, results are exploratory and uncertain.
- Use patient-level validation; never split frames from one patient across folds.
- Preprocessing, feature selection and tuning must be learned within training folds.
- Do not use the output for patient care or present it as a clinically validated MI diagnosis.

## MATLAB requirements

Use the same MATLAB release where possible. The existing Phase 1 and Phase 2
modules require Image Processing Toolbox and Statistics and Machine Learning
Toolbox functionality, respectively. Some functions and graphics behaviour vary
by MATLAB release. The package has not been executed against the user's actual
DICOM data or local MATLAB installation.
