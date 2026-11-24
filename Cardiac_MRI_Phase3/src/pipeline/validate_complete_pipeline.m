function qc = validate_complete_pipeline(phase1Out, featureTable, modelFile)
%VALIDATE_COMPLETE_PIPELINE Run structural/consistency checks on one patient's outputs.
%
% This is a software quality-control check. It does not validate clinical
% accuracy or establish segmentation ground truth.

if nargin < 2, error('Provide Phase 1 output and its patient feature table.'); end
if nargin < 3, modelFile = ''; end
qc = struct();
qc.Passed = true;
qc.Messages = strings(0,1);

requiredViews = {'2CH','4CH'};
for v=1:2
    vn = requiredViews{v};
    if ~isfield(phase1Out,vn)
        qc = addFailure(qc,['Missing view: ' vn]);
        continue;
    end
    z = phase1Out.(vn);
    if ~isfield(z,'Tracking') || ~isfield(z.Tracking,'Masks')
        qc = addFailure(qc,[vn ' tracking masks missing.']);
        continue;
    end
    masks = z.Tracking.Masks;
    if ndims(masks)~=3 || size(masks,3)~=30
        qc = addFailure(qc,[vn ' should contain 30 mask frames.']);
    end
    if ~isfield(z,'Measurements')
        qc = addFailure(qc,[vn ' measurements missing.']);
    else
        m=z.Measurements;
        if m.EDFrame==m.ESFrame
            qc = addFailure(qc,[vn ' ED and ES frames are identical.']);
        end
        if ~isfinite(m.FACPercent)
            qc = addFailure(qc,[vn ' FAC is non-finite.']);
        end
        if any(m.AreaPixels<=0)
            qc = addFailure(qc,[vn ' contains empty LV masks; manual review required.']);
        end
    end
end

if ~istable(featureTable) || height(featureTable)~=1
    qc = addFailure(qc,'Feature output must be a one-row table.');
else
    if ~ismember('PatientID',featureTable.Properties.VariableNames)
        qc = addFailure(qc,'PatientID missing from feature table.');
    end
    predictors = setdiff(featureTable.Properties.VariableNames,{'PatientID'});
    for j=1:numel(predictors)
        x=featureTable.(predictors{j});
        if ~isnumeric(x) || ~isscalar(x) || ~isfinite(x)
            qc = addFailure(qc,['Invalid or non-finite feature: ' predictors{j}]);
        end
    end
end

if ~isempty(modelFile)
    if ~exist(modelFile,'file')
        qc = addFailure(qc,'Classifier model file does not exist.');
    else
        try
            S=load(modelFile,'bundle');
            if ~isfield(S,'bundle')
                qc = addFailure(qc,'Model file does not contain a bundle variable.');
            elseif istable(featureTable)
                missing=setdiff(S.bundle.InputFeatureNames,featureTable.Properties.VariableNames);
                if ~isempty(missing)
                    qc = addFailure(qc,['Model features missing: ' strjoin(missing,', ')]);
                end
            end
        catch ME
            qc = addFailure(qc,['Could not inspect model file: ' ME.message]);
        end
    end
end

if qc.Passed
    qc.Messages(end+1)="Structural checks passed. This does not establish clinical validity.";
end
end

function qc = addFailure(qc,msg)
qc.Passed=false;
qc.Messages(end+1)=string(msg);
end
