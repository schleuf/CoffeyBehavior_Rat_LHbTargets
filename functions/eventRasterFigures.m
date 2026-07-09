function eventRasterFigures(mT, runType, dex, figFold, figsave_type)
    events2show = [22, 23, 17, 6, 30]; 
    events2lab = {'Active lever', 'Inactive lever', 'Infusion', 'Head Entry', 'Experimenter Reward'};
    eventColor = {'green', 'red', 'blue', 'magenta', 'cyan'};
    sessperfig = 5; 
    fig = figure('Position', get(0, 'Screensize'));
    for rt = 1:length(runType)
        expStr = char(string(runType(rt)));
        pT = mT(dex.(string(expStr)),:);
        id = unique(pT.ID);
        
        for i = 1:length(id)
            sess2get = unique(pT.Session(pT.ID == id(i)));
            numsess = length(sess2get);
            numfig = floor(numsess/sessperfig) + (mod(numsess, sessperfig) > 0);
            
            for f = 1:numfig
                if f == 1
                    topsess = 1;
                else
                    topsess = botsess + 1; 
                end
                botsess = min(topsess + (sessperfig - 1), numsess);

                t = tiledlayout(length(topsess:botsess), 1);
                t.TileSpacing = 'compact';
                t.Padding = 'compact';
                sgtitle([char(id(i)), ' Sessions ', num2str(sess2get(topsess)), '-', num2str(sess2get(botsess))]);  
                hSeries = gobjects(1, length(events2show));

                for s = topsess:botsess
                    EC = pT.eventCode{pT.ID == id(i) & pT.Session == sess2get(s)};
                    ET = pT.eventTime{pT.ID == id(i) & pT.Session == sess2get(s)};
                    nexttile
                    hold on
                    for e = 1:length(events2show)
                       ts = ET(EC == events2show(e));
                       h = scatter(ts, repmat(e,length(ts)), 200, '|', 'MarkerFaceColor', eventColor{e}, 'MarkerEdgeColor', eventColor{e}, 'DisplayName', events2lab{e});
                       if s == topsess
                           hSeries(e) = h(1);
                       end
                       ylabel(['Session: ', num2str(sess2get(s))])
                       ylim([-.5, length(events2show) + .5])
                       xlim([-50, 180*60])
                       xticks([0:600:180*60])
                       set(get(gca,'ylabel'),'rotation',0)
                       set(gca, 'YTick', []);
                    end
                    legend(hSeries, events2lab, 'Location', 'northwestoutside');
                    hold off
                end
                figName = fullfile(figFold,[expStr, '_', char(id(i)), '_EventRasters_S', num2str(sess2get(topsess)), '-', num2str(sess2get(botsess))]);
    
                for fst = 1:length(figsave_type)
                    if strcmp(figsave_type{fst}, '.pdf')
                        exportgraphics(t,[figName, figsave_type{fst}], 'ContentType','vector')
                    else
                        exportgraphics(t,[figName, figsave_type{fst}]);
                    end
                    disp(['saved figure: ', figName, figsave_type{fst}])
                end
            end
        end

    end

end