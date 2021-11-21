function cell2csv(filename,cellArray,delimiter)
% Writes cell array content into a *.csv file.
% 
% CELL2CSV(filename,cellArray,delimiter)
%
% filename      = Name of the file to save. [ i.e. 'text.csv' ]
% cellarray    = Name of the Cell Array where the data is in
% delimiter = seperating sign, normally:',' (it's default)
%
% by Sylvain Fiedler, KA, 2004
% modified by Rob Kohr, Rutgers, 2005 - changed to english and fixed delimiter

arguments
    filename (1,1) string 
    cellArray cell
    delimiter (1,1) char = ","
end




datei = fopen(filename,'w');
for z = 1:size(cellArray,1)
    for s = 1:size(cellArray,2)
        
        variable = eval(['cellArray{z,s}']);
        
        if size(variable,1) == 0
            variable = '';
        end
        
        if isnumeric(variable) == 1
            variable = num2str(variable);
        end
        
        fprintf(datei,variable);
        
        if s ~= size(cellArray,2)
            fprintf(datei,[delimiter]);
        end
    end
    fprintf(datei,'\n');
end
fclose(datei);