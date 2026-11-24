function out=run_phase1_patient(patientID,rootDir,ed2,es2,ed4,es4)
% Guided single-patient workflow; requires manual anchor contouring and review.
if nargin<2, error('Provide parent folder containing Patient XXXX folders.'); end
if nargin<3, ed2=[]; end; if nargin<4, es2=[]; end; if nargin<5, ed4=[]; end; if nargin<6, es4=[]; end
id=char(string(patientID)); views={'2CH','4CH'}; eds=[ed2 ed4]; ess=[es2 es4];
sub={'2_Chamber_FIESTA_CINE','4_Chamber_FIESTA_CINE'};
for v=1:2
 folder=fullfile(rootDir,['Patient ' id],sub{v},sub{v});
 c=load_cine_sequence(folder); q=validate_cine_sequence(c,30); [x,pi]=preprocess_cine_sequence(c.Images);
 inspect_cine_view(x,views{v});
 if isempty(eds(v))||isempty(ess(v))
  a=inputdlg({[views{v} ' ED frame'],[views{v} ' ES frame']},'Select phases',1,{'1','15'});
  if isempty(a), error('Phase selection cancelled.'); end
  eds(v)=str2double(a{1}); ess(v)=str2double(a{2});
 end
 re=segment_lv_frame(x(:,:,eds(v)),id,views{v},eds(v)); rs=segment_lv_frame(x(:,:,ess(v)),id,views{v},ess(v));
 rev1=review_segmentation(x(:,:,eds(v)),re.LVMask,id,views{v},eds(v)); rev2=review_segmentation(x(:,:,ess(v)),rs.LVMask,id,views{v},ess(v));
 tr=track_lv_cine(x,eds(v),ess(v),re.LVMask,rs.LVMask,id,views{v});
 out.(views{v})=struct('Cine',c,'Preprocessed',x,'PreprocessInfo',pi,'CineQC',q,'EDAnchor',re,'ESAnchor',rs,'EDReview',rev1,'ESReview',rev2,'Tracking',tr);
end
out.('2CH').Measurements=calculate_lv_measurements(out.('2CH').Tracking.Masks,out.('2CH').Cine.PixelSpacing,eds(1),ess(1),id,'2CH');
out.('4CH').Measurements=calculate_lv_measurements(out.('4CH').Tracking.Masks,out.('4CH').Cine.PixelSpacing,eds(2),ess(2),id,'4CH');
out.Features=extract_lv_features(out.('2CH').Measurements,out.('4CH').Measurements);
save(fullfile(rootDir,['Patient_' id '_phase1.mat']),'out','-v7.3');
end
