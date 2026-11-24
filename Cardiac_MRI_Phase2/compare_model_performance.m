function T = compare_model_performance(results)
% results: struct array with Name and Metrics fields from evaluate_classifier.
n=numel(results); Name=strings(n,1); Accuracy=nan(n,1); Sensitivity=nan(n,1);
Specificity=nan(n,1); Precision=nan(n,1); F1=nan(n,1); AUC=nan(n,1);
for k=1:n
 Name(k)=string(results(k).Name); m=results(k).Metrics;
 Accuracy(k)=m.Accuracy; Sensitivity(k)=m.Sensitivity; Specificity(k)=m.Specificity;
 Precision(k)=m.Precision; F1(k)=m.F1; if isfield(m,'AUC'), AUC(k)=m.AUC; end
end
T=table(Name,Accuracy,Sensitivity,Specificity,Precision,F1,AUC); disp(T);
end
