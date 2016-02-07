function static_shift(hObject, ~, handles)
% Edi2Mare-internal routine; Callback-function for static shift edit boxes.
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
[data, tmph, plt] = storage({'data' 'tmph' 'plt'});

% Get and store new value
ed_val = round(100*str2double(get(hObject, 'String')))./100;

% Update handle and edit box
if strcmp(handles, 'xy')                                 % XY
    data.staticshift(1) = ed_val;
    set(tmph.ed_ss_xy,   'String',  num2str(ed_val))
elseif strcmp(handles, 'yx')                             % YX
    data.staticshift(2) = ed_val;
    set(tmph.ed_ss_yx,   'String',  num2str(ed_val))
else                                                     % FIT

    % Get frequencies from MT that are contained in TEM
    minix = data.freq > max(min(data.tem(:,1)), min(data.freq));
    maxix = data.freq < min(max(data.tem(:,1)), max(data.freq));
    ix = logical(minix.*maxix);

    % Interpolate TEM at MT-frequencies
    tem_amp = interp1(data.tem(:,1), data.tem(:,2), data.freq(ix));

    % Median (looked better than mean/mode/lsqr)
    xyshift = round(median(tem_amp./data.xy_a(ix))*100)/100;
    yxshift = round(median(tem_amp./data.yx_a(ix))*100)/100;

    % Least Square Method
    %xyshift = round(lsqr(data.xy_a(ix)', tem_amp')*100)/100;
    %yxshift = round(lsqr(data.yx_a(ix)', tem_amp')*100)/100;

    % Set XY shift
    data.staticshift(1) = xyshift;
    set(tmph.ed_ss_xy,   'String',  num2str(xyshift))

    % Set YX shift
    data.staticshift(2) = yxshift;
    set(tmph.ed_ss_yx,   'String',  num2str(yxshift))

end

% Switch on Static shift, if it isn't
plt.show_static = 1;
set(tmph.cb_static,   'Value',  plt.show_static )

% Store back
storage({'tmph' 'data' 'plt'}, {tmph data plt});

% Plot data
calc_rhoaphase([], 'gui')

end
