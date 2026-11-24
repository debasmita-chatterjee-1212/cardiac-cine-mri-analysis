function cm = plot_confusion_matrix(Ytrue,Ypred,classNames)
if nargin<3||isempty(classNames), classNames=categories(categorical(Ytrue)); end
cm=confusionmat(categorical(Ytrue,classNames),categorical(Ypred,classNames),'Order',categorical(classNames));
figure('Color','w'); confusionchart(cm,classNames,'RowSummary','row-normalized','ColumnSummary','column-normalized');
title('Confusion matrix');
end
