function [y,info]=preprocess_cine_sequence(x,p1,p2)
% Sequence-wide percentile clipping and scaling to [0,1].
if nargin<2||isempty(p1), p1=1; end
if nargin<3||isempty(p2), p2=99; end
if ndims(x)~=3||p1<0||p2>100||p1>=p2, error('Invalid input or percentile limits.'); end
x=double(x); if any(~isfinite(x(:))), error('Input contains non-finite pixels.'); end
lo=prctile(x(:),p1); hi=prctile(x(:),p2); if hi<=lo, error('No usable intensity range.'); end
y=(min(max(x,lo),hi)-lo)/(hi-lo);
info=struct('LowerPercentile',p1,'UpperPercentile',p2,'LowerIntensity',lo,'UpperIntensity',hi);
end
