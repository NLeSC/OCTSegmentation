function number = getInfoTableColumn(guiMode, descriptor)
% GETINFOTABLECOLUMN: Returns the column number in the octsegMain 
% Info table of the descriptor, and within a certain guiMode

global TABLE_HEADERS

number = 0;
for i = 1:numel(TABLE_HEADERS{guiMode})
    if strcmp(TABLE_HEADERS{guiMode}{i}, descriptor)
        number = i;
        return;
    end
end
