# Cardiac MRI Study — Phase 2 MATLAB Classification Code Set

This package is a research framework for exploratory patient-level binary classification
(Healthy vs MI) using cine-MRI-derived features.

## Requirements
- MATLAB with Statistics and Machine Learning Toolbox.
- MATLAB with `fitclinear`, `fitcsvm`, `fitcensemble`, `cvpartition`, `perfcurve`, `confusionchart`,
  `lasso`, and `predict` support. Some plotting functions require standard MATLAB graphics.
- Use the same MATLAB release across development where possible.

## Input contract
The Phase 1 table must contain:
- `PatientID`: unique subject identifier.
- `Diagnosis`: confirmed labels, exactly two classes (e.g. `Healthy`, `MI`).
- Numeric predictor columns. The default pipeline uses the 20 Phase 1 features whose names start
  with `LV_`. You can pass a different explicit feature list to `prepare_classification_data`.

One row = one patient. Never use frames as independent rows. Do not include PatientID, diagnosis,
scanner/site identifiers, or post-outcome variables as predictors unless there is a pre-specified,
scientifically justified reason.

## Important small-cohort rule
With 20–50 subjects, all performance estimates are exploratory and highly uncertain. The code
does not create an independent external test cohort. Cross-validation is internal validation only.
If there are too few subjects in the minority class for 5 folds, use fewer folds. If fewer than
2 subjects exist in either class, stratified cross-validation is not possible.

## Leakage prevention
Imputation, scaling, feature selection, and hyperparameter selection must be learned using only
the training portion of each fold. Use `fit_preprocessor` / `apply_preprocessor` within each fold.
Do not preprocess the complete dataset before cross-validation. The feature-selection functions
are utilities; call them on training data only.

## Suggested execution order
1. `D = prepare_classification_data(T);`
2. Inspect with Codes 14–17.
3. `cv = create_patient_splits(D.Y, 5, 1);`
4. In each fold, use `fit_preprocessor(Xtrain)` then `apply_preprocessor` to train/validation.
5. Select features using training data only, if justified.
6. Train models using Codes 23–25; tune cautiously using training-only inner validation.
7. Aggregate out-of-fold predictions and use Codes 30–33.
8. Interpret coefficients/importances cautiously with Codes 34–36.

## Code file list
- 10 `prepare_classification_data.m`
- 11 `encode_diagnosis_labels.m`
- 12 `handle_missing_features.m`
- 13 `normalise_features.m`
- 14 `plot_feature_distributions.m`
- 15 `analyse_feature_correlations.m`
- 16 `analyse_class_balance.m`
- 17 `compare_class_features.m`
- 18 `select_features_correlation.m`
- 19 `select_features_univariate.m`
- 20 `select_features_model_based.m`
- 21 `create_patient_splits.m`
- 22 `validate_data_splits.m`
- 23 `train_logistic_regression.m`
- 24 `train_svm.m`
- 25 `train_random_forest.m`
- 26 `compare_baseline_models.m`
- 27 `tune_logistic_regression.m`
- 28 `tune_svm.m`
- 29 `tune_random_forest.m`
- 30 `evaluate_classifier.m`
- 31 `plot_confusion_matrix.m`
- 32 `plot_roc_curves.m`
- 33 `compare_model_performance.m`
- 34 `extract_feature_importance.m`
- 35 `plot_feature_importance.m`
- 36 `analyse_model_coefficients.m`

## A minimal workflow sketch
```
D = prepare_classification_data(patientDataset);
cv = create_patient_splits(D.Y, 3, 1); % choose folds based on minority-class count
% For each fold:
tr = training(cv,fold); va = test(cv,fold);
prep = fit_preprocessor(D.X(tr,:));
Xtr = apply_preprocessor(D.X(tr,:),prep);
Xva = apply_preprocessor(D.X(va,:),prep);
% Optional feature selection must be fit on Xtr and Ytr only.
mdl = train_logistic_regression(Xtr,D.Y(tr));
[pred,score] = predict(mdl,Xva);
% Save out-of-fold predictions, then evaluate once across all subjects.
```

## Clinical/statistical limitations
- Cine FIESTA cine-derived features are not LGE scar measurements; do not claim direct infarct scar detection.
- 2CH/4CH area features are not full 3D LV volumes and FAC is not EF.
- MI labels should be confirmed by the clinical team and label definitions documented.
- Consider MI subtype, infarct timing, comorbidities, acquisition differences and site effects in interpretation.
