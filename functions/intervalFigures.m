function intervalFigures(mT, runType, dex, figFold, figsave_type)
    for rt = 1:length(runType)
        expStr = char(string(runType(rt)));
        pT = mT(dex.(string(expStr)),:);
        id = unique(pT.ID);  
    
        ids = unique(pT.ID);
        numrat = length(ids); 
        sessions = unique(pT.Session);
        numsess = length(sessions);
        
        tfp = nan(numrat, numsess); % time to first press 
        tp = cell(numrat, numsess); % time of all presses
        ipi = cell(numrat, numsess); % inter-press intervals
        
        for i = 1:numrat
            for s = 1:numsess
                row = find(pT.ID == ids(i) & pT.Session == sessions(s));
                if ~isempty(row)
                    EC = pT.eventCode{row};
                    ET = pT.eventTime{row};
                    tp{i, s} = ET(EC == 22);
                    if ~ isempty(tp{i,s})
                        tfp(i,s) = tp{i, s}(1);
                    end
                    ipi{i, s} = diff(tp{i, s});

                end    
            end
        end

        nonempty = ipi(~cellfun(@isempty, ipi)); 
        minVal = min(cellfun(@min, nonempty));
        maxVal = max(cellfun(@max, nonempty));


        

        numbin = 50;
        xmax = maxVal  +  10 - (10-(mod(maxVal, 10)));
        edges = 0:1200/100:1200;
        % edges = 0:xmax/50:xmax;

        ipi_hist = nan(numrat, numsess, numbin);
        for i = 1:numrat
            figure
            t = tiledlayout(3, 5, 'TileSpacing', 'Compact', 'Padding', 'compact');
            sgtitle('interpress intervals')

            for s = 1:numsess
                n = nexttile;
                
                hold on

                yscale(n,"log")
  
                if ~isempty(ipi{i, s})
                    histogram(ipi{i, s}, edges);
                else
                    scatter(.5, .5, 100, 'rx')
                end

                if i == 1
                    title([string(sessions(s))]);
                end
                if s == 1
                   ylabel(string(ids(i)))
                end

                % xlim([0, 1200])
                ylim([0, 100])
                

            end
            
        end
        yscale log

        figure
        hold on
        hSeries = gobjects(1, numrat);
        for i = 1:numrat
            p = plot(sessions, tfp(i,:));
            hSeries(i) = p(1);
        end
        legend(hSeries, ids);
        ylim([-.05, 180])
        xlim([min(sessions) - .5, max(sessions) + .5])
        hold off


       
        figName = fullfile(figFold,[expStr, '_', char(id(i)), '_Time2FirstPress_Individual']);

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