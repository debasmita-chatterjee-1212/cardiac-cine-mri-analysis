function inspect_cine_view(x,label,frames)
if nargin<2, label='cine'; end
if nargin<3||isempty(frames), frames=unique(round(linspace(1,size(x,3),min(6,size(x,3))))); end
figure('Name',[label ' inspection'],'Color','w'); tiledlayout(2,ceil(numel(frames)/2));
for k=1:numel(frames), nexttile; imagesc(x(:,:,frames(k))); axis image off; colormap gray; title(sprintf('%s frame %d',label,frames(k))); end
end
