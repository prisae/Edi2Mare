function line_data_info(hObject, ~, handles)
% Edi2Mare-internal routine; Callback-function for edit boxes.
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

% Get  required handles
[data, line, tmph, plt] = storage({'data' 'line' 'tmph' 'plt'});

% Get and store new value
if or(strcmp(handles, 'sys'), strcmp(handles, 'emdata'))
    dt_val = get(hObject, 'String');
    ed_val = dt_val;
else
    dt_val = round(1000*str2double(get(hObject, 'String')))./1000;
    ed_val = num2str(dt_val);
end

% Ensure Error is a value and at least 0
if and(any(strcmp(handles, {'erram', 'errph'})), or(lt(dt_val, 0), isnan(dt_val)))
    dt_val = 0;
    ed_val = num2str(dt_val);
end

% Update handle and edit box
if strcmp(handles, 'zshift')
    data.(handles) = dt_val;
else
    line.(handles) = dt_val;
end
set(tmph.(['ed_', handles]), 'String',  ed_val)    

% Store back
storage({'tmph' 'data' 'plt' 'line'}, {tmph data plt line});

%% Plot survey
surveyplotter
if any(strcmp(handles, {'minfreq', 'maxfreq', 'erram', 'errph'}))
    plotter
end

end
