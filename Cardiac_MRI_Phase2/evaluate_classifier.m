function metrics = evaluate_classifier(Ytrue,Ypred,scores,positiveClass)
% Binary metrics. scores is optional numeric score/probability for positiveClass.
Ytrue=categorical(Ytrue); Ypred=categorical(Ypred);
cats=categories(Ytrue); if numel(cats)~=2, error('Ytrue must have two classes.'); end
if nargin<4||isempty(positiveClass), positiveClass=cats{2}; end
pos=categorical(string(positiveClass),cats); neg=categorical(cats{1},cats);
tp=sum(Ytrue==pos & Ypred==pos); tn=sum(Ytrue==neg & Ypred==neg);
fp=sum(Ytrue==neg & Ypred==pos); fn=sum(Ytrue==pos & Ypred==neg);
sens=tp/max(tp+fn,1); spec=tn/max(tn+fp,1); prec=tp/max(tp+fp,1);
f1=2*prec*sens/max(prec+sens,eps); acc=mean(Ytrue==Ypred);
metrics=struct('Accuracy',acc,'Sensitivity',sens,'Specificity',spec,'Precision',prec,'F1',f1, ...
    'TP',tp,'TN',tn,'FP',fp,'FN',fn,'PositiveClass',string(positiveClass));
if nargin>=3 && ~isempty(scores)
    [~,~,~,auc]=perfcurve(Ytrue,scores,positiveClass); metrics.AUC=auc;
else, metrics.AUC=NaN; end
end
