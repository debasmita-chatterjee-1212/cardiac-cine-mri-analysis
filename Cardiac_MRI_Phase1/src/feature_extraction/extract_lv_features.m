function f=extract_lv_features(m2,m4)
% Ten exploratory features per view. Areas are in pixels unless scaled upstream.
req={'AreaPixels','EDAreaPixels','ESAreaPixels','FACPercent','PatientID','View'};
for k=1:numel(req), if ~isfield(m2,req{k})||~isfield(m4,req{k}), error('Missing measurement field %s.',req{k}); end, end
if string(m2.PatientID)~=string(m4.PatientID), error('Patient IDs differ.'); end
if ~strcmpi(m2.View,'2CH')||~strcmpi(m4.View,'4CH'), error('Pass 2CH then 4CH.'); end
f=struct('PatientID',string(m2.PatientID));
f2=oneView(m2); f4=oneView(m4); names=fieldnames(f2);
for k=1:numel(names), f.([names{k} '_2CH'])=f2.(names{k}); f.([names{k} '_4CH'])=f4.(names{k}); end
end
function z=oneView(m)
a=double(m.AreaPixels(:)); if numel(a)<2||any(~isfinite(a))||any(a<=0), error('Frame areas must be finite and positive.'); end
z=struct('EDArea',m.EDAreaPixels,'ESArea',m.ESAreaPixels,'FAC',m.FACPercent,'MeanArea',mean(a), ...
'AreaSD',std(a),'AreaCV',std(a)/mean(a),'MaxArea',max(a),'MinArea',min(a),'AreaRange',max(a)-min(a),'MeanAbsAreaChange',mean(abs(diff(a))));
end
