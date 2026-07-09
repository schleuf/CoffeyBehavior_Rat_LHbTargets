function [LME_stats] = getLMEstats(data, dep_var, lme_form, excludenans)
    LME_stats = struct;
    exclude_log = zeros([size(data,1), 1]);
    if excludenans
        for d = 1:length(dep_var)
            nan_ind = isnan(data.(dep_var{d}));
            exclude_log(nan_ind) = exclude_log(nan_ind)+ 1; 
        end
    end

    for dv = 1:length(dep_var)
        if excludenans
            LME_stats.(strcat(dep_var(dv), "LME")) = fitlme(data, strcat(dep_var(dv), lme_form), 'Exclude', find(exclude_log));
        else
            LME_stats.(strcat(dep_var(dv), "LME")) = fitlme(data, strcat(dep_var(dv), lme_form));
        end
        LME_stats.(strcat(dep_var(dv), "F")) = anova(LME_stats.(strcat(dep_var(dv), "LME")) ,'DFMethod','satterthwaite');
    end
end