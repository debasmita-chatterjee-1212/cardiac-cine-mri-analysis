function setup_project(root)
if nargin<1||isempty(root), root=pwd; end
folders={'data/raw','data/processed','results','documentation','src/data_import','src/preprocessing','src/segmentation','src/quality_control','src/feature_extraction','src/pipeline'};
for k=1:numel(folders), p=fullfile(root,folders{k}); if ~exist(p,'dir'), mkdir(p); end, end
addpath(genpath(fullfile(root,'src')));
fprintf('Project ready: %s\n',root);
end
