function [Y,classNames] = encode_diagnosis_labels(labels, classOrder)
% Convert two diagnosis labels to categorical labels.
% Optional classOrder, e.g. ["Healthy","MI"], fixes positive-class convention.
s=string(labels(:));
if any(ismissing(s)|strlength(strtrim(s))==0), error('Missing diagnosis labels.'); end
if nargin<2 || isempty(classOrder), classNames=unique(s,'stable');
else, classNames=string(classOrder(:))'; end
if numel(classNames)~=2, error('Exactly two class names are required.'); end
if any(~ismember(unique(s),classNames)), error('Unexpected diagnosis label found.'); end
Y=categorical(s,classNames,classNames);
end
