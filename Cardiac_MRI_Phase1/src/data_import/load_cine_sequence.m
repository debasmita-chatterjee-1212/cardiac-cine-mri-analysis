function cine=load_cine_sequence(folder)
% One DICOM file per temporal frame. Sort by TriggerTime, fallback InstanceNumber.
if ~isfolder(folder), error('Folder not found: %s',folder); end
d=dir(fullfile(folder,'*.dcm')); if isempty(d), d=dir(fullfile(folder,'*.DCM')); end
if isempty(d), error('No DICOM files in %s',folder); end
n=numel(d); paths=strings(n,1); tt=nan(n,1); ins=nan(n,1);
for k=1:n
 paths(k)=string(fullfile(d(k).folder,d(k).name));
 info=dicominfo(paths(k));
 if isfield(info,'TriggerTime'), tt(k)=double(info.TriggerTime); end
 if isfield(info,'InstanceNumber'), ins(k)=double(info.InstanceNumber); end
end
if all(isfinite(tt)), [~,ix]=sortrows([tt ins],[1 2]);
elseif all(isfinite(ins)), [~,ix]=sort(ins);
else, error('No complete temporal ordering metadata found.'); end
im0=dicomread(paths(ix(1))); if ndims(im0)>2, im0=im0(:,:,1); end
vol=zeros(size(im0,1),size(im0,2),n,'like',im0);
for k=1:n
 im=dicomread(paths(ix(k))); if ndims(im)>2, im=im(:,:,1); end
 if ~isequal(size(im),size(im0)), error('Inconsistent DICOM dimensions.'); end
 vol(:,:,k)=im;
end
spacing=[];
info=dicominfo(paths(ix(1))); if isfield(info,'PixelSpacing'), spacing=double(info.PixelSpacing(:)'); end
cine=struct('Images',vol,'FilePaths',paths(ix),'NumberOfFrames',n,'PixelSpacing',spacing,'TriggerTime',tt(ix),'InstanceNumber',ins(ix));
end
