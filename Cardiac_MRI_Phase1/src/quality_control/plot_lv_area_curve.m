function r=plot_lv_area_curve(area,view,ed,es,spacing)
if nargin<2, view='Unknown'; end
if nargin<3||isempty(ed), [~,ed]=max(area); end
if nargin<4||isempty(es), [~,es]=min(area); end
if nargin<5, spacing=[]; end
a=double(area(:)); if numel(a)<2||any(~isfinite(a))||any(a<0), error('Invalid area vector.'); end
validateattributes(ed,{'numeric'},{'scalar','integer','>=',1,'<=',numel(a)});
validateattributes(es,{'numeric'},{'scalar','integer','>=',1,'<=',numel(a)});
unit='pixels'; y=a; if ~isempty(spacing), validateattributes(spacing,{'numeric'},{'vector','numel',2,'positive'}); y=a*prod(spacing); unit='mm^2'; end
figure('Color','w'); plot(y,'-o'); hold on; plot(ed,y(ed),'go','MarkerFaceColor','g'); plot(es,y(es),'ro','MarkerFaceColor','r'); grid on;
xlabel('Frame'); ylabel(['LV area (' unit ')']); title([view ' LV area curve']); legend('Area','ED','ES');
r=struct('EDFrame',ed,'ESFrame',es,'FACPercent',100*(a(ed)-a(es))/max(a(ed),eps),'AreaUnit',unit);
end
