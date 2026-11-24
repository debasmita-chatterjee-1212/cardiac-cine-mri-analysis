function r=compare_masks(ref,pred,spacing)
% Dice, Jaccard and symmetric Hausdorff distance (pixels unless spacing supplied).
if nargin<3, spacing=[]; end
if ~isequal(size(ref),size(pred)), error('Mask sizes differ.'); end
a=logical(ref); b=logical(pred);
if ~any(a(:))||~any(b(:)), dice=0; jac=0; hd=NaN;
else
 inter=nnz(a&b); dice=2*inter/(nnz(a)+nnz(b)); jac=inter/nnz(a|b);
 pa=bwperim(a); pb=bwperim(b);
 if isempty(spacing), da=bwdist(pa); db=bwdist(pb); hd=max([max(da(pb)),max(db(pa))]);
 else
  validateattributes(spacing,{'numeric'},{'vector','numel',2,'positive','finite'});
  [ra,ca]=find(pa); [rb,cb]=find(pb); A=[ra*spacing(1),ca*spacing(2)]; B=[rb*spacing(1),cb*spacing(2)];
  D=pdist2(A,B); hd=max([max(min(D,[],2)),max(min(D,[],1))]);
 end
end
unit='pixels'; if ~isempty(spacing), unit='mm'; end
r=struct('Dice',dice,'Jaccard',jac,'HausdorffDistance',hd,'HausdorffUnit',unit);
end
