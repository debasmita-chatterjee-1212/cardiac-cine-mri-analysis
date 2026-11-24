function r=segment_lv_frame(im,patient,view,frame,seed,iterations)
% Draw polygon seed if omitted; active contour is a candidate, not validated segmentation.
if nargin<2, patient='Unknown'; end
if nargin<3, view='Unknown'; end
if nargin<4, frame=1; end
if nargin<5, seed=[]; end
if nargin<6||isempty(iterations), iterations=150; end
im=mat2gray(double(im));
if isempty(seed)
 f=figure('Name','Draw LV cavity seed'); imshow(im,[]); title('Draw polygon around LV cavity'); h=drawpolygon; wait(h); seed=createMask(h); if isvalid(f), close(f); end
end
if ~isequal(size(seed),size(im))||~any(seed(:)), error('Seed mask invalid or empty.'); end
m=activecontour(im,logical(seed),iterations,'Chan-Vese');
cc=bwconncomp(m); if cc.NumObjects>1, [~,j]=max(cellfun(@numel,cc.PixelIdxList)); z=false(size(m)); z(cc.PixelIdxList{j})=true; m=z; end
r=struct('PatientID',patient,'View',view,'FrameNumber',frame,'Image',im,'SeedMask',logical(seed),'LVMask',logical(m),'AreaPixels',nnz(m));
end
