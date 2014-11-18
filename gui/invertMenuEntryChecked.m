function newValue = invertMenuEntryChecked(handle, currentValue)
% INVERTMENUENTRYCHECKED: Invert the "check" of the menu entry
% given by the value. Returns new value (0 for 'off' or 1 for 'on')
% Parameters:
%   handle: Handle to the menu entry
%   currentValue: Either 0 (off) or 1 (on)

if currentValue 
    set(handle, 'Checked', 'off');
    newValue = 0;
else
    set(handle, 'Checked', 'on');
    newValue = 1;
end