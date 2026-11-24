function plot_feature_distributions(X, featureNames, Y)
% Histograms by class, if Y supplied.
if nargin<2||isempty(featureNames), featureNames="Feature "+(1:size(X,2)); end
if nargin<3, Y=[]; end
if size(X,2)~=numel(featureNames), error('Feature name count mismatch.'); end
for j=1:size(X,2)
    figure('Name',char(string(featureNames(j))),'Color','w');
    if isempty(Y)
        histogram(X(:,j)); 
    else
        cats=categories(categorical(Y));
        hold on;
        for k=1:numel(cats)
            idx=string(Y)==string(cats{k});
            histogram(X(idx,j),'DisplayName',cats{k});
        end
        legend('Location','best');
    end
    xlabel(featureNames(j)); ylabel('Patient count'); title("Distribution: "+string(featureNames(j))); grid on;
end
end
