function [varTable] = importMEDPCfile(filepath)
    maxLatency = 360;
    %% Import & process MedPC data
    if contains(filepath, '_Subject') || contains(filepath, '.Subject') % SS edit to avoid invalid filenames
        % Import Data Geterated By MED-PC Code
        [varTable, eventCode, eventTime] = importRatOralSA(filepath);
        
        % Calculate Variables Using Raw Data
        [varTable] = rawVariableExtractor(varTable, eventCode, eventTime, maxLatency);
    end
end