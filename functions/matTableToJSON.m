folder = 'C:\Users\schle\OneDrive\Documents\GitHub\CoffeyBehavior_Rat_LHbTargets\';
datafile = [folder, 'data_masterTable.mat'];
savename = 'medPC_JSON_table.json';
mattab = load(datafile).mT;

% Convert the table to a struct, then to JSON
S = table2struct(mattab, 'ToScalar', true);
jsonText = jsonencode(S);
writelines(jsonText, [folder, savename]);