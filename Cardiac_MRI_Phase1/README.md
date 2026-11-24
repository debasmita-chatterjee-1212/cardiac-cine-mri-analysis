# Cardiac MRI Phase 1 — Integrated MATLAB Code Set

## Included
DICOM loading and ordering; cine QC; sequence-wide intensity preprocessing; visual inspection;
manual polygon anchor segmentation with Chan–Vese refinement; corrected two-arc cyclic propagation;
review dialogs; mask comparison; area-curve plotting; LV area/FAC measurements; 20 exploratory
2CH/4CH features; patient-level dataset construction; dataset validation; single-patient driver.

## Requirements
MATLAB with Image Processing Toolbox. DICOM functions must be available. Physical Hausdorff
distance in `compare_masks` uses `pdist2` (Statistics and Machine Learning Toolbox); use pixel
spacing `[]` for pixel-based distance if that toolbox is unavailable.

## Folder layout expected by driver
`Patient XXXX/2_Chamber_FIESTA_CINE/2_Chamber_FIESTA_CINE/*.dcm`
`Patient XXXX/4_Chamber_FIESTA_CINE/4_Chamber_FIESTA_CINE/*.dcm`

## Start
1. Extract ZIP and set MATLAB Current Folder to `Cardiac_MRI_Phase1`.
2. Run `setup_project(pwd)`.
3. Example: `out=run_phase1_patient('0912','FULL_PATH_TO_PARENT_FOLDER',2,11,3,12);`
   Arguments after root are ED/ES frame numbers for 2CH then ED/ES for 4CH.
4. Inspect saved `Patient_0912_phase1.mat`, especially masks and review decisions.

## Build cohort table
After processing each subject and collecting `out.Features`:
`records=[out0912.Features,out0913.Features];`
`T=build_patient_dataset(records);`
`report=validate_patient_dataset(T);`
Join confirmed labels using a table with `PatientID` and `Diagnosis`.

## Scientific and operational cautions
- This is a research starter pipeline, not a clinically validated or fully automatic segmentation system.
- Confirm DICOM ordering and that each file represents one temporal frame; multi-frame DICOMs need a different importer.
- The tracker propagates masks but can drift or leak into adjacent structures. Review every frame; expert contours on a subset are strongly recommended.
- FAC is fractional area change, not ejection fraction. Two 2D views do not provide full 3D LV volumes.
- Cine FIESTA is not LGE scar imaging. Do not claim this pipeline directly detects infarct scar or provides a clinical MI diagnosis.
- Pixel-based areas are not comparable across subjects unless pixel spacing and acquisition consistency are checked. Use physical area where reliable spacing exists.
- One patient must be one row. Never split frames from one patient across training and test data.
- With approximately 20–50 subjects, model performance will be highly uncertain and exploratory.
- Keep DICOMs and clinical labels on institution-approved secure storage. Do not place patient data in public Git repositories.
- Validate on a few subjects first; do not batch-process the full cohort until import, segmentation, tracking and measurements are reviewed.
