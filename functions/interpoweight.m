function [mT] = interpoweight(mT, expKey)
    % get days that weights were collected for each run
    runs = unique(expKey.Run);
    weightsess_by_run = dictionary;
    for r = 1:length(runs)
        weightsess_inds = find(expKey.WeightTaken(expKey.Run == runs(r)));
        if ~isempty(weightsess_inds)
            weightsess_by_run(string(runs(r))) = {expKey.Session(weightsess_inds)};
        else
            weightsess_by_run(string(runs(r))) = {nan};
        end
    end

    ids = unique(mT.ID);
    for t = 1:length(ids)
        weights = mT.Weight(mT.ID == ids(t));
        sessions = mT.Session(mT.ID == ids(t));
        days = mT.Date(mT.ID == ids(t)); 
        this_run = unique(mT.Run(mT.ID == ids(t)));
        interp_sessions = weightsess_by_run{string(this_run)};

        % figure
        % hold on
        % plot(sessions, weights)
        % title(ids(t))
        % hold off
        
        temp = weights;
        for s = 1:length(interp_sessions)-1
            w1 = weights(sessions == interp_sessions(s));
            w2 = weights(sessions == interp_sessions(s+1));
            d1 = days(sessions == interp_sessions(s));
            d2 = days(sessions == interp_sessions(s+1));

            if ~isempty(w1) && ~isempty(w2)
                numdays = daysact(d1, d2);
                try
                    interp = linspace(w1, w2, numdays+1);
                catch
                    disp('help')
                end
                
                %get rid of elements corresponding to dates sessions did
                %not occur (usually weekends)
                dump = zeros(length(interp), 1);
                for n = 1:numdays
                    if ~any(arrayfun(@(x) x==d1+n-1, days))
                        dump(n) = 1;
                    end
                end
                interp(find(dump)) = [];

                for i = 1:length(interp)
                    temp(sessions == interp_sessions(s) + i - 1) = interp(i);
                end
            end
        end
        mT.Weight(mT.ID == ids(t)) = temp;
        
        % hold on
        % plot(sessions, temp)
        % hold off
    end
end