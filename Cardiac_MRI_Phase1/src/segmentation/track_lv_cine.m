function r=track_lv_cine(x,ed,es,edMask,esMask,patient,view,iters)
% Propagates ED->ES and ES->next ED in temporal order on complementary arcs.
% The arcs do not overwrite one another. Review every frame for drift.
if nargin<6, patient='Unknown'; end
if nargin<7, view='Unknown'; end
if nargin<8||isempty(iters), iters=100; end
n=size(x,3); validateattributes(ed,{'numeric'},{'scalar','integer','>=',1,'<=',n}); validateattributes(es,{'numeric'},{'scalar','integer','>=',1,'<=',n});
if ed==es||~isequal(size(edMask),size(x(:,:,1)))||~isequal(size(esMask),size(x(:,:,1))), error('Invalid anchors.'); end
m=false(size(x)); m(:,:,ed)=logical(edMask); m(:,:,es)=logical(esMask);
f=ed; while f~=es, q=mod(f,n)+1; if q~=es, m(:,:,q)=step(x(:,:,q),m(:,:,f),iters); end, f=q; end
f=es; while f~=ed, q=mod(f,n)+1; if q~=ed, m(:,:,q)=step(x(:,:,q),m(:,:,f),iters); end, f=q; end
a=zeros(n,1); for k=1:n, a(k)=nnz(m(:,:,k)); end
r=struct('PatientID',patient,'View',view,'Masks',m,'AreaPixels',a,'EDFrame',ed,'ESFrame',es,'Iterations',iters);
end
function m=step(im,seed,iters)
m=activecontour(mat2gray(double(im)),logical(seed),iters,'Chan-Vese'); cc=bwconncomp(m);
if cc.NumObjects>1, [~,j]=max(cellfun(@numel,cc.PixelIdxList)); z=false(size(m)); z(cc.PixelIdxList{j})=true; m=z; end
end
