function [ivT] = GetMetrics(mT)
    
    IVmetrics = ["ID", "Sex", "LHbAAV", "Acquire", "Intake", "Seeking", "Association", "Escalation"...
                 "Extinction", "Persistence", "Flexibility", "Relapse", "Recall"];  
    numNonMets = 4; % refers to the first 3 elements of IVmetrics being labels rather than numeric metrics
    ID = unique(mT.TagNumber);

    % Individual Variable Table
    ivT = table('Size', [length(ID), length(IVmetrics)], 'VariableTypes', ...
               [repmat({'categorical'}, [1,numNonMets]), repmat({'double'}, [1, length(IVmetrics) - numNonMets])], ...
                'VariableNames', IVmetrics);
    ivT{:, IVmetrics(numNonMets + 1:end)} = nan;
    
    for i=1:length(ID)
        this_ID = mT.TagNumber == ID(i);
        ivT.ID(i) = ID(i);
        ivT.Sex(i) = unique(mT.Sex(this_ID));
        ivT.LHbAAV(i) = unique(mT.LHbAAV(this_ID));
        ivT.Acquire(i) = unique(mT.Acquire(this_ID));
        ivT.Intake(i) = nanmean(mT.Intake(this_ID & mT.sessionType == 'Training'));
        ivT.Seeking(i) = nanmean(mT.HeadEntries(this_ID &  mT.sessionType =='Training'));
        ivT.Association(i)= 1/log(nanmean(mT.HE_median_cue_latency(this_ID & mT.sessionType == 'Training'))); 
        e = polyfit(double(mT.Session(this_ID & mT.sessionType == 'Training')), ...
                           mT.TotalInfusions(this_ID & mT.sessionType =='Training'),1);
        ivT.Escalation(i)=e(1);
        if isnan(ivT.Association(i))
            ivT.Association(i) = 0;
        end

        if ~isempty(find(this_ID & (mT.sessionType == 'Extinction')))

            ivT.Extinction(i)= nanmean(mT.ActiveLever(this_ID & mT.sessionType == 'Extinction'));
            p = polyfit(double(mT.Session(this_ID & mT.sessionType == 'Extinction')), ...
                               mT.ActiveLever(this_ID & mT.sessionType == 'Extinction'),1);
            ivT.Persistence(i) = 0 - p(1);
            ivT.Flexibility(i) = nanmean(mT.InactiveLever(this_ID & mT.sessionType == 'Extinction'));

        if ~isempty(find(this_ID & (mT.sessionType == 'Reinstatement')))
            ivT.Relapse(i) = mT.ActiveLever(this_ID & mT.sessionType == 'Reinstatement');
            ivT.Recall(i) = 1/log(mT.HE_median_cue_latency(this_ID & mT.sessionType == 'Reinstatement'));
            if isnan(ivT.Recall(i))
                ivT.Recall(i) = 0;
            end
        end
    end   
end