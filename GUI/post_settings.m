function post_settings
% Edi2Mare-internal routine; post settings of Edi2Mare, after loading
% project or pre-allocate data.
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

% Get required handles
[tmph, plt, data, line] = storage({'tmph' 'plt' 'data' 'line'});

%% Set GUI stuff

% Set Checkboxes
set(tmph.cb_orig,     'Value',  plt.show_orig )
set(tmph.cb_smooth,   'Value',  plt.show_smooth )
set(tmph.cb_static,   'Value',  plt.show_static )
set(tmph.cb_err,      'Value',  plt.show_err )
set(tmph.cb_tem,      'Value',  plt.show_tem )
set(tmph.cb_te,       'Value',  plt.show_te )
set(tmph.cb_tm,       'Value',  plt.show_tm )

% Set Data
set(tmph.dd_data,     'String', plt.chosen_sel)
set(tmph.dd_data,     'Value',  plt.data)

% Set Line
set(tmph.dd_line,     'String', plt.line_sel)
set(tmph.dd_line,     'Value',  plt.line)

% Set static shift
set(tmph.ed_ss_xy,    'String',  num2str(data.staticshift(1)))
set(tmph.ed_ss_yx,    'String',  num2str(data.staticshift(2)))

% Set line info
set(tmph.ed_zshift,   'String',  num2str(data.zshift))
set(tmph.ed_north,    'String',  num2str(line.north))
set(tmph.ed_east,     'String',  num2str(line.east))
set(tmph.ed_ang,      'String',  num2str(line.ang))
set(tmph.ed_sys,      'String',  line.sys)
if line.minfreq > 0
    set(tmph.ed_minfreq,  'String',  num2str(line.minfreq))
end
if line.maxfreq > 0
    set(tmph.ed_maxfreq,  'String',  num2str(line.maxfreq))
end
if line.erram > 0
    set(tmph.ed_erram,    'String',  num2str(line.erram))
end
if line.errph > 0
    set(tmph.ed_errph,    'String',  num2str(line.errph))
end
set(tmph.ed_emdata,   'String',  line.emdata)

% Disable Load if data is loaded, and enable drop-downs
if ~isempty(data.freq)
    set(tmph.pb_load, 'Enable', 'off')
    set(tmph.dd_data, 'Enable', 'on')
    set(tmph.dd_line, 'Enable', 'on')
end

% Switch off elemens if data from wln-file (also in load_data)
if eq(plt.fromedi, 0)
    set(tmph.cb_smooth,   'Enable',  'off' )
    set(tmph.cb_tem,      'Enable',  'off' )
    set(tmph.pb_fit,      'Enable',  'off' )
    set(tmph.ed_ss_xy,    'Enable',  'off' )
    set(tmph.ed_ss_yx,    'Enable',  'off' )
    set(tmph.tx_ss_xy,    'Enable',  'off' )
    set(tmph.tx_ss_yx,    'Enable',  'off' )
end

%% Save back
storage('tmph', tmph);

%% Set GUI elements and plot
surveyplotter
calc_rhoaphase([], 'gui')

end
