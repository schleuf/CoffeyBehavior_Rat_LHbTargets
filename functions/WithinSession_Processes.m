function [mTDL, mPressT, mDrugLT] = WithinSession_Processes(mT, dex, sub_dir, indivIntake_figs, indivIntakefigs_savepath, groupIntake_figs, groupIntakefigs_savepath, saveTabs, tabs_savepath, figsave_type,figColors)
    % Analyze Rewardeded Lever Pressing Across the Session
    mTDL_subset = intersect(dex.all, find(mT.Acquire=='Acquire')); 
    mTDL = mT(mTDL_subset, :);
    
    mPressT = table;
    mDrugLT = table;
    
    group_str = 'LHbAAV';

    wb = waitbar(0, ['Running individual within-session intake analysis... (0/' num2str(height(mTDL)) ')']);
    for i=1:height(mTDL)
        
        waitmessage = ['Running individual within-session intake analysis... (' num2str(i), '/' num2str(height(mTDL)) ')'];
        waitbar(i/height(mTDL), wb, waitmessage);

        ET = mTDL.eventTime{i};
        EC = mTDL.eventCode{i};
        doseHE = mTDL.doseHE{i};
        cumulDoseHE = cumsum(doseHE);
        rewHE = ET(EC==98);
        conc = mTDL.Concentration(i);
    
        TagNumber=repmat([mTDL.TagNumber(i)],length(rewHE),1);
        Session=repmat([mTDL.Session(i)],length(rewHE),1);
        sessionType=repmat([mTDL.sessionType(i)],length(rewHE),1);
        Sex =repmat([mTDL.Sex(i)],length(rewHE),1);
        groupComp =repmat([mTDL.(group_str)(i)],length(rewHE),1);
    
        if i==1
            mPressT = table(TagNumber, Session, rewHE, cumulDoseHE, Sex, groupComp, sessionType);
            mPressT = renamevars(mPressT,{'groupComp'},{group_str});
        else
            addTab = table(TagNumber, Session, rewHE, cumulDoseHE, Sex, groupComp, sessionType);
            addTab = renamevars(addTab,{'groupComp'},{group_str});
            mPressT=[mPressT; addTab];
        end
        
        infDur = 3; % duration of infusion in seconds SSnote: why the hell is this hardcoded all the way in here
        sessDur = 180; % duration of session in minutes SSnote: why the hell is this hardcoded all the way in here
        
        if ~isempty(rewHE)
            [DL, DLTime] = pharmacokineticsMouseOralFent('infusions',[rewHE*1000 (rewHE+(doseHE*infDur))*1000],'duration',sessDur,'type',4,'weight',mTDL.Weight(i)./1000,'mg_mL',conc/1000,'mL_S',mTDL.DoseVolume(i)/infDur);
            DL = imresize(DL', [length(DLTime),1]); % SSnote: but why
            DLTime = DLTime';
        else
            DLTime = ((1:(sessDur*60))./60)'; 
            DL = zeros([length(DLTime), 1]);
        end

        TagNumber = repmat([mTDL.TagNumber(i)],length(DL),1);
        Session = repmat([mTDL.Session(i)],length(DL),1);
        Sex = repmat([mTDL.Sex(i)],length(DL),1);
        groupComp = repmat([mTDL.(group_str)(i)],length(DL),1);
        sessionType = repmat([mTDL.sessionType(i)],length(DL),1);
    
        if i==1
            mDrugLT = table(TagNumber, Session, DL, DLTime, Sex, groupComp, sessionType);
            mDrugLT = renamevars(mDrugLT,{'groupComp'},{group_str});
        else
            addTab = table(TagNumber, Session, DL, DLTime, Sex, groupComp, sessionType);
            addTab = renamevars(addTab,{'groupComp'},{group_str});
            mDrugLT = [mDrugLT; addTab];
            
        end

        if indivIntake_figs 
            figpath = [sub_dir, indivIntakefigs_savepath, 'Tag', char(mTDL.TagNumber(i)), '_Session', char(string(mTDL.Session(i))), '_ugkgDose_and_estBrainFent'];
            indiv_sessionIntakeBrainFentFig({rewHE/60, DLTime}, {cumulDoseHE, DL(:)}, figpath, figsave_type);
        end
    end
    close(wb)

    if saveTabs
        writeTabs(mPressT, [sub_dir, tabs_savepath, 'Within_Session_Responses'], {'.mat'})
        writeTabs(mDrugLT, [sub_dir, tabs_savepath, 'Within_Session_DrugLevel'], {'.mat'})
    end

    if indivIntake_figs
        IDs=unique(mPressT.TagNumber);
        for j=1:length(IDs)
            figpath = [sub_dir, indivIntakefigs_savepath, 'Tag', char(IDs(j)), '_allSessionCumulDose'];
            indiv_allSessionFig(mPressT, mPressT.TagNumber==IDs(j), 'rewHE', "Time (m)", ...
                                'cumulDoseHE', "Cumulative Responses", ...
                                 ['ID: ' char(IDs(j))], 'Session', figpath, figsave_type, 'cumbin');

            figpath = [sub_dir, indivIntakefigs_savepath, 'Tag', char(IDs(j)), '_allSessionEstBrainFent'];
            indiv_allSessionFig(mDrugLT, mDrugLT.TagNumber==IDs(j), 'DLTime', "Time (m)", ...
                                'DL', "Estimated Brain Fentanyl (ug/kg)", ...
                                 ['ID: ' char(IDs(j))], 'Session', figpath, figsave_type, 'line');
        end

        if any(ismember(fieldnames(dex), 'BE'))

            xtick = [0 90 180];
            xticklab = ["0", "90", "180"];
            legOptions = {'lightness', 'Session'};
            for j = 1:length(IDs)
                subset = (mPressT.TagNumber == IDs(j)) & (mPressT.sessionType == 'BehavioralEconomics');
                if ~isempty(find(subset))
                    figpath = [sub_dir, indivIntakefigs_savepath, 'BE_cumulDose_overlay_Tag_', char(IDs(j))];
                    subTab = mPressT(find(subset), :);
                    grammOptions = {'lightness', subTab.Session};
                    statOptions = {'normalization','cumcount','geom','stairs','edges',0:1:180};
                    pointOptions = {'markers',{'o','s'},'base_size',10};  
                    gramm_GroupFig(subTab, "rewHE", "cumulDoseHE", "Time (m)", "Cumulative Responses", ...
                                   figpath, figsave_type, 'GrammOptions', grammOptions, 'LegOptions', legOptions, 'StatOptions', statOptions, 'PointOptions', pointOptions);
                end
                subset = (mDrugLT.TagNumber == IDs(j)) & (mDrugLT.sessionType == 'BehavioralEconomics');
                if ~isempty(find(subset))
                    figpath = [sub_dir, indivIntakefigs_savepath, 'BE_estBrainFent_overlay_Tag_', char(IDs(j))];
                    subTab = mDrugLT(find(subset), :);
                    grammOptions = {'lightness', subTab.Session};
                    statOptions = {'area'};
                   
                    gramm_GroupFig(subTab, "DLTime", "DL", "Time (m)", "Estimated Brain Fentanyl (ug/kg)", ...
                                   figpath, figsave_type, 'GrammOptions', grammOptions, 'LegOptions', legOptions);    
                end
            end
        end
    end
    
    if groupIntake_figs   
        axOptions = {'LineWidth',1.5,'FontSize',10,'XLim',[0 180],'tickdir','out'};
        legOptions = {'color', 'Sex'};
        colorOptions = {{'hue_range',[40 310],'lightness_range',[95 65],'chroma_range',[50 90]},...
            {'hue_range',[85 -200],'lightness_range',[85 75],'chroma_range',[75 90]}};
        
        treatments = unique(mT.(group_str));
        
        % Drug Level by Treatment group during Training
        figpath = [sub_dir, groupIntakefigs_savepath, 'Drug Level Grouped by Treatment during Training'];
        subset = (mDrugLT.sessionType == 'Training' | mDrugLT.sessionType == 'PreTraining');
        grammOptions = {'lightness', mDrugLT.(group_str), 'subset', subset};
        statOptions = {'geom', 'area', 'type', 'quartile', 'setylim', 1};
        wrapOptions = {mDrugLT.Session,'scale','independent','ncols',5,'column_labels',1}; %'force_ticks',1,
        gramm_GroupFig(mDrugLT, "DLTime", "DL", "Time (m)", "Estimated Brain Fentanyl (ug/kg)", figpath, figsave_type, ...
            'GrammOptions', grammOptions, 'StatOptions', statOptions, 'WrapOptions', wrapOptions, 'AxOptions', axOptions, 'LegOptions', legOptions,'ColorOptions',colorOptions{1})

        % Drug Level by Treatment group during Training - Males
        figpath = [sub_dir, groupIntakefigs_savepath, 'Drug Level Grouped by Treatment during Training_Male'];
        subset = (mDrugLT.sessionType == 'Training' | mDrugLT.sessionType == 'PreTraining') & mDrugLT.Sex == 'Male';
        grammOptions = {'lightness', mDrugLT.(group_str), 'subset', subset};
        statOptions = {'geom', 'area', 'type', 'quartile', 'setylim', 1};
        wrapOptions = {mDrugLT.Session,'scale','independent','ncols',5,'column_labels',1}; %'force_ticks',1,
        gramm_GroupFig(mDrugLT, "DLTime", "DL", "Time (m)", "Estimated Brain Fentanyl (ug/kg)", figpath, figsave_type, ...
            'GrammOptions', grammOptions, 'StatOptions', statOptions, 'WrapOptions', wrapOptions, 'AxOptions', axOptions, 'LegOptions', legOptions,'ColorOptions',colorOptions{1})

        % Drug Level by Treatment group during Training - Females
        figpath = [sub_dir, groupIntakefigs_savepath, 'Drug Level Grouped by Treatment during Training_Female'];
        subset = (mDrugLT.sessionType == 'Training' | mDrugLT.sessionType == 'PreTraining') & mDrugLT.Sex == 'Female';
        grammOptions = {'lightness', mDrugLT.(group_str), 'subset', subset};
        statOptions = {'geom', 'area', 'type', 'quartile', 'setylim', 1};
        wrapOptions = {mDrugLT.Session,'scale','independent','ncols',5,'column_labels',1}; %'force_ticks',1,
        gramm_GroupFig(mDrugLT, "DLTime", "DL", "Time (m)", "Estimated Brain Fentanyl (ug/kg)", figpath, figsave_type, ...
            'GrammOptions', grammOptions, 'StatOptions', statOptions, 'WrapOptions', wrapOptions, 'AxOptions', axOptions, 'LegOptions', legOptions,'ColorOptions',colorOptions{1})


        for t = 1:length(treatments)
            this_group = treatments(t);
    
            % Drug Level by Sex during Training
            figpath = [sub_dir, groupIntakefigs_savepath, 'Drug Level Grouped by Sex during Training_', char(this_group)];
            subset = (mDrugLT.sessionType == 'Training' | mDrugLT.sessionType == 'PreTraining') & mDrugLT.(group_str) == this_group;
            grammOptions = {'color', mDrugLT.Sex, 'subset', subset};
            statOptions = {'geom', 'area', 'type', 'quartile', 'setylim', 1};
            wrapOptions = {mDrugLT.Session,'scale','independent','ncols',5,'column_labels',1}; %'force_ticks',1,
            gramm_GroupFig(mDrugLT, "DLTime", "DL", "Time (m)", "Estimated Brain Fentanyl (ug/kg)", figpath, figsave_type, ...
                          'GrammOptions', grammOptions, 'StatOptions', statOptions, 'WrapOptions', wrapOptions, 'AxOptions', axOptions, 'LegOptions', legOptions,'ColorOptions',colorOptions{t})
           
           
            % Drug Level by Sex during Training Sessions 5, 10, 15
            figpath = [sub_dir, groupIntakefigs_savepath, 'Drug Level Grouped by Sex - Session 5 10 15_', char(this_group)];
            subset = (mDrugLT.Session==5 | mDrugLT.Session==10 | mDrugLT.Session==15) & mDrugLT.(group_str) == this_group;
            grammOptions = {'color', mDrugLT.Sex, 'subset', subset};
            statOptions = {'geom', 'area', 'setylim', 1, 'type', 'quartile',};
            wrapOptions = {mDrugLT.Session,'scale','independent','ncols',3,'column_labels',1}; %'force_ticks',1,
            gramm_GroupFig(mDrugLT, "DLTime", "DL", "Time (m)", "Estimated Brain Fentanyl (ug/kg)", figpath, figsave_type, ...
                           'GrammOptions', grammOptions, 'StatOptions', statOptions, 'WrapOptions', wrapOptions, 'AxOptions', axOptions, 'LegOptions', legOptions,'ColorOptions',colorOptions{t})
    
    
            % Cumulative responses (rewarded head entries) by Sex during Training Sessions 5, 10, 15
            figpath = [sub_dir, groupIntakefigs_savepath, 'Cumulative Responses Grouped by Sex and Session 5 10 15_', char(this_group)];
            subset = ((mPressT.Session==5 | mPressT.Session==10 | mPressT.Session==15) & mPressT.(group_str) == this_group);
            grammOptions = {'color', mPressT.Sex, 'subset', subset};
            statOptions = {'normalization','cumcount','geom','stairs','edges',0:1:180};
            wrapOptions = {mPressT.Session,'scale','independent','ncols',3,'column_labels',1}; %'force_ticks',1,
            gramm_GroupFig(mPressT, "rewHE", "cumulDoseHE", "Time (m)", "Cumulative Responses", figpath, figsave_type, ...
                           'GrammOptions', grammOptions, 'StatOptions', statOptions, 'WrapOptions', wrapOptions, 'AxOptions', axOptions, 'LegOptions', legOptions,'ColorOptions',colorOptions{t})        
    
        end
    end
end