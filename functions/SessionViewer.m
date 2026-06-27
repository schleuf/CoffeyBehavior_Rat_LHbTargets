function [] = SessionViewer(filepath) 
    stampKey = readtable('MedPC_EventStampKey_VTA4SA-06-26.csv');
    stampCol = stampKey{:,1};

    varTable = importMEDPCfile(filepath);
    eventCode = varTable.eventCode{1};
    eventTime = varTable.eventTime{1};
    uniCode = unique(eventCode);
    
    eventString = {};


    % print as sequence of eventnames with timestamps next to them
    disp(' ')
    disp(filepath)
    disp('EVENT STAMPS')
    disp('--------------------------------------')
    disp(' ')
   
    for row = 1:size(eventCode,1)
        stamp = eventCode(row);
        key_row = find(stampCol == stamp);
        if isempty(key_row)
            eventStr = 'Unknown';
        else
            eventStr = stampKey{key_row, 2}{1};
        end
        disp([num2str(eventTime(row)), '  :  ', eventStr, ' (', num2str(stamp), ')'])
        eventString{row} = eventStr;
    end

    % rasterize
    marker = 'x';

    figure
    hold on
   
    for u = 1:length(uniCode)
        stamp = uniCode(u);
        stampTime = eventTime(eventCode == stamp);
        key_row = find(stampCol == stamp);
        if isempty(key_row)
            eventStr = 'Unknown';
        else
            eventStr = stampKey{key_row, 2}{1};
        end

        text(75, u, eventStr, 'HorizontalAlignment', 'right')
        scatter(stampTime, repmat(u, length(stampTime)), marker);
    end

    disp('woo')
end