function reportFile = generate_patient_report(phase1Out, featureTable, prediction, outputDir)
%GENERATE_PATIENT_REPORT Write a concise text report for one processed patient.
% Also saves the Phase 1 output, feature row and prediction in a MAT file.
%
% This report is for research review, not clinical decision-making.

if nargin < 4 || isempty(outputDir), outputDir = fullfile(pwd,'results'); end
if ~exist(outputDir,'dir'), mkdir(outputDir); end
if ~istable(featureTable) || height(featureTable)~=1
    error('featureTable must be a one-row patient-level table.');
end
id = char(string(featureTable.PatientID(1)));
safeID = regexprep(id,'[^A-Za-z0-9_-]','_');
stamp = datestr(now,'yyyymmdd_HHMMSS');
reportFile = fullfile(outputDir,['Patient_' safeID '_research_report_' stamp '.txt']);
matFile = fullfile(outputDir,['Patient_' safeID '_research_output_' stamp '.mat']);

fid = fopen(reportFile,'w');
if fid < 0, error('Could not create report file: %s',reportFile); end
cleanup = onCleanup(@() fclose(fid));

fprintf(fid,'CARDIAC MRI RESEARCH PIPELINE REPORT\n');
fprintf(fid,'===================================\n\n');
fprintf(fid,'Patient ID: %s\n',id);
fprintf(fid,'Generated: %s\n\n',datestr(now));
fprintf(fid,'IMPORTANT: Exploratory research output only. Not a clinical diagnosis.\n\n');

views = {'2CH','4CH'};
for v=1:2
    viewName = views{v};
    if ~isfield(phase1Out,viewName), continue; end
    m = phase1Out.(viewName).Measurements;
    fprintf(fid,'%s VIEW\n',viewName);
    fprintf(fid,'---------\n');
    fprintf(fid,'Frames: %d\n',m.NumberOfFrames);
    fprintf(fid,'ED frame: %d\n',m.EDFrame);
    fprintf(fid,'ES frame: %d\n',m.ESFrame);
    fprintf(fid,'ED area: %.4f pixels\n',m.EDAreaPixels);
    fprintf(fid,'ES area: %.4f pixels\n',m.ESAreaPixels);
    fprintf(fid,'FAC: %.4f %%\n',m.FACPercent);
    fprintf(fid,'Area unit: %s\n\n',m.AreaUnit);
end

fprintf(fid,'PATIENT-LEVEL FEATURES\n');
fprintf(fid,'----------------------\n');
for j=1:width(featureTable)
    nm = featureTable.Properties.VariableNames{j};
    val = featureTable{1,j};
    if isnumeric(val)
        fprintf(fid,'%s: %.8g\n',nm,double(val));
    elseif isstring(val) || ischar(val)
        fprintf(fid,'%s: %s\n',nm,char(string(val)));
    end
end
fprintf(fid,'\nCLASSIFICATION\n');
fprintf(fid,'--------------\n');
if isempty(prediction)
    fprintf(fid,'No classification performed (no model supplied).\n');
else
    fprintf(fid,'Predicted class: %s\n',char(prediction.PredictedLabel));
    fprintf(fid,'%s\n',prediction.Interpretation);
    fprintf(fid,'\nRaw model scores:\n');
    dispNames = prediction.ScoreClassNames;
    sc = prediction.Scores;
    if isvector(sc)
        for j=1:min(numel(sc),numel(dispNames))
            fprintf(fid,'%s: %.8g\n',char(dispNames(j)),sc(j));
        end
    else
        for j=1:min(size(sc,2),numel(dispNames))
            fprintf(fid,'%s: %.8g\n',char(dispNames(j)),sc(1,j));
        end
    end
end
fprintf(fid,'\nLIMITATIONS\n');
fprintf(fid,'-----------\n');
fprintf(fid,['Cine FIESTA-derived measurements are not direct LGE scar measurements. ' ...
    'Two 2D views do not provide full 3D LV volumes; FAC is not ejection fraction. ' ...
    'Predictions require clinical label verification and independent validation before ' ...
    'any clinical interpretation.\n']);

save(matFile,'phase1Out','featureTable','prediction','-v7.3');
fprintf('Report saved: %s\n',reportFile);
fprintf('MAT results saved: %s\n',matFile);
end
