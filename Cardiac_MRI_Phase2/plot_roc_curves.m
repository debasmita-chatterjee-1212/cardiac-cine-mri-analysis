function result = plot_roc_curves(Ytrue,scoreMap,positiveClass)
% scoreMap is a struct with one numeric score vector per model.
names=fieldnames(scoreMap); figure('Color','w'); hold on; result=struct();
for k=1:numel(names)
    [x,y,~,auc]=perfcurve(Ytrue,scoreMap.(names{k}),positiveClass);
    plot(x,y,'LineWidth',1.5,'DisplayName',sprintf('%s (AUC %.3f)',names{k},auc));
    result.(names{k})=auc;
end
plot([0 1],[0 1],'k--'); xlabel('False positive rate'); ylabel('True positive rate'); title('ROC curves'); legend('Location','best'); grid on;
end
