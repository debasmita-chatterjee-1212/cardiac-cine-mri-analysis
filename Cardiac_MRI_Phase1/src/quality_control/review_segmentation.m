function r=review_segmentation(im,mask,patient,view,frame)
if nargin<3, patient='Unknown'; end
if nargin<4, view='Unknown'; end
if nargin<5, frame=1; end
f=figure('Name','Segmentation review'); imshow(im,[]); hold on; visboundaries(logical(mask),'Color','r');
title(sprintf('%s %s frame %d',patient,view,frame));
decision=questdlg('Is the LV cavity contour acceptable?','Review','Accept','Reject','Needs review','Needs review');
a=inputdlg('Comments (optional):','Reviewer notes',[4 60],{''}); if isempty(a), a={''}; end
r=struct('PatientID',patient,'View',view,'Frame',frame,'Decision',decision,'Comments',a{1},'Date',datetime('now'),'AreaPixels',nnz(mask));
if isvalid(f), close(f); end
end
