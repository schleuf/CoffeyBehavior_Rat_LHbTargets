function dailySAFigures(mT, runType, dex, statType, figFold, figsave_type, close_after_save)
    % dailySAFigures generates a set of figures to explore oral SA data dily
    % pT = the master behavior table from main_MouseSABehavior
    % dt = current date time variable
    % figFold = Name of the daily figure folder 'Daily Figure'; Path is
    % relative so name of the folder is suffiecient
    
    yVals = {'ActiveLever', 'InactiveLever', 'EarnedInfusions', 'Intake', 'HeadEntries', 'UnpursuedCues'};
    yLabs = {'Active Lever Presses', 'Inactive Lever Presses', 'Earned Rewards', 'Estimated Fentanyl Intake (μg/Kg)', 'Head Entries', 'Unpursued Cues'};
    
    % these values will be plotted with the y-axis in log scale
    logscale_yVals = {'HE_median_actLP_latency', 'HE_median_rewLP_latency', 'HE_median_cue_latency', 'median_interval_actLP', 'median_interval_rewLP', 'median_interval_HE', 'time_first_actLP'};
    logscale_yLabs = {'Head Entry Latency (active lever) (s)', 'Head Entry Latency (rewarded press) (s)', 'Head Entry Latency (cue) (s)', 'Active Lever Interval (s)', 'Rewarded Press Interval (s)', 'Head Entry Interval (s)', 'Time of 1st Active Lever Press'};
    
    gramm_C57_Sex_colors = {'hue_range',[40 310],'lightness_range',[95 65],'chroma_range',[50 90]};
    gramm_CD1_Sex_colors = {'hue_range',[85 -200],'lightness_range',[85 75],'chroma_range',[75 90]};
    gramm_Strain_Acq_colors = {'hue_range',[25 385],'lightness_range',[95 60],'chroma_range',[50 70]};     
    for rt = 1:length(runType)
        expStr = char(string(runType(rt)));

        pT = mT(dex.(string(expStr)),:);
        % fig 1: all animals grouped by sex and AAV
        figName{1} = fullfile(figFold,[expStr, '_Grouped_Sex-LHbAAV']);
        grammOptions{1} = {'color', pT.LHbAAV, 'lightness', pT.Sex, 'group', pT.sessionType};
        orderOptions{1} = {};
        legOptions{1} = {'color', 'LHbAAV', 'lightness', 'Sex'};

        % fig 2: all animals grouped by acquisition
        figName{2} = fullfile(figFold,[expStr, '_Grouped_LHbAAV-Acquire']);
        grammOptions{2} = {'color', pT.LHbAAV, 'lightness', pT.Acquire, 'group',pT.sessionType};
        orderOptions{2} = {};
        legOptions{2} = {'color', 'LHbAAV', 'lightness', 'Acquire'};

        % fig 3: acquirer animals grouped by Treatment
        figName{3} = fullfile(figFold,[expStr, '_Grouped_LHbAAV_Subset_Acquire']);
        grammOptions{3} = {'color', pT.LHbAAV,'group', pT.sessionType, 'subset', pT.Acquire=='Acquire'};
        orderOptions{3} = {};
        legOptions{3} = {'color', 'LHbAAV'};

        % fig 4: acquirer animals grouped by sex
        figName{4} = fullfile(figFold,[expStr, '_Grouped_Sex_Subset_Acquire']);
        grammOptions{4} = {'lightness', pT.Sex, 'group', pT.sessionType, 'subset', pT.Acquire=='Acquire'};
        orderOptions{4} = {};
        legOptions{4} = {'lightness', 'Sex'};

        % fig 5: acquirer animals grouped by sex and treatment
        figName{5} = fullfile(figFold,[expStr, '_Grouped_Sex-LHbAAV_Subset_Acquire']);
        grammOptions{5} = {'color', pT.LHbAAV, 'lightness', pT.Sex, 'group', pT.sessionType, 'subset', pT.Acquire=='Acquire'};
        orderOptions{5} = {};
        legOptions{5} = {'color', 'LHbAAV', 'lightness', 'Sex'};

        % fig 6: all animals grouped by Morning/Afternoon session
        figName{6} = fullfile(figFold,[expStr, '_Grouped_TimeOfBehavior']);
        grammOptions{6} = {'color', pT.TimeOfBehavior, 'group', pT.sessionType,};
        orderOptions{6} = {};
        legOptions{6} = {'color', 'Time of Session'};

        % fig 7: all animals individually
        figName{7} = fullfile(figFold,[expStr, '_Individual']);
        grammOptions{7} = {'color', pT.ID, 'group', pT.sessionType};
        orderOptions{7} = {};
        legOptions{7} = {'color', 'ID'};

        % fig 8: acquirers individually
        figName{8} = fullfile(figFold,[expStr, '_Individual_Subset_Acquire']);
        grammOptions{8} = {'color', pT.ID, 'subset', pT.Acquire=='Acquire', 'group', pT.sessionType};
        orderOptions{8} = {};
        legOptions{8} = {'color', 'ID'};

        % fig 9: non acquirers individually
        figName{9} = fullfile(figFold,[expStr, '_Individual_Subset_Nonacquire']);
        grammOptions{9} = {'color', pT.ID, 'subset', pT.Acquire=='NonAcquire', 'group', pT.sessionType};
        orderOptions{9} = {};
        legOptions{9} = {'color', 'ID'};
        % 
        % % fig 10: all animals grouped by chamber
        figName{10} = fullfile(figFold,[expStr, '_Grouped_Box']);
        grammOptions{10} = {'color', pT.Chamber, 'group', pT.sessionType};
        orderOptions{10} = {};
        legOptions{10} = {'color', 'Chamber'};

        % fig 11: AM Individual Male
        figName{11} = fullfile(figFold,[expStr, '_Individual_Subset_Male-AM']);
        grammOptions{11} = {'color', pT.ID, 'subset', pT.TimeOfBehavior == 'Morning' & pT.Sex == 'Male', 'group', pT.sessionType};
        orderOptions{11} = {};
        legOptions{11} = {'color', 'ID'};

        % fig 12: PM Individual Male
        figName{12} = fullfile(figFold,[expStr, '_Individual_Subset_Male-PM']);
        grammOptions{12} = {'color', pT.ID, 'subset', pT.TimeOfBehavior == 'Afternoon' & pT.Sex == 'Male', 'group', pT.sessionType};
        orderOptions{12} = {};
        legOptions{12} = {'color', 'ID'}; 

        % fig 13: AM Individual Female
        figName{13} = fullfile(figFold,[expStr, '_Individual_FemaleAMSubset']);
        grammOptions{13} = {'color', pT.ID, 'subset', pT.TimeOfBehavior == 'Morning' & pT.Sex == 'Female', 'group', pT.sessionType};
        orderOptions{13} = {};
        legOptions{13} = {'color', 'ID'};

        % fig 14: PM Individual Female
        figName{14} = fullfile(figFold,[expStr, '_Individual_Subset_Female-PM']);
        grammOptions{14} = {'color', pT.ID, 'subset', pT.TimeOfBehavior == 'Afternoon' & pT.Sex == 'Female', 'group', pT.sessionType};
        orderOptions{14} = {};
        legOptions{14} = {'color', 'ID'}; 

        % fig 15: Treatment
        figName{15} = fullfile(figFold,[expStr, '_Grouped_LHbAAV']);
        grammOptions{15} = {'color', pT.LHbAAV, 'group' pT.sessionType};
        orderOptions{15} = {};
        legOptions{15} = {'color', {'LHbAAV'}}; 

    
        %% figure generation
    
        for f = 1:length(figName)
            if ~isempty(figName{f})
                plotDailies(pT, expStr, yVals, yLabs, statType, figName{f}, figsave_type, 'lin', close_after_save, ...
                    'GrammOptions', grammOptions{f}, 'OrderOptions', orderOptions{f}, 'LegOptions', legOptions{f}, 'ColorOptions', gramm_Strain_Acq_colors);
                plotDailies(pT, expStr, logscale_yVals, logscale_yLabs, statType, figName{f}, figsave_type, 'log', close_after_save, ...
                    'GrammOptions', grammOptions{f}, 'OrderOptions', orderOptions{f}, 'LegOptions', legOptions{f}, 'ColorOptions', gramm_Strain_Acq_colors);
            end
        end
    end
    
