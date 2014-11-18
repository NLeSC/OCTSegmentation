function newValue = setMenuEntryChecked(handle, value)
% SETMENUENTRYCHECKED: Set the "check" of the menu entry given by handle
% to either 'on' or 'off' given by the value
% Parameters:
%   handle: Handle to the menu entry
%   value: Either 0 (off) or 1 (on)
% Return:
%   newValue: Just a copy of value;
if value 
    set(handle, 'Checked', 'on');
else
    set(handle, 'Checked', 'off');
end

newValue = value;