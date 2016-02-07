function surveyplotter
% Edi2Mare-internal routine; Plot survey outline and frequency content
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

%% Load handles and clean up
[tmph, db_data, data, plt, line] = storage({'tmph' 'db_data' 'data' 'plt' 'line'});
delete(findobj('Tag','del_surv'))  % deletes ALL line-plots/scatter

%% Early exit, if no data available or no plots required, clean-up

% If no data is loaded return
if isempty(data.freq)
    return
end

% Set correct figure, just in case
set(0,'currentfigure',getappdata(0, 'hEdi2Mare'))

% Get names, current measurement index, and chosen name
names = plt.data_savename;
snamesi = logical(line.data);
chosen = plt.chosen_savename;

%% 1. Survey plot

% Pre-allocate coord
coord = zeros(length(names), 3);

% Get coord
i = 0;
for name = names'
    i = i+1;
    coord(i, :) = db_data.(name{:}).coor/1000;
end

% Set axes current
set(getappdata(0, 'hEdi2Mare'), 'currentaxes', tmph.surv_ax);
hold(tmph.surv_ax, 'on')

% 1. Survey line
if ~any([isempty(line.east), isempty(line.north), isempty(line.ang)])
    ang = -1*(line.ang-90);
    tmp.surv_linedot = plot(line.east, line.north, 'bv', 'Tag', 'del_surv');

    tmp.surv_line = plot([line.east line.east+1000*cos(ang*pi/180)],...
                         [line.north line.north+1000*sin(ang*pi/180)],...
                         'b-', 'Tag', 'del_surv');
end

% 2. All Stations
tmph.surv_dots = plot(coord(:,1), coord(:,2), 'ko', 'Tag', 'del_surv');

% 3. Current Line
tmph.surv_dots = plot(coord(snamesi,1), coord(snamesi,2), 'ko',...
    'MarkerFaceColor', 'k', 'Tag', 'del_surv');

% 4. Current Station
tmph.curr_data = plot(data.coor(1)/1000, data.coor(2)/1000, 'ko',...
    'MarkerFaceColor', [0 .6 0], 'MarkerSize', 8, ...
    'Tag', 'del_surv');

% Get dimensions and set axis to cover whole survey with equal axis
minc = min(coord(:,1:2));
diff = (max(coord(:,1:2))-minc)./2;
centc = minc+diff;
diff = max(diff)*1.05;
axis([centc(1)-diff centc(1)+diff centc(2)-diff centc(2)+diff])

hold(tmph.surv_ax, 'off')

%% 2. Frequency plot

% Set axes current
set(getappdata(0, 'hEdi2Mare'), 'currentaxes', tmph.freq_ax);
hold(tmph.freq_ax, 'on')

% Plot frequencies
i = 0;
for name = chosen'
    i = i+1;

    % Get freq-range indices
    idx = ones(size(db_data.(name{:}).freq));
    if line.minfreq > 0
        idx = idx.*(db_data.(name{:}).freq > line.minfreq);
    end
    if line.maxfreq > 0
        idx = idx.*(db_data.(name{:}).freq < line.maxfreq);
    end
    idx = logical(idx.*db_data.(name{:}).select);

    % Grey-out outside freq-range
    tmp.(['f_r', name{:}]) = plot(i*ones(size(db_data.(name{:}).freq(~idx))),...
        db_data.(name{:}).freq(~idx), 'o', 'MarkerFaceColor', [.8 .8 .8],...
        'Color', [.8 .8 .8], 'Tag', 'del_surv');

    % Black inside freq-range
    tmp.(['f_', name{:}]) = plot(i*ones(size(db_data.(name{:}).freq(idx))),...
        db_data.(name{:}).freq(idx), 'ko', 'MarkerFaceColor', 'k',...
        'Tag', 'del_surv');

    % Highlight current freqs within freq-band
    if strcmp(name,  plt.chosen_savename(plt.data))
        tmp.curr_f = plot(plt.data*ones(size(data.freq(idx))), data.freq(idx), 'ko',...
            'MarkerFaceColor', [0 .6 0],  'Tag', 'del_surv');
    end
end

% Min/Max freq
if line.minfreq > 0
    tmp.minfreq = plot([-1, 200], [line.minfreq, line.minfreq],...
        '-', 'Color', [0 .6 0], 'Tag', 'del_surv');
end
if line.maxfreq > 0
    tmp.maxfreq = plot([-1, 200], [line.maxfreq, line.maxfreq],...
        '-', 'Color', [0 .6 0], 'Tag', 'del_surv');
end

% Limits
xlim([.5 length(chosen)+.5])
hold(tmph.freq_ax, 'off')

%% 3. General

% Set Station name
station = plt.chosen_sel(plt.data);
set(tmph.hstation, 'string', station{:})

% Set Line name
line = plt.line_sel(plt.line);
set(tmph.hline, 'string', line{:})

% Set the project name
if isempty(plt.projectname)
    set(tmph.hproject, 'string', 'Not saved!')
else
    set(tmph.hproject, 'string', plt.projectname)
end

% Store back
storage('tmph', tmph);

end
