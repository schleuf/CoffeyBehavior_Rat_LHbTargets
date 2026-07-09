function [mT] = createMasterTable(beh_datapath, masterKey_flnm, experimentKey_flnm, savename, maxLatency)
    showWarnings = false;
    
    % Import Master Key
    opts = detectImportOptions(masterKey_flnm);
    opts = setvartype(opts,{'TagNumber','ID','Cage','Sex','TimeOfBehavior', 'LHbTarget', 'LHbAAV'},'categorical'); % Must be variables in the master key
    mKey=readtable(masterKey_flnm,opts);
    
    % Import Experiment Keyp.
    expKey = readtable(experimentKey_flnm);
    
    %% Import & process MedPC data
    mT=table; % Initialize Master Table
    
    for bd = 1:length(beh_datapath) % SS edit to pull data from multiple folders
        Files = dir(beh_datapath{bd});
        Files = Files(1:height(Files));
        startIdx = 1; % Current Wave Only
        disp(['Pulling ', num2str(length(Files)), '...']) % height(Files)-i);
        wb = waitbar(0, ['Importing data... (0/', num2str(height(Files)), ')']);
        
        for i=startIdx:height(Files) % Loop all behavior files
            waitmessage = ['Importing data... (', num2str(i),'/',num2str(height(Files)),')'];
            waitbar(i/height(Files), wb, waitmessage);
            
            if contains(Files(i).name, '_Subject') || contains(Files(i).name, '.Subject') % SS edit to avoid invalid filenames
                % Import Data Geterated By MED-PC Code
                [varTable, eventCode, eventTime] = importRatOralSA(fullfile(Files(i).folder, Files(i).name));
                
                % Flags to extract totals from medPC files that erroneously
                % did not do event-logging...
                if varTable.Date == datetime('30-Jun-2026') || ...
                   varTable.Date == datetime('01-Jul-2026') || ...
                   varTable.Date == datetime('02-Jul-2026') || ...
                   varTable.Date == datetime('03-Jul-2026') || ...
                   varTable.Date == datetime('04-Jul-2026')
                    recountTotals = false;
                else
                    recountTotals = true; 
                end

                % Calculate Variables Using Raw Data
                [varTable] = rawVariableExtractor(varTable, eventCode, eventTime, maxLatency, recountTotals);

                % Find this animal's index in mKey
                IDtag = varTable.TagNumber(height(varTable));
                if contains(char(IDtag), '_')
                    split = strsplit(char(IDtag), '_');
                    tag = categorical(string(split{2}));
                    id = categorical(string(split{1}));
                    mKey_ind = find(mKey.TagNumber==tag & mKey.ID == id);
                else
                    id = IDtag;
                    mKey_ind = find(mKey.ID == id);
                    tag = mKey.TagNumber(mKey_ind);
                end

                varTable.TagNumber = tag;
                varTable.ID = id;
     
                % Get experiment type from logical indexing in mKey
                if mKey.Extinction(mKey_ind) && mKey.Reinstatement(mKey_ind) && ~mKey.BehavioralEconomics(mKey_ind)
                    Experiment = categorical("ER");
                elseif mKey.BehavioralEconomics(mKey_ind) % don't exclude based on indication of extinction and reinstatement in mKey so we can keep the BE data from run 2
                    Experiment = categorical("BE");
                elseif mKey.SelfAdministration
                    Experiment = categorical("SA");
                else
                    Experiment = categorical("undefined");
                end
                
                % Get session type, fentanyl concentration, and intake from expKey
                fl_date = varTable.Date(height(varTable));
                expKey_ind = find(datetime(expKey.Date) == fl_date & strcmp(expKey.Experiment,string(Experiment))); % both cases necessary for when multiple experiments are run on the same day (run 4)
                
                if isempty(expKey_ind) | length(expKey_ind) > 1
                    % Code's only set up for 'BE' and 'ER' experiments (w/ ability to section out the 'SA' sessions) 
                    % Call anything else undefined
                    if showWarnings
                        disp(['cannot add session type or intake data for ', fullfile(Files(i).folder, Files(i).name)])
                    end
                    Intake = NaN;
                    totalIntake = NaN;
                    Concentration = NaN;
                    DoseVolume = NaN;
                    Run = NaN;
                    sessionType = categorical("undefined");
                else
                    % Read concentration & dose volume per dose from Experiment Key to calculate drug intake
                    Weight = varTable.Weight;
                    Concentration = expKey.FentanylConcentration_ug_ml_(expKey_ind);
                    DoseVolume = expKey.VolumePerDose_mL_(expKey_ind);
                    Intake = (DoseVolume * Concentration * varTable.EarnedInfusions(height(varTable))) / (Weight/1000);
                    totalIntake = DoseVolume * Concentration * varTable.TotalInfusions(height(varTable));
                    Run = expKey.Run(expKey_ind);
                    sessionType = categorical(string(expKey.SessionType{expKey_ind}));
                end

                % slideSession - Slide Days for looks
                if sessionType == 'SaccharineTraining'
                    slideSession = varTable.Session;
                elseif sessionType == 'PreTraining' || sessionType == 'SaccharineFade'
                    slideSession = varTable.Session;
                elseif sessionType == 'Training' || sessionType == 'OpiateTraining'
                    slideSession = varTable.Session + 1;
                elseif sessionType == 'Extinction' || sessionType == 'BehavioralEconomics'
                    slideSession = varTable.Session + 2;
                elseif sessionType == 'Reinstatement' || sessionType == 'ReTraining'
                    slideSession = varTable.Session + 3;
                else
                    slideSession = varTable.Session;
                end

                % % Special case latency calc for Extinction trials
                % if sessionType == 'Extinction'
                %     EC = varTable.eventCode{1};
                %     ET = varTable.eventTime{1};
                %     actLP = ET(EC==22);
                %     HE = ET(EC==95);
                %     seekHE = arrayfun(@(x) find(HE > x, 1, 'first'), actLP, 'UniformOutput', false);
                %     seekHE = HE(unique(cell2mat(seekHE(~cellfun(@isempty, seekHE)))));
                %     seekLP = arrayfun(@(x) find(actLP < x, 1, 'last'), seekHE, 'UniformOutput', false);
                %     seekLP = actLP(unique(cell2mat(seekLP(~cellfun(@isempty, seekLP)))));
                %     allLatency = seekHE-seekLP;
                %     allLatency = allLatency(allLatency <= maxLatency);
                %     varTable.allLatency = {allLatency};
                %     varTable.Latency = mean(allLatency);
                % end

                % % Catch for instances where infusion event codes were still
                % % being triggered by lever presses despite cues and
                % % infusions not being triggered
                % if sessionType == 'Extinction' || sessionType == 'Reinstatement' 
                %     varTable.EarnedInfusions = 0;
                % end
                
                % Concatenate the Master Table
                drugIntakeTab = table(sessionType, slideSession, Experiment, Run, Concentration, DoseVolume, Intake, totalIntake);
                if varTable.EarnedInfusions < 0 
                    disp(varTable.Date)
                    disp(varTable.Session)
                    disp(varTable.TagNumber)
                    disp(varTable.EarnedInfusions)
                    disp(' ')
                end

                mT = [mT; [varTable, drugIntakeTab]];
            end
        end
        close(wb)
    end
    
    % Join Master Variable Table with Key to Include Grouping Variables
    
    mT=innerjoin(mT,mKey,'Keys',{'ID'},'RightVariables',{'Sex','TimeOfBehavior','Chamber', 'LHbTarget', 'LHbAAV'});
    
    %%
    save(savename,'mT');
    
    correctFiles = true;
    mT = checkSessionDates(mT, mKey, expKey, correctFiles, savename);
    
end