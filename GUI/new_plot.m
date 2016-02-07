function plt = new_plot
% Edi2Mare-internal routine; Initial values for new plot.
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

% Plot structure
plt                 = struct();
plt.projectname     = '';   % Project name
plt.fromedi         = 1;    % Input from Edi or from txt-file
plt.show_orig       = 0;    % Original off
plt.show_static     = 0;    % Static Shift off
plt.show_smooth     = 0;    % Smoothed off
plt.show_tem        = 0;    % TEM off
plt.show_te         = 1;    % TE on
plt.show_tm         = 1;    % TM on
plt.show_err        = 0;    % Error off

% Data
plt.data_sel        = {''};
plt.data_savename   = {'none'};

% Chosen
plt.chosen_sel      = {''};
plt.chosen_savename = {'none'};

% Lines
plt.line_sel        = {''};
plt.line_savename   = {'none'};

% Default data and line
plt.data            = 1;
plt.line            = 1;

end
