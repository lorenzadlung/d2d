% Plot YSTD models sensitivities
%
% arPlotSYSTD

function arPlotSYSTD

global ar

if(isempty(ar))
    error('please initialize by arInit')
end

% constants
overplot = 0.1;

fcount = 1;
for jm = 1:length(ar.model)
    nd = length(ar.model(jm).data);
    for jd = 1:nd
        myRaiseFigure(jm, ['SYSTD: ' ar.model(jm).data(jd).name ' - ' ar.model(jm).data(jd).checkstr], fcount);
        
        % rows and cols
        [ncols, nrows, ny] = myColsAndRows(jm, jd);
        
        np = length(ar.model(jm).data(jd).p);
        for jy = 1:ny
            g = subplot(nrows,ncols,jy);
            arSubplotStyle(g);
            
            legendhandle = zeros(1,np);
            
            for jp = 1:np
                linestyle = myLineStyle(np,jp);
                ltmp = plot(g, ar.model(jm).data(jd).tFine, ar.model(jm).data(jd).systdFineSimu(:,jy,jp), linestyle{:});
                legendhandle(jp) = ltmp;
                hold(g, 'on');
                if(isfield(ar.model(jm).data(jd), 'systdExpSimuFD'))
                    plot(g, ar.model(jm).data(jd).tExp, ar.model(jm).data(jd).systdExpSimuFD(:,jy,jp), linestyle{:}, 'Marker', '*');
                end
            end
            hold(g, 'off');
            
            spacedAxisLimits(g, overplot);
            title(g, arNameTrafo(ar.model(jm).data(jd).y{jy}));
            if(jy == 1)
                legend(g, legendhandle, arNameTrafo(ar.model(jm).data(jd).p));
            end
            
            if(jy == (nrows-1)*ncols + 1)
                xlabel(g, sprintf('%s [%s]', ar.model(jm).data(jd).tUnits{3}, ar.model(jm).data(jd).tUnits{2}));
                ylabel(g, 'sensitivity');
            end
        end        
        fcount = fcount + 1;
    end
end



%% sub-functions



function C = myLineStyle(n, j)
farben = lines(n);
zeichen = {':', '-', '--', '-.'};
zeichenindex = mod(floor((j-1)/7)+1, 4)+1;
C = cell(1,3);
C{1} = [zeichen{zeichenindex}];
C{2} = 'Color';
C{3} = farben(j,:);




function h = myRaiseFigure(m, figname, jf)
global ar
openfigs = get(0,'Children');

figcolor = [1 1 1];
figdist = 0.02;

ar.model(m).plots(jf).time = now;

if(isfield(ar.model(m).plots(jf), 'fighandel_systd') && ~isempty(ar.model(m).plots(jf).fighandel_systd) && ...
        ar.model(m).plots(jf).fighandel_systd ~= 0 && sum(ar.model(m).plots(jf).fighandel_systd==openfigs)>0 && ...
        strcmp(get(ar.model(m).plots(jf).fighandel_systd, 'Name'), figname))
    h = ar.model(m).plots(jf).fighandel_systd;
    figure(h);
else
    h = figure('Name', figname, 'NumberTitle','off', ...
        'Units', 'normalized', 'Position', ...
        [0.25+((jf-1)*figdist) 0.45-((jf-1)*figdist) 0.3 0.45]);
    set(h,'Color', figcolor);
    ar.model(m).plots(jf).fighandel_systd = h;
end






function [ncols, nrows, ny] = myColsAndRows(jm, jd)
global ar
ny = size(ar.model(jm).data(jd).y, 2);
[nrows, ncols] = arNtoColsAndRows(ny);





function spacedAxisLimits(g, overplot)
[xmin xmax ymin ymax] = axisLimits(g);
xrange = xmax - xmin;
if(xrange == 0)
    xrange = 1;
end
yrange = ymax - ymin;
if(yrange == 0)
    yrange = 1;
end
xlim(g, [xmin-(xrange*overplot) xmax+(xrange*overplot)]);
ylim(g, [ymin-(yrange*overplot) ymax+(yrange*overplot)]);



function [xmin xmax ymin ymax] = axisLimits(g)
p = get(g,'Children');
xmin = nan;
xmax = nan;
ymin = nan;
ymax = nan;
for j = 1:length(p)
    if(~strcmp(get(p(j), 'Type'), 'text'))
        xmin = min([xmin toRowVector(get(p(j), 'XData'))]);
        xmax = max([xmax toRowVector(get(p(j), 'XData'))]);
        %         get(p(j), 'UData')
        %         get(p(j), 'LData')
        %         set(p(j), 'LData', get(p(j), 'LData')*2)
        if(strcmp(get(p(j), 'Type'),'hggroup'))
            ymin = min([ymin toRowVector(get(p(j), 'YData'))-toRowVector(get(p(j), 'LData'))]);
            ymax = max([ymax toRowVector(get(p(j), 'YData'))+toRowVector(get(p(j), 'UData'))]);
        else
            ymin = min([ymin toRowVector(get(p(j), 'YData'))]);
            ymax = max([ymax toRowVector(get(p(j), 'YData'))]);
        end
    end
end



function b = toRowVector(a)
b = a(:)';


