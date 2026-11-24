function r=validate_cine_sequence(cine,expected)
if nargin<2, expected=30; end
if ~isstruct(cine)||~isfield(cine,'Images')||ndims(cine.Images)~=3, error('Expected cine.Images as rows x columns x frames.'); end
x=double(cine.Images); r=struct('ImageSize',size(x),'NumberOfFrames',size(x,3),'ExpectedFrames',expected,'FrameCountMatches',size(x,3)==expected,'HasNonfinite',any(~isfinite(x(:))),'PixelSpacing',cine.PixelSpacing);
if ~r.FrameCountMatches, warning('Found %d frames; expected %d.',size(x,3),expected); end
if r.HasNonfinite, warning('Non-finite pixel values detected.'); end
end
