function r=calculate_lv_measurements(masks,spacing,ed,es,patient,view)
if nargin<2, spacing=[]; end
if nargin<3, ed=[]; end
if nargin<4, es=[]; end
if nargin<5, patient='Unknown'; end
if nargin<6, view='Unknown'; end
if ndims(masks)~=3||size(masks,3)<2, error('Masks must be rows x columns x frames.'); end
n=size(masks,3); area=zeros(n,1); for k=1:n, area(k)=nnz(masks(:,:,k)); end
[~,ced]=max(area); [~,ces]=min(area); if isempty(ed), ed=ced; end; if isempty(es), es=ces; end
validateattributes(ed,{'numeric'},{'scalar','integer','>=',1,'<=',n}); validateattributes(es,{'numeric'},{'scalar','integer','>=',1,'<=',n});
if ed==es, error('ED and ES must differ.'); end
if isempty(spacing), phys=[]; edphys=NaN; esphys=NaN; unit='pixels';
else, validateattributes(spacing,{'numeric'},{'vector','numel',2,'positive','finite'}); phys=area*prod(spacing); edphys=phys(ed); esphys=phys(es); unit='mm^2'; end
fac=NaN; if area(ed)>0, fac=100*(area(ed)-area(es))/area(ed); end
r=struct('PatientID',patient,'View',view,'AreaPixels',area,'AreaPhysical',phys,'AreaUnit',unit,'PixelSpacing',spacing, ...
'CandidateEDFrame',ced,'CandidateESFrame',ces,'EDFrame',ed,'ESFrame',es,'EDAreaPixels',area(ed),'ESAreaPixels',area(es), ...
'EDAreaPhysical',edphys,'ESAreaPhysical',esphys,'FACPercent',fac,'NumberOfFrames',n);
if any(area==0), warning('Empty mask frame(s): inspect before interpreting.'); end
end
