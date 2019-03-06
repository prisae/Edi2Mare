function change_data_or_line(hObject, ~, handles)
% Edi2Mare-internal routine; Callback-function for drop-down to change
% data or line.
%
% Copyright 2015, 2016 GEOTEM Ingenieria S.A. de C.V.
%
% This file is part of Edi2Mare.
%
% Edi2Mare is free software: you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation, either version 3 of the License, or
% (at your option) any later version.
%
% Edi2Mare is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
% GNU General Public License for more details.
%
% You should have received a copy of the GNU General Public License
% along with Edi2Mare.  If not, see <http://www.gnu.org/licenses/>.


% Get handle
[plt, tmph, dbl] = storage({'plt' 'tmph' 'db_line'});

% Next, previous, or drop-down (in case of data, not line)
nrdat = length(plt.chosen_sel);
tts = get(hObject, 'TooltipString');
if strcmp(tts(1:4), 'Next')
    % If current is last, set to first, else to current+1
    if or(eq(nrdat, 1), eq(plt.data, nrdat))
        plt.data = 1;
    else
        plt.data = plt.data+1;
    end
elseif strcmp(tts(1:4), 'Prev')
    % If current is first, set to last, else to current-1
    if eq(nrdat, 1)
        plt.data = 1;
    elseif eq(plt.data, 1)
        plt.data = nrdat;
    else
        plt.data = plt.data-1;
    end
else % Get input from dropdown
    % Update plt.(handles)
    plt.(handles) = get(hObject, 'Value');
end

% Set Data or Line
if strcmp(handles, 'line')
    % Set data to first in line
    plt.data = 1;
    
    % Get chosen
    chosen = logical(dbl.(plt.line_savename{plt.line}).data);
    
    % Store chosen
    plt.chosen_sel = plt.data_sel(chosen);
    plt.chosen_savename = plt.data_savename(chosen);
end

% Store back
storage({'plt' 'tmph'}, {plt tmph});

% Set gui elements and plot
post_settings

end
