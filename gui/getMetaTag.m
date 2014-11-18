function tag = getMetaTag(descriptor, type)
% GETMETATAG: Returns meta tag for a certain descriptor
% Needs the gloabl variable TABLE_META_TAGS
% Parameters:
%   descriptor: The descriptor you search the associated tag with 
%       For a list of the descriptors, have a look at:
%       octsegConstantVariables 
%   type: Do you want to have the automated segmentation ('auto) or manual
%       segmentation ('man') tag? Do you want to have just the information
%       if the segmentation was perforemd or the associated data 
%       ('autoData'/'manData') 
%       Or both tags (auto/man) together in a cell array?
% Return value:
%   tag: The meta tag associated with the descriptor 
global TABLE_META_TAGS;

for i = 1:size(TABLE_META_TAGS,1)
    if strcmp(TABLE_META_TAGS{i, 1}, descriptor)
        switch type
            case 'auto'
                tag = TABLE_META_TAGS{i, 2};
            case 'man'
                tag = TABLE_META_TAGS{i, 3};
            case 'autoData'
                tag = [TABLE_META_TAGS{i, 2} 'Data'];
            case 'manData'
                tag = [TABLE_META_TAGS{i, 3} 'Data'];
            case 'both'
                tag = {TABLE_META_TAGS{i, 2} TABLE_META_TAGS{i, 3}};
            case 'bothData'
                tag = {[TABLE_META_TAGS{i, 2} 'Data'] ...
                       [TABLE_META_TAGS{i, 3} 'Data']};
            otherwise
                disp('getMetaTag: type not known (other than auto/man)!');
                return;
        end
        
        break;
    end
end

end