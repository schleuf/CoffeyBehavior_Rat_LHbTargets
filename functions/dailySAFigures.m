function dailySAFigures(mT, runType, dex, statType, figFold, figsave_type)
    % dailySAFigures generates a set of figures to explore oral SA data dily
    % pT = the master behavior table from main_MouseSABehavior
    % dt = current date time variable
    % figFold = Name of the daily figure folder 'Daily Figure'; Path is
    % relative so name of the folder is suffiecient
    
    yVals = {'ActiveLever', 'InactiveLever', 'EarnedInfusions', 'Intake', 'HeadEntries', 'UnpursuedCues'};
    yLabs = {'Active Lever Presses', 'Inactive Lever Presses', 'Earned Rewards', 'Estimated Fentanyl Intake (μg/Kg)', 'Head Entries', 'Unpursued Cues'};
    
    more_yVals = {'HE_median_actLP_latency', 'HE_median_rewLP_latency', 'HE_median_cue_latency', 'median_interval_actLP', 'median_interval_rewLP', 'median_interval_HE'};
    more_yLabs = {'Head Entry Latency (active lever) (s)', 'Head Entry Latency (rewarded press) (s)', 'Head Entry Latency (cue) (s)', 'Active Lever Interval (s)', 'Rewarded Press Interval (s)', 'Head Entry Interval (s)'};
    
    gramm_C57_Sex_colors = {'hue_range',[40 310],'lightness_range',[95 65],'chroma_range',[50 90]};
    gramm_CD1_Sex_colors = {'hue_range',[85 -200],'lightness_range',[85 75],'chroma_range',[75 90]};
    gramm_Strain_Acq_colors = {'hue_range',[25 385],'lightness_range',[95 60],'chroma_range',[50 70]};     
    for rt = 1:length(runType)
        expStr = char(string(runType(rt)));

        pT = mT(dex.(string(expStr)),:);
        % fig 1: all animals grouped by sex and AAV
        figName{1} = fullfile(figFold,[expStr, '_SexTreatmentCollapsed']);
        grammOptions{1} = {'color', pT.LHbAAV, 'lightness', pT.Sex, 'group', pT.sessionType};
        orderOptions{1} = {};
        legOptions{1} = {'color', 'LHbAAV', 'lightness', 'Sex'};

        % fig 2: all animals grouped by acquisition
        figName{2} = fullfile(figFold,[expStr, '_TreatmentAcquisitionCollapsed']);
        grammOptions{2} = {'color', pT.LHbAAV, 'lightness', pT.Acquire, 'group',pT.sessionType};
        orderOptions{2} = {};
        legOptions{2} = {'color', 'LHbAAV', 'lightness', 'Acquire'};

        % fig 3: acquirer animals grouped by Treatment
        figName{3} = fullfile(figFold,[expStr, '_TreatmentCollapsed_Acquire']);
        grammOptions{3} = {'color', pT.LHbAAV,'group', pT.sessionType, 'subset', pT.Acquire=='Acquire'};
        orderOptions{3} = {};
        legOptions{3} = {'color', 'LHbAAV'};

        % fig 4: acquirer animals grouped by sex
        figName{4} = fullfile(figFold,[expStr, '_SexCollapsed_Acquire']);
        grammOptions{4} = {'lightness', pT.Sex, 'group', pT.sessionType, 'subset', pT.Acquire=='Acquire'};
        orderOptions{4} = {};
        legOptions{4} = {'lightness', 'Sex'};

        % fig 5: acquirer animals grouped by sex and treatment
        figName{5} = fullfile(figFold,[expStr, '_SexTreatmentCollapsed_Acquire']);
        grammOptions{5} = {'color', pT.LHbAAV, 'lightness', pT.Sex, 'group', pT.sessionType, 'subset', pT.Acquire=='Acquire'};
        orderOptions{5} = {};
        legOptions{5} = {'color', 'LHbAAV', 'lightness', 'Sex'};

        % fig 6: all animals grouped by Morning/Afternoon session
        figName{6} = fullfile(figFold,[expStr, '_TimeOfBehaviorCollapsed']);
        grammOptions{6} = {'color', pT.TimeOfBehavior, 'group', pT.sessionType,};
        orderOptions{6} = {};
        legOptions{6} = {'color', 'Time of Session'};

        % fig 7: all animals individually
        figName{7} = fullfile(figFold,[expStr, '_IndividualAll']);
        grammOptions{7} = {'color', pT.ID, 'group', pT.sessionType};
        orderOptions{7} = {};
        legOptions{7} = {'color', 'ID'};

        % fig 8: acquirers individually
        figName{8} = fullfile(figFold,[expStr, '_IndividualAcquire']);
        grammOptions{8} = {'color', pT.ID, 'subset', pT.Acquire=='Acquire', 'group', pT.sessionType};
        orderOptions{8} = {};
        legOptions{8} = {'color', 'ID'};

        % fig 9: non acquirers individually
        figName{9} = fullfile(figFold,[expStr, '_IndividualNonacquire']);
        grammOptions{9} = {'color', pT.ID, 'subset', pT.Acquire=='NonAcquire', 'group', pT.sessionType};
        orderOptions{9} = {};
        legOptions{9} = {'color', 'ID'};
        % 
        % % fig 10: all animals grouped by chamber
        figName{10} = fullfile(figFold,[expStr, '_BoxCollapsed']);
        grammOptions{10} = {'color', pT.Chamber, 'group', pT.sessionType};
        orderOptions{10} = {};
        legOptions{10} = {'color', 'Chamber'};

        % fig 11: AM Individual Male
        figName{11} = fullfile(figFold,[expStr, '_IndividualMale_AM']);
        grammOptions{11} = {'color', pT.ID, 'subset', pT.TimeOfBehavior == 'Morning' & pT.Sex == 'Male', 'group', pT.sessionType};
        orderOptions{11} = {};
        legOptions{11} = {'color', 'ID'};

        % fig 12: PM Individual Male
        figName{12} = fullfile(figFold,[expStr, '_IndividualMale_PM']);
        grammOptions{12} = {'color', pT.ID, 'subset', pT.TimeOfBehavior == 'Afternoon' & pT.Sex == 'Male', 'group', pT.sessionType};
        orderOptions{12} = {};
        legOptions{12} = {'color', 'ID'}; 

        % fig 13: AM Individual Female
        figName{13} = fullfile(figFold,[expStr, '_IndividualFemale_AM']);
        grammOptions{13} = {'color', pT.ID, 'subset', pT.TimeOfBehavior == 'Morning' & pT.Sex == 'Female', 'group', pT.sessionType};
        orderOptions{13} = {};
        legOptions{13} = {'color', 'ID'};

        % fig 14: PM Individual Female
        figName{14} = fullfile(figFold,[expStr, '_IndividualFemale_PM']);
        grammOptions{14} = {'color', pT.ID, 'subset', pT.TimeOfBehavior == 'Afternoon' & pT.Sex == 'Female', 'group', pT.sessionType};
        orderOptions{14} = {};
        legOptions{14} = {'color', 'ID'}; 

        % fig 15: Treatment
        figName{15} = fullfile(figFold,[expStr, '_TreatmentCollapsed']);
        grammOptions{15} = {'color', pT.LHbAAV, 'group' pT.sessionType};
        orderOptions{15} = {};
        legOptions{15} = {'color', {'LHbAAV'}}; 


    
        %% figure generation
    
        for f = 1:length(figName)
            if ~isempty(figName{f})
                disp(f)
                disp(figName(f))
                plotDailies(pT, expStr, yVals, yLabs, statType, figName{f}, figsave_type, 1, 'GrammOptions', grammOptions{f}, 'OrderOptions', orderOptions{f}, 'LegOptions', legOptions{f}, 'ColorOptions', gramm_Strain_Acq_colors);
                plotDailies(pT, expStr, more_yVals, more_yLabs, statType, figName{f}, figsave_type, 2, 'GrammOptions', grammOptions{f}, 'OrderOptions', orderOptions{f}, 'LegOptions', legOptions{f}, 'ColorOptions', gramm_Strain_Acq_colors);
            end
        end
    end
    
end

function plotDailies(pT, runType, yVals, yLabs, statType, figName, figsave_type, plotSet, varargin)
    
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
        g(row,col).stat_summary('geom',{'black_errorbar','point','line'},'type', statType,'dodge',.1,'setylim',1); % set 'type' to 'sem' or 'quartile'
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
            if strcmp(runType, 'ER') 
                set(g(row,col).facet_axes_handles, 'XTick', [3 9 14 22.5 29], 'XTickLabels', {'PreT' 'W1' 'W2' 'Ext.' 'Rei.'});
            elseif strcmp(runType, 'BE')
                set(g(row,col).facet_axes_handles, 'XTick', [3 9 14 20 24], 'XTickLabels', {'PreT' 'W1' 'W2' 'BeE.' 'ReT'});
            elseif strcmp(runType, 'SA')
                set(g(row,col).facet_axes_handles, 'XTick', [3 9 14], 'XTickLabels', {'PreT' 'W1' 'W2'});
            end
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
            fullname = [figName, '_', statType, '_set', num2str(plotSet), figsave_type{fst}];
            if strcmp(figsave_type{fst}, '.pdf')
                exportgraphics(f, fullname, 'ContentType','vector')
            else
                exportgraphics(f, fullname);
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