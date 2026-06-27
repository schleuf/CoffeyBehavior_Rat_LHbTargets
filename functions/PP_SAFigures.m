function dailySAFigures(mT,runType, dex, figFold, figsave_type)
    % dailySAFigures generates a set of figures to explore oral SA data dily
    % pT = the master behavior table from main_MouseSABehavior
    % dt = current date time variable
    % figFold = Name of the daily figure folder 'Daily Figure'; Path is
    % relative so name of the folder is suffiecient
    
    yVals = {'ActiveLever', 'InactiveLever', 'EarnedInfusions', 'Intake', 'HeadEntries', 'Latency' };
    yLabs = {'Active Lever Presses', 'Inactive Lever Presses', 'Earned Rewards', 'Estimated Fentanyl Intake (μg/Kg)', 'Head Entries', 'Latency to Head Entry (s)'};
    gramm_C57_Sex_colors = {'hue_range',[40 310],'lightness_range',[95 65],'chroma_range',[50 90]};
    gramm_CD1_Sex_colors = {'hue_range',[85 -200],'lightness_range',[85 75],'chroma_range',[75 90]};
    gramm_Strain_Acq_colors = {'hue_range',[25 385],'lightness_range',[95 60],'chroma_range',[50 70]};     
    for rt = 1:length(runType)
        expStr = char(string(runType(rt)));

        pT = mT(dex.(string(expStr)),:);
        % fig 1: all animals grouped by sex and Run
        figName{1} = fullfile(figFold,[expStr, '_SexRun_GroupBehavior']);
        grammOptions{1} = {'lightness', pT.Sex, 'color', pT.Run, 'group', pT.sessionType};
        orderOptions{1} = {'lightness',{'Female','Male'}};
        legOptions{1} = {'lightness', 'Sex', 'color', 'Run'};

        % fig 2: all animals grouped by Run
        figName{2} = fullfile(figFold,[expStr, '_Run_GroupBehavior']);
        grammOptions{2} = {'color', pT.Run, 'group', pT.sessionType};
        orderOptions{2} = {};
        legOptions{2} = {'color', 'Run'};
    
        % fig 3: all animals individually
        figName{3} = fullfile(figFold,[expStr, '_IndividualBehavior']);
        grammOptions{3} = {'color', pT.ID, 'group', pT.sessionType};
        orderOptions{3} = {};
        legOptions{3} = {'color', 'ID'};
        
         % fig 4: all animals Run 3
        figName{4} = fullfile(figFold,[expStr, '_run3_IndividualBehavior']);
        grammOptions{4} = {'color', pT.ID, 'subset', pT.Run == 3, 'group', pT.sessionType};
        orderOptions{4} = {};
        legOptions{4} = {'color', 'ID'};

        % fig 5: all animals Run 4
        figName{5} = fullfile(figFold,[expStr, '_run4_IndividualBehavior']);
        grammOptions{5} = {'color', pT.ID, 'subset', pT.Run == 4, 'group', pT.sessionType};
        orderOptions{5} = {};
        legOptions{5} = {'color', 'ID'};

        % fig 6: all animals Run 5
        figName{6} = fullfile(figFold,[expStr, '_run5_IndividualBehavior']);
        grammOptions{6} = {'color', pT.ID, 'subset', pT.Run == 5, 'group', pT.sessionType};
        orderOptions{6} = {};
        legOptions{6} = {'color', 'ID'};


    
        %% figure generation
    
        for f = 1:length(figName)
            if ~isempty(figName{f})
                disp(f)
                disp(figName(f))
                plotDailies(pT, expStr, yVals, yLabs, figName{f}, figsave_type, 'GrammOptions', grammOptions{f}, 'OrderOptions', orderOptions{f}, 'LegOptions', legOptions{f}, 'ColorOptions', gramm_Strain_Acq_colors);
            end
        end
    end
    
end

function plotDailies(pT, runType, yVals, yLabs, figName, figsave_type, varargin)
    
    p = inputParser;
    addParameter(p, 'GrammOptions', {});             % For gramm initial options
    addParameter(p, 'OrderOptions', {});             % For set_order_options
    addParameter(p, 'LegOptions', {});
    addParameter(p, 'ColorOptions', {});
    parse(p, varargin{:});

    f = figure('units','normalized','outerposition',[0 0 1 1]);   
    row = 1; 
    col = 1;
    for y = 1:length(yVals)
        g(row,col)=gramm('x',pT.slideSession,'y',pT.(yVals{y}), p.Results.GrammOptions{:});
        g(row,col).set_color_options(p.Results.ColorOptions{:});
        g(row,col).stat_summary('geom',{'black_errorbar','point','line'},'type','sem','dodge',.1,'setylim',1);
        g(row,col).set_point_options('markers',{'o','s'},'base_size',10);
        g(row,col).set_text_options('font','Helvetica','base_size',16,'legend_scaling',.75,'legend_title_scaling',.75);
        g(row,col).axe_property('LineWidth',1.5,'XLim',[min(pT.slideSession)-1, max(pT.slideSession) + 1],'TickDir','out');
        g(row,col).set_order_options(p.Results.OrderOptions{:});
        g(row,col).set_names('x','Session','y', yLabs{y}, p.Results.LegOptions{:});
        [row, col] = updateRowCol(row, col, 3);
    end

    try
        g.draw();
        row = 1;
        col = 1;
        for y = 1:length(yVals)
            % SSnote: don't have to hardcode those xticks
            % if strcmp(runType, 'ER') 
            %     set(g(row,col).facet_axes_handles, 'XTick', [3 9 14 22.5 29], 'XTickLabels', {'PreT' 'W1' 'W2' 'Ext.' 'Rei.'});
            % elseif strcmp(runType, 'BE')
            %     set(g(row,col).facet_axes_handles, 'XTick', [3 9 14 20 24], 'XTickLabels', {'PreT' 'W1' 'W2' 'BeE.' 'ReT'});
            % elseif strcmp(runType, 'SA')
            %     set(g(row,col).facet_axes_handles, 'XTick', [3 9 14], 'XTickLabels', {'PreT' 'W1' 'W2'});
            % end
            [row, col] = updateRowCol(row, col, 3);
            yMax = 0;
            for ss = 1:length(g(y).results.stat_summary)
               maxStat = nanmax(g(y).results.stat_summary(ss).yci(:));
               if isnan(maxStat)
                   maxStat = nanmax(g(y).results.stat_summary(ss).y(:));
               end
               if maxStat > yMax
                   yMax = maxStat;
               end      
            end
            yMax = (ceil(yMax/10)*10)+10;
            g(y).facet_axes_handles.YLim = [-.05 * yMax, yMax];
        end
        g(1,2).facet_axes_handles.YLim=g(1,1).facet_axes_handles.YLim;
        
        for fst = 1:length(figsave_type)
            if strcmp(figsave_type{fst}, '.pdf')
                exportgraphics(f,[figName, figsave_type{fst}], 'ContentType','vector')
            else
                exportgraphics(f,[figName, figsave_type{fst}]);
            end
            disp(['saved figure: ', figName, figsave_type{fst}])
        end
    catch ME
        rep = getReport(ME);
        disp(rep)
        disp(['error encountered drawing or saving figure: ', figName, ', aborted'])
    end

end

function [row, col] = updateRowCol(row, col, colMax)
    if col == colMax
        row = row + 1;
        col = 1;
    else
        col = col + 1;
    end
end