end

function plotDailies(pT, runType, yVals, yLabs, statType, figName, figsave_type, scaleY, close_after_save, varargin)
    
    p = inputParser;
    addParameter(p, 'GrammOptions', {});             % For gramm initial options
    addParameter(p, 'OrderOptions', {});             % For set_order_options
    addParameter(p, 'LegOptions', {});
    addParameter(p, 'ColorOptions', {});
    parse(p, varargin{:});

    row = 1; 
    col = 1;

    for y = 1:length(yVals)
        f = figure('units','normalized','outerposition',[0 0 1 1]);   

        g(row,col)=gramm('x',pT.slideSession,'y',pT.(yVals{y}), p.Results.GrammOptions{:});
        g(row,col).set_color_options(p.Results.ColorOptions{:});
        if strcmp(statType, 'boxplot') | strcmp(statType, 'violin')
            if strcmp(statType, 'boxplot')
                g(row,col).stat_boxplot('outliers', false);
            elseif strcmp(statType, 'violin')
                g(row,col).stat_violin('normalization', 'width', 'fill','transparent');
                g(row,col).geom_jitter('width',0.1,'height',0, 'dodge', .7);
                g(row,col).set_point_options('markers', {'o'}, 'base_size', 4);
            end
        else
            g(row,col).stat_summary('geom',{'errorbar','point','line'},'type', statType,'dodge',.4,'setylim',1); % set 'type' to 'sem' or 'quartile'
            g(row,col).set_point_options('markers',{'o','s'},'base_size', 10);
        end
        
        g(row,col).set_text_options('font','Helvetica','base_size',16,'legend_scaling',.75,'legend_title_scaling',.75);
        g(row,col).axe_property('LineWidth',1.5,'XLim',[min(pT.slideSession)-1, max(pT.slideSession) + 1],'TickDir','out');
        g(row,col).set_order_options(p.Results.OrderOptions{:});
        g(row,col).set_names('x','Session','y', yLabs{y}, p.Results.LegOptions{:});
        % [row, col] = updateRowCol(row, col, 3);

        try
            g.draw();
            row = 1;
            col = 1;
            % SSnote: don't have to hardcode those xticks
            if strcmp(runType, 'ER') 
                set(g(row,col).facet_axes_handles, 'XTick', [3 9 14 22.5 29], 'XTickLabels', {'PreT' 'W1' 'W2' 'Ext.' 'Rei.'});
            elseif strcmp(runType, 'BE')
                set(g(row,col).facet_axes_handles, 'XTick', [3 9 14 20 24], 'XTickLabels', {'PreT' 'W1' 'W2' 'BeE.' 'ReT'});
            elseif strcmp(runType, 'SA')
                set(g(row,col).facet_axes_handles, 'XTick', [3 9 14], 'XTickLabels', {'PreT' 'W1' 'W2'});
            end

            if strcmp(scaleY, 'log')
                set(g(row,col).facet_axes_handles, 'YScale', 'log');
            end

            % [row, col] = updateRowCol(row, col, 3);
            yMax = 0;
            if strcmp(statType, 'boxplot') | strcmp(statType, 'violin')
                disp('??? figure out how to set y limits w/ boxplot summaries')
            else

                for ss = 1:length(g(1).results.stat_summary)
                   maxStat = nanmax(g(1).results.stat_summary(ss).yci(:));
                   if isnan(maxStat)
                       maxStat = nanmax(g(1).results.stat_summary(ss).y(:));
                   end
                   if maxStat > yMax
                       yMax = maxStat;
                   end      
                end
                yMax = (ceil(yMax/10)*10)+10;
                g(1).facet_axes_handles.YLim = [-.05 * yMax, yMax];
            end
        
            for fst = 1:length(figsave_type)
                if contains(yLabs{y}, '/')
                    labstr = strrep(yLabs{y}, '/', 'per');
                else 
                    labstr = yLabs{y};
                end
                fullname = [figName, '\' labstr, '_', statType, figsave_type{fst}];
                if ~exist(figName, 'dir')
                    mkdir(figName);
                end

                if strcmp(figsave_type{fst}, '.pdf')
                    exportgraphics(f, fullname, 'ContentType','vector');
                else
                    exportgraphics(f, fullname);
                end
                disp(['saved figure: ', fullname])
                if close_after_save
                    close(f)
                end
            end
        catch ME
            rep = getReport(ME);
            disp(rep)
            disp(['error encountered drawing or saving figure: ', figName, '\' labstr, '_', statType, figsave_type{fst}, ', aborted'])
        end
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