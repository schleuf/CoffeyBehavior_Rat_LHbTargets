function [varTable] = rawVariableExtractor(varTable, eventCode, eventTime, maxLatency, recountTotals)
% rawVariableExtractor takes the raw event times for mouse oral SA and
% calculates variables of interest and adds them to the varTable
%
% INPUTS: varTable, eventCode, eventTime - Direct outputs of "importMouseOralSA"
%
% OUTPUTS: varTable (Updated with variables calculated or cleaned below)
%
% SSnote: update output variable list
% Variables added to or modified from varTable:
%    HeadEntries: # head entries (filtered to remove headentries <2s apart)
%    RewardedHeadEntries: # head entries occurring after a lever press 
%    RewardedLeverPresses: # active lever presses with a head entry before the next activelever press
%    DoseHE: # of infusions per rewarded head entry
%    allLatency: latencies from rewarded lever presses to first head entry (unless no head entry occurs before next rewarded press)
%    Latency: Avg. time from each rewarded lever press to first head entry
%    eventCode: original eventCode appended with new event codes (see below)
%    eventTime: original eventTime appended with new event times (see below)
% 
% events added to eventCode and eventTime:
%    95 time-filtered head entries
%    97 rewarded lever presses preceding head entries
%    98 head entries following infusions, used for fentanyl intake estimates
%    99 head entries following contingent rewards (does not include head entries following non-contingent infusions)
%    90 noncontingent rewards
%    91 cues with no head entries within maxLatency seconds 

    HE_timeFilt = 2;

    % Change Subject to TagNumber to Match the Key
    varTable.Properties.VariableNames{'Subject'} = 'TagNumber';

    % Pull times of events
    time_prefiltHE = eventTime(eventCode == 6); % head entry
    time_inf = eventTime(eventCode == 17); % infusion on
    time_cue = eventTime(eventCode == 13); % tone on
    time_actLP = eventTime(eventCode == 22); % active lever press
    time_inaLP = eventTime(eventCode == 23); % inactive lever press
    time_iti_actLP = eventTime(eventCode == 20); % active lever press
    time_iti_inaLP = eventTime(eventCode == 21); % inactive lever press
    time_rewLP = eventTime(eventCode == 3 | eventCode == 4); % rewarded lever press
    
    % get counts of variables that don't require further processing
    if recountTotals
         varTable.ActiveLever = length(time_actLP);
         varTable.InactiveLever = length(time_inaLP);
         varTable.TotalInfusions = length(time_inf);
         varTable.EarnedInfusions = length(time_rewLP);
    end
    varTable.itiActiveLever = length(time_iti_actLP);
    varTable.itiInactiveLever = length(time_iti_inaLP);

    % ---------------- HEAD ENTRY FILTERING ----------------------------
    % filter head entries, remove entries that happen within  HE_timeFilt(s) of each other    
    remove_inds = logical([0; diff(time_prefiltHE) < HE_timeFilt]);
    time_HE = time_prefiltHE;
    time_HE(remove_inds) = [];

    varTable.HeadEntries = length(time_HE); 
      
    % filter head entries following lever presses, cues, and infusions
    time_HE_after_actLP = firstBeforeAfter(time_HE, 'after', time_actLP, true); 
    time_HE_after_rewLP = firstBeforeAfter(time_HE, 'after', time_rewLP, true); 
    time_HE_after_cue = firstBeforeAfter(time_HE, 'after', time_cue, true); 
    time_HE_after_inf = firstBeforeAfter(time_HE, 'after', time_inf, true); % needed for fentanyl intake estimates
    
    time_actLP_before_HE = firstBeforeAfter(time_actLP, 'before', time_HE, true); 
    time_rewLP_before_HE = firstBeforeAfter(time_rewLP, 'before', time_HE, true); 
    time_cue_before_HE = firstBeforeAfter(time_cue, 'before', time_HE, true);
    time_inf_before_HE = firstBeforeAfter(time_inf, 'before', time_HE, true);
    
    varTable.rewardedHeadEntries = length(time_HE_after_inf);
    
    % Compute the number of infusions before the first head entry following infusions
    % (used to estimate fentanyl intake timing: doses per head entry)
    doseHE = arrayfun(@(x) sum(time_inf < x), time_HE_after_inf); 
    if ~isempty(doseHE)
        doseHE = [doseHE(1); diff(doseHE)]; % Compute the difference between successive elements to get the count per interval
    end
    varTable.doseHE = {doseHE};


    % --------- LATENCIES-------------------------------

    % calculate head entry latencies for...
    % ...active lever presses
    [varTable.HE_latencies_actLP{1}, varTable.HE_median_actLP_latency] = latencyCalcs(time_actLP_before_HE, time_HE_after_actLP, maxLatency);
    % ...rewarded lever presses,
    [varTable.HE_latencies_rewLP{1}, varTable.HE_median_rewLP_latency] = latencyCalcs(time_rewLP_before_HE, time_HE_after_rewLP, maxLatency);
    % ...cues
    [varTable.HE_latencies_cue{1}, varTable.HE_median_cue_latency] = latencyCalcs(time_cue_before_HE, time_HE_after_cue, maxLatency);


    % ------------------ NONCONTINGENT & UNPURSUED REWARDS ----------------------
    % event code for noncontingent k-pulse rewards was added pretty late,
    % and isn't triggered by the task-initiation rewards
    time_nonCont_rew = [];
    inf_w_rewLP = arrayfun(@(x) find(abs(time_rewLP - x) < .1), time_inf, 'UniformOutput', false);
    ind_nonCont_rew = find(cellfun(@(x) isempty(x), inf_w_rewLP));
    if ~isempty(ind_nonCont_rew)
        time_nonCont_rew = [time_nonCont_rew; time_inf(ind_nonCont_rew)];
    end

    varTable.NoncontingentRewards = length(time_nonCont_rew);
    
    time_unpurs_cue = [];
    ind_unpurs_cue = find((time_HE_after_cue - time_cue_before_HE) > maxLatency);
    if ~isempty(ind_unpurs_cue)
        time_unpurs_cue = time_cue_before_HE(ind_unpurs_cue);
    end
    varTable.UnpursuedCues = length(time_unpurs_cue);


    % ------------------ INTERVALS ----------------------------------
    varTable.interval_actLP{1} = diff(time_actLP); 
    varTable.median_interval_actLP = median(varTable.interval_actLP{1}, 'omitmissing');
    
    varTable.interval_rewLP{1} = diff(time_rewLP);
    varTable.median_interval_rewLP = median(varTable.interval_rewLP{1}, 'omitmissing');

    varTable.interval_HE{1} = diff(time_HE);
    varTable.median_interval_HE = median(varTable.interval_HE{1}, 'omitmissing');    
    
    if ~isempty(time_actLP)
        varTable.time_first_actLP = time_actLP(1);
    else
        varTable.time_first_actLP = nan;
    end
    

    % ------------------ POST-HOC EVENT CODES ----------------------------
    
    % append eventCode and eventTime for new variables 
    eventCode=[eventCode; ...
               repmat(90, [height(time_nonCont_rew), 1]); ...
               repmat(91, [height(time_unpurs_cue), 1]); ...
               repmat(95, [height(time_HE), 1]); ...
               repmat(96, [height(time_inf_before_HE)]); ...
               repmat(97,[height(time_rewLP_before_HE),1]); ...
               repmat(98,[height(time_HE_after_inf),1]); ...
               repmat(99,[height(time_HE_after_rewLP),1])];
               
    
    eventTime = [eventTime; ...
                 time_nonCont_rew; ... % noncontingent rewards
                 time_unpurs_cue; ... % cues with no head entry within maxLatency seconds
                 time_HE; ... % filtered head entries
                 time_inf_before_HE; ...
                 time_rewLP_before_HE; ... % SSnote: does this need an event code? 
                 time_HE_after_inf; ... % head entries after infusions, used for fentanyl intake estimates
                 time_HE_after_rewLP]; % head entries after contingent rewards SSnote: does this need an event code? 

    varTable.eventCode={eventCode};
    varTable.eventTime={eventTime};


    % ------------------ HELPER FUNCTIONS -------------------- 

    function [times] = firstBeforeAfter(A, direction, B, uni)
        if strcmp(direction, 'before')
            times = arrayfun(@(x) A(find(A < x, 1, 'last')), B, 'UniformOutput', false);
            times = cell2mat(times(~cellfun(@isempty, times)));     
        elseif strcmp(direction, 'after')
            times = arrayfun(@(x) A(find(A > x, 1, 'first')), B, 'UniformOutput', false);
            times = cell2mat(times(~cellfun(@isempty, times)));
        else
            disp('bad "direction" entry to whenBeforeAfter')
            times = [nan];
        end
        if uni 
            times = unique(times, 'stable');
        end
    end


    function [lats, med_lat] = latencyCalcs(first, second, maxLatency)
        lats = second - first;
        lats = lats(lats <= maxLatency); 
        if isempty(lats)
            med_lat = NaN;
        else
            med_lat = quantile(lats, 0.5); 
        end

    end
end