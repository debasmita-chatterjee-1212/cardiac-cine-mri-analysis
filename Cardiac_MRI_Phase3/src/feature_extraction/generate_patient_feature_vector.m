function [T, featureNames] = generate_patient_feature_vector(phase1Out, expectedFeatureNames)
%GENERATE_PATIENT_FEATURE_VECTOR Convert one Phase 1 result into one table row.
% Compatible with Phase 1 extract_lv_features.m and build_patient_dataset.m.
%
% [T, featureNames] = generate_patient_feature_vector(phase1Out)
% [T, featureNames] = generate_patient_feature_vector(phase1Out, expectedFeatureNames)
%
% The Phase 1 feature extractor stores names such as:
%   EDArea_2CH, ESArea_2CH, FAC_2CH, ...
% The Phase 1 dataset builder expects the corresponding LV_ prefix:
%   LV_EDArea_2CH, LV_ESArea_2CH, LV_FAC_2CH, ...
%
% This function returns one row, not one row per frame.

if ~isstruct(phase1Out) || ~isfield(phase1Out,'Features')
    error('phase1Out must be the output structure returned by run_phase1_patient.');
end
f = phase1Out.Features;
if ~isfield(f,'PatientID')
    error('Phase 1 Features structure is missing PatientID.');
end
id = string(f.PatientID);
if ismissing(id) || strlength(strtrim(id))==0
    error('PatientID is missing in Phase 1 output.');
end

baseNames = {'EDArea','ESArea','FAC','MeanArea','AreaSD','AreaCV', ...
             'MaxArea','MinArea','AreaRange','MeanAbsAreaChange'};
featureNames = cell(1,20);
values = nan(1,20);
views = {'2CH','4CH'};
k = 0;
for v = 1:2
    for j = 1:numel(baseNames)
        k = k + 1;
        sourceName = [baseNames{j} '_' views{v}];
        targetName = ['LV_' baseNames{j} '_' views{v}];
        featureNames{k} = targetName;
        if ~isfield(f,sourceName)
            error('Phase 1 output is missing feature %s.',sourceName);
        end
        val = double(f.(sourceName));
        if ~isscalar(val) || ~isreal(val)
            error('Feature %s must be a real numeric scalar.',sourceName);
        end
        values(k) = val;
    end
end

if nargin >= 2 && ~isempty(expectedFeatureNames)
    expectedFeatureNames = cellstr(string(expectedFeatureNames));
    [tf,loc] = ismember(expectedFeatureNames,featureNames);
    if ~all(tf)
        error('Requested feature(s) not found in Phase 1 output: %s', ...
            strjoin(expectedFeatureNames(~tf),', '));
    end
    featureNames = expectedFeatureNames;
    values = values(loc);
end

T = array2table(values,'VariableNames',featureNames);
T = addvars(T,id,'Before',1,'NewVariableNames','PatientID');
end
