function [mT] = removeExcludedData(mT, mKey)
    % exclude animals
    sub_RemAll = find(~mKey.IncludeBehavior);
    for sub = 1:length(sub_RemAll)
        tag = mKey.TagNumber(sub_RemAll(sub));
        inds = mT.TagNumber == tag; 
        mT(inds, :) = [];
    end

    % exclude sessions of included animals
    RemoveSession = zeros([length(mT.Chamber),1]);
    sub_RemSess = mKey.RemoveSession;
    for sub = 1:length(sub_RemSess)
        sess = sub_RemSess{sub}(2:end-1);
        if ~isempty(sess)
            sess = strsplit(sess, ' ');
            tag = mKey.TagNumber(sub);
            for s = 1:length(sess)
                ind = find((mT.TagNumber == tag) .* (mT.Session == str2double(sess{s})));
                RemoveSession(ind) = 1;
            end
        end      
    end
    mT(find(RemoveSession),:) = [];
end
