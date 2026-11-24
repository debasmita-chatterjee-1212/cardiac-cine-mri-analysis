function mdl = train_svm(X,Y,kernel,boxConstraint,kernelScale)
% Binary SVM. Standardise X using training-only normalisation beforehand.
if nargin<3||isempty(kernel), kernel='linear'; end
if nargin<4||isempty(boxConstraint), boxConstraint=1; end
if nargin<5||isempty(kernelScale), kernelScale='auto'; end
Y=categorical(Y); if numel(categories(Y))~=2, error('Binary labels required.'); end
mdl=fitcsvm(X,Y,'KernelFunction',kernel,'BoxConstraint',boxConstraint, ...
    'KernelScale',kernelScale,'Standardize',false,'ClassNames',categories(Y));
end
