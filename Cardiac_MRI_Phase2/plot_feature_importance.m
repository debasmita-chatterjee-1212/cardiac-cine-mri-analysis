function plot_feature_importance(importanceTable,topN)
if nargin<2||isempty(topN), topN=min(15,height(importanceTable)); end
if ~all(ismember({'Feature','Importance'},importanceTable.Properties.VariableNames)), error('Table needs Feature and Importance.'); end
T=importanceTable(1:min(topN,height(importanceTable)),:);
figure('Color','w'); barh(categorical(flip(string(T.Feature))),flip(T.Importance));
xlabel('Importance'); title('Feature importance'); grid on;
end
