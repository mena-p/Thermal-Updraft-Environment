function derived = derived_to_table(filename, startRow, endRow)
% Usage: data = derived_to_table('GMM00010868-drvd.txt',3,78);
% This function extracts the derived atmospheric parameters in the rows
% startRow to endRow of the file 'filename'. WARNING: this function should
% not be used to parse header lines. It can only parse lines
% containing actual derived parameters. The function was generated by
% MATLAB and some adjustments were made to clean the data.

% Auto-generated by MATLAB on 2024/07/05 16:35:33

%% Initialize variables.
if nargin<=2
    startRow = 2;
    endRow = 27;
end

%% Format for each line of text:
%   column1: double (%f)
%	column2: double (%f)
%   column3: double (%f)
%	column4: double (%f)
%   column5: double (%f)
%	column6: double (%f)
%   column7: double (%f)
%	column8: double (%f)
%   column9: double (%f)
%	column10: double (%f)
%   column11: double (%f)
%	column12: double (%f)
%   column13: double (%f)
%	column14: double (%f)
%   column15: double (%f)
%	column16: double (%f)
%   column17: double (%f)
%	column18: double (%f)
%   column19: double (%f)
% For more information, see the TEXTSCAN documentation.
formatSpec = '%7f%8f%8f%8f%8f%8f%8f%8f%8f%8f%8f%8f%8f%8f%8f%8f%8f%8f%8f%[^\n\r]';

%% Open the text file.
fileID = fopen(filename,'r');

%% Read columns of data according to the format.
% This call is based on the structure of the file used to generate this code. If an error occurs for a different file, try regenerating the code from the Import Tool.
dataArray = textscan(fileID, formatSpec, endRow(1)-startRow(1)+1, 'Delimiter', '', 'WhiteSpace', '', 'TextType', 'string', 'HeaderLines', startRow(1)-1, 'ReturnOnError', false, 'EndOfLine', '\r\n');
for block=2:length(startRow)
    frewind(fileID);
    dataArrayBlock = textscan(fileID, formatSpec, endRow(block)-startRow(block)+1, 'Delimiter', '', 'WhiteSpace', '', 'TextType', 'string', 'HeaderLines', startRow(block)-1, 'ReturnOnError', false, 'EndOfLine', '\r\n');
    for col=1:length(dataArray)
        dataArray{col} = [dataArray{col};dataArrayBlock{col}];
    end
end

%% Close the text file.
fclose(fileID);

%% Create output variable
derived = table(dataArray{1:end-1}, 'VariableNames', {'PRESS','REPGPH','CALCGPH','TEMP','TEMPGRAD','PTEMP','PTEMPGRAD','VTEMP','VPTEMP','VAPPRESS','SATVAP','REPRH','CALCRH','RHGRAD','UWND','UWNDGRAD','VWND','VWNDGRAD','N'});
%% Replace missing values with NaN
derived = standardizeMissing(derived,-99999);