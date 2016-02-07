function deselect_data(hObject, ~, type)
% Edi2Mare-internal routine; (De)Select data points.
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

% Get required data
[tplt, ttmph, tdata] = storage({'plt', 'tmph', 'data'});

% Check which plot we're on and if there exist any data; set static shift
if ~or(tplt.show_orig, tplt.show_static)
    return
elseif and(gca == ttmph.real_ax, ~isfield(tdata, 'xy_r'))
    return
elseif and(gca == ttmph.imag_ax, ~isfield(tdata, 'xy_i'))
    return
elseif tplt.show_static
    ss = tdata.staticshift;
else
    ss = [1 1];
end

% Get square
%
% After sample_select_data.m; Thomas Montagnon (The MathWorks), 21 Jun 2007
%
pstart = get(hObject,'CurrentPoint');    % starting point
rbbox;
pend = get(hObject,'CurrentPoint');      % button up detected
pstart = pstart(1,1:2);                  % extract x and y
pend = pend(1,1:2);
p1 = min(pstart,pend);                   % calculate locations
offset = abs(pstart-pend);               % and dimensions
xrange = [p1(1) p1(1)+offset(1)];
yrange = [p1(2) p1(2)+offset(2)];
hold('on');

% Find frequencies in the selected range
ifreq = find((tdata.freq < xrange(2)) & (tdata.freq > xrange(1)));

% Get correct axes and reset ite and itm
ite = [];
itm = [];
if gca == ttmph.phas_ax
    nax = 'p';
elseif gca == ttmph.rhoa_ax
    nax = 'a';
elseif gca == ttmph.real_ax
    nax = 'r';
elseif gca == ttmph.imag_ax
    nax = 'i';
end

% Find data points in the selected range
if tplt.show_te
    if strcmp(nax, 'p')
        ite = find((tdata.(['xy_', nax]) < yrange(2)) &...
            (tdata.(['xy_', nax]) > yrange(1)));
    elseif strcmp(nax, 'a')
        ite = find((ss(1)*tdata.(['xy_', nax]) < yrange(2)) &...
            (ss(1)*tdata.(['xy_', nax]) > yrange(1)));
    else
        ite = find((sqrt(ss(1))*abs(tdata.(['xy_', nax])) < yrange(2)) &...
            (sqrt(ss(1))*abs(tdata.(['xy_', nax])) > yrange(1)));
    end
end
if tplt.show_tm
    if strcmp(nax, 'p')
        itm = find((tdata.(['yx_', nax]) < yrange(2)) &...
            (tdata.(['yx_', nax]) > yrange(1)));
    elseif strcmp(nax, 'a')
        itm = find((ss(2)*abs(tdata.(['yx_', nax])) < yrange(2)) &...
            (ss(2)*abs(tdata.(['yx_', nax])) > yrange(1)));
    else
        itm = find((sqrt(ss(2))*abs(tdata.(['yx_', nax])) < yrange(2)) &...
            (sqrt(ss(2))*abs(tdata.(['yx_', nax])) > yrange(1)));
    end
end

% Find common points of freq and data
ind = intersect(ifreq,[ite, itm]);

% Set the selected indeces to type (0 or 1)
tdata.select(ind) = type;

% Store back and plot
storage('data', tdata);
surveyplotter
plotter

end
