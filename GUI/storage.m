function varargout = storage(handles, varargin)
% Edi2Mare-internal routine; get or set data from Edi2Mare. This can
% also be used from the MATLAB-command-line to get the values of the GUI.
%
% *INPUTS*
%
% * *varargin*:   list of handles, eg {'data' 'tmph'}, plus optionally a
%                 list of corresponding variables {data tmph}.
%                 Alternatively, 'all' returns hEdi2Mare as a structure
%                 with all fields.
%
% *OUTPUT*
%
% * *varargout*:  List of variables corresponding to input handles.
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

%% Check input
if lt(nargin, 1) || gt(nargin, 2)
    error('Input must be a cell of handle-strings, optionally with cell of corresponding variables.')
end

%% Get main handle and first input argument
hEdi2Mare = getappdata(0, 'hEdi2Mare');

% If handles is a string, convert
if ischar(handles)
    handles = cellstr(handles);
end

%% LOAD CASE
if eq(nargin, 1)

    % Check size
    if gt(nargout, size(handles, 2))
        error('Too many output variables')
    end

    % Get data
    varargout = cell(size(handles));
    if strcmp(handles{1}, 'all')
        varargout = {getappdata(hEdi2Mare)};
    else
        % If data or line required, get plt first
        if ne(sum(strcmp(handles, 'data')) + sum(strcmp(handles, 'line')), 0)
            plt = getappdata(hEdi2Mare, 'plt');
        end

        % Loop over required handles
        for n_1 = 1:size(handles, 2)
            if strcmp(handles{n_1}, 'data')
                temp = getappdata(hEdi2Mare, 'db_data');
                varargout(n_1) = {temp.(plt.chosen_savename{plt.data})};
            elseif strcmp(handles{n_1}, 'line')
                temp = getappdata(hEdi2Mare, 'db_line');
                varargout(n_1) = {temp.(plt.line_savename{plt.line})};
            else
                varargout(n_1) = {getappdata(hEdi2Mare, handles{n_1})};
            end
        end
    end
end

%% STORE CASE
if eq(nargin, 2)

    % Get variables
    variables = varargin{:};

    % If input is string, convert
    if ~iscell(variables)
        variables = {variables};
    end

    % Check for output
    if ne(nargout, 0)
        error('No output variables if two input variables provided!')
    end

    % Loop over required handles
    for n_2 = 1:size(handles, 2)

        % If data or line required, get plt first
        if ne(sum(strcmp(handles, 'data')) + sum(strcmp(handles, 'line')), 0)
            % Either the new one, if any, or the stored one
            if ne(sum(strcmp(handles, 'plt')), 0)
                plt = variables{strcmp(handles, 'plt')};
            else
                plt = getappdata(hEdi2Mare, 'plt');
            end
        end

        if strcmp(handles{n_2}, 'data')
            temp = getappdata(hEdi2Mare, 'db_data');
            temp.(plt.chosen_savename{plt.data}) = variables{n_2};
            setappdata(hEdi2Mare, 'db_data', temp);
        elseif strcmp(handles{n_2}, 'line')
            temp = getappdata(hEdi2Mare, 'db_line');
            temp.(plt.line_savename{plt.line}) = variables{n_2};
            setappdata(hEdi2Mare, 'db_line', temp);
        else
            setappdata(hEdi2Mare, handles{n_2}, variables{n_2});
        end
    end

end

end
