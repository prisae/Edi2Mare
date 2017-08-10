function Edi2Mare
% GUI to create MARE2DEM inputs from EDI (and TEM) or WinGLink files.
%
% Created with MATLAB R2012b; not tested with any other version.
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

%% Add GUI path (in case it wasn't done)
[pathstr, ~, ~] = fileparts(which('Edi2Mare'));
addpath(pathstr, fullfile(pathstr, 'GUI'), '-BEGIN')

%% Initialization tasks

%  Create and then hide the GUI as it is being constructed.
hEdi2Mare = figure(round(rand(1)*10000));  % Random figure number
scrsz = get(0, 'ScreenSize');              % Get screend size

% Set figure properties
feature('DefaultCharacterSet','UTF-8');
set(hEdi2Mare,...
    'Visible'         ,'off',...
    'NumberTitle'    , 'off',...
    'Name'           , ['      :: Edi2Mare [V 1.2] ::                  ',...
    'Create input files for MARE2DEM from EDIs                      ',...
    '                            GEOTEM Ingenieria S.A. de C.V.'],...
    'Position'       , [scrsz(3)/4-1400/2, scrsz(4)/2-800/2, 1400, 800],...
    'MenuBar'        , 'none',...
    'ToolBar'        , 'none',...
    'CloseRequestFcn', @edi2mare_closereq);

% Store figure handle in root
setappdata(0, 'hEdi2Mare', hEdi2Mare);

% Create temporary handles structure : The stuff in this handle is not
% saved in a project, it is specific to this instance of the GUI
tmph = struct();

% Get project-name if .config exists
if ne(exist(fullfile(pwd, '.edi2mare'), 'file'), 0)
    config = fopen(fullfile(pwd, '.edi2mare'));
    projectname = fgetl(config);
    pos = textscan(fgetl(config), '%d', 4);
    set(hEdi2Mare, 'Position', [pos{1}(1), pos{1}(2), pos{1}(3), pos{1}(4)])
    fclose(config);
else
    projectname = datestr(now,30); % dummy name as placeholder
end

%% Construct the components

%% 0. Settings of various buttons
pb_set = {'Style'      'pushbutton'...
    'Units'            'normalized'};
tb_set = {'Style'      'togglebutton'...
    'Units'            'normalized'};
tx_set = {'Style'      'text'...
    'HorizontalAlignment'  'left'...
    'Units'            'normalized'};
ed_set = {'Style'      'edit'...
    'HorizontalAlignment'  'left'...
    'Units'            'normalized'};
dd_set = {'Style'      'popupmenu'...
    'Units'            'normalized'};
cb_set = {'Style'      'checkbox' ...
    'Value'            0 ...
    'Units'            'normalized'};
box_set = {'BorderType' 'line',...
    'ForegroundColor'  [0 0 .6],... 
    'BorderWidth'      1};

%% 1a General buttons and texts

tmph.hcontr = uipanel(hEdi2Mare, box_set{:},...
    'Position'       , [.01, .33, .385, .66]);

% Directory where the matlab icons should be
icondir = fullfile(matlabroot, '/toolbox/matlab/icons/');

% New Project
tmph.hnew = uicontrol(hEdi2Mare, pb_set{:},...
    'Position'       , [.015, .93, .03, .05],...
    'TooltipString'  , 'New Project',...
    'CData'          , icon_read(fullfile(icondir, 'file_new.png')),...
    'Callback'       , {@new_project_callback});
% Open Project
tmph.hopen = uicontrol(hEdi2Mare, pb_set{:},...
    'Position'       , [.05, .93, .03, .05],...
    'TooltipString'  , 'Open Existing Project',...
    'CData'          , icon_read(fullfile(icondir, 'file_open.png')),...
    'Callback'       , {@open_project_callback});
% Save Project
tmph.hsave = uicontrol(hEdi2Mare, pb_set{:},...
    'Position'       , [.085, .93, .03, .05],...
    'TooltipString'  , 'Save Project',...
    'CData'          , icon_read(fullfile(icondir, 'file_save.png')),...
    'Callback'       , {@save_project, 1});
% Save As ... Project
tmph.hsaveas = uicontrol(hEdi2Mare, pb_set{:},...
    'Position'       , [.12, .93, .03, .05],...
    'TooltipString'  , 'Save Project As...',...
    'CData'          , icon_read('file_saveas.mat'),...
    'Callback'       , {@save_project, 3});
% Zoom In
tmph.hzoomin = uicontrol(hEdi2Mare, tb_set{:},...
    'Position'       , [.255, .93, .03, .05],...
    'TooltipString'  , 'Zoom In',...
    'CData'          , icon_read(fullfile(icondir, 'tool_zoom_in.png')),...
    'Callback'       , {@zoom_callback, 'in'});
% Zoom Out
tmph.hzoomout = uicontrol(hEdi2Mare, tb_set{:},...
    'Position'       , [.29, .93, .03, .05],...
    'TooltipString'  , 'Zoom Out',...
    'CData'          , icon_read(fullfile(icondir, 'tool_zoom_out.png')),...
    'Callback'       , {@zoom_callback, 'out'});
% Pan
tmph.hpan = uicontrol(hEdi2Mare, tb_set{:},...
    'Position'       , [.325, .93, .03, .05],...
    'TooltipString'  , 'Pan',...
    'CData'          , icon_read(fullfile(icondir, 'tool_hand.png')),...
    'Callback'       , {@pan_callback});
% Data Cursor
tmph.hdatacursor = uicontrol(hEdi2Mare, tb_set{:},...
    'Position'       , [.36, .93, .03, .05],...
    'TooltipString'  , 'Data Cursor',...
    'CData'          , icon_read(fullfile(icondir, 'tool_data_cursor.png')),...
    'Callback'       , {@data_cursor_callback});

% Project-Name
tmph.hprojectt = uicontrol(hEdi2Mare, tx_set{:},...
    'FontWeight'     , 'bold',...
    'FontSize'       , 14,...
    'ForegroundColor', [0 0 .6],...
    'String'         , 'Project:',...
    'Position'       , [.015, .88, .055, .03]);
tmph.hproject = uicontrol(hEdi2Mare, tx_set{:},...
    'FontWeight'     , 'bold',...
    'FontSize'       , 14,...
    'ForegroundColor', [0 0 .6],...
    'String'         , 'Not saved!',...
    'Position'       , [.08, .88, .31, .03]);

% Station-Name
tmph.hstationt = uicontrol(hEdi2Mare, tx_set{:},...
    'FontWeight'     , 'bold',...
    'FontSize'       , 14,...
    'ForegroundColor', [0 0 .6],...
    'String'         , 'Station:',...
    'Position'       , [.015, .845, .055, .03]);
tmph.hstation = uicontrol(hEdi2Mare, tx_set{:},...
    'FontWeight'     , 'bold',...
    'FontSize'       , 14,...
    'ForegroundColor', [0 0 .6],...
    'String'         , '',...
    'Position'       , [.08, .845, .31, .03]);

% Line-Name
tmph.hlinet = uicontrol(hEdi2Mare, tx_set{:},...
    'FontWeight'     , 'bold',...
    'FontSize'       , 14,...
    'ForegroundColor', [0 0 .6],...
    'String'         , 'Line:',...
    'Position'       , [.015, .81, .055, .03]);
tmph.hline = uicontrol(hEdi2Mare, tx_set{:},...
    'FontWeight'     , 'bold',...
    'FontSize'       , 14,...
    'ForegroundColor', [0 0 .6],...
    'String'         , '',...
    'Position'       , [.08, .81, .31, .03]);

%% 1.b Measurements
tmph.ld_ui = uipanel(hEdi2Mare, box_set{:},...
    'Position'        , [0.205, .69, .185, .1],...
    'Title'           , 'Measurement');

% Choose Measurements
tmph.dd_data = uicontrol(tmph.ld_ui, dd_set{:},...
    'Enable'          , 'off',...
    'Value'           , 1 ,...
    'String'          , ' ',...
    'Position'        , [.34, 0.45, .65, .4],...
    'TooltipString'   , 'Choose data',...
    'Callback'        , {@change_data_or_line, 'data'});

% Load
tmph.pb_load = uicontrol(tmph.ld_ui, pb_set{:},...
    'Position'       ,[.01, .51, .3, .4],...
    'TooltipString'  ,'Load data',...
    'String'         ,'Load',...
    'Callback'       , @load_data);

% Previous
tmph.pb_previous = uicontrol(tmph.ld_ui, pb_set{:},...
    'Position'       ,[.58, .05, .17, .4],...
    'TooltipString'  ,'Previous meauserement',...
    'String'         ,'<',...
    'Callback'       ,{@change_data_or_line, 'data'});

% Next
tmph.pb_next = uicontrol(tmph.ld_ui, pb_set{:},...
    'Position'       ,[.80, .05, .17, .4],...
    'TooltipString'  ,'Next Measurement',...
    'String'           ,'>',...
    'Callback'       ,{@change_data_or_line, 'data'});

% Z-Shift
tmph.tx_zshift = uicontrol(tmph.ld_ui, tx_set{:},...
    'Position'            , [.01 0.15 .2 .2],...
    'TooltipString'       , 'Z-shift of station, positive downwards',...
    'String'              , 'Z-shift');
tmph.ed_zshift = uicontrol(tmph.ld_ui, ed_set{:},...
    'Position'        , [.22 .05 .25 .4],...
    'TooltipString'   , 'Z-shift of station, positive downwards',...
    'Callback'        ,{@line_data_info, 'zshift'});

%% 1.c Static Shift
tmph.ls_ui = uipanel(hEdi2Mare, box_set{:},...
    'Position'        , [0.205, .61, .185, .05],...
    'Title'           ,'Static Shift');

% Automatic fit
tmph.pb_fit = uicontrol(tmph.ls_ui, pb_set{:},...
    'Position'       ,[.05, .05, .3, .85],...
    'TooltipString'  ,'Fit data with median',...
    'String'         ,'Fit',...
    'Enable'         ,'off',...
    'Callback'       , {@static_shift, 'fit'});

% XY
tmph.tx_ss_xy = uicontrol(tmph.ls_ui, tx_set{:},...
    'Position'       , [.4 0 .1 .8],...
    'String'         , 'XY');
tmph.ed_ss_xy = uicontrol(tmph.ls_ui, ed_set{:},...
    'Position'       , [.47 .1 .2 .9],...
    'TooltipString'  , 'Static Shift XY',...
    'Callback'       ,{@static_shift, 'xy'});

% YX
tmph.tx_ss_yx = uicontrol(tmph.ls_ui, tx_set{:},...
    'Position'       , [.71 0 .1 .8],...
    'String'         , 'YX');
tmph.ed_ss_yx = uicontrol(tmph.ls_ui, ed_set{:},...
    'Position'       , [.78 .1 .2 .9],...
    'TooltipString'  , 'Static Shift YX',...
    'Callback'       ,{@static_shift, 'yx'});

%% 1.d Lines
tmph.ll_ui = uipanel(hEdi2Mare, box_set{:},...
    'Position'       ,[0.015,.49,.185,.3],...
    'Title'          ,'Line');

% Lines
tmph.dd_line = uicontrol(tmph.ll_ui, dd_set{:},...
    'Value'          ,1 ,...
    'Enable'         ,'off',...
    'String'         ,' ',...
    'Position'       ,[.34, .85, .65, .1],...
    'TooltipString'  ,'Choose line',...
    'Callback'       ,{@change_data_or_line, 'line'});

% Add
tmph.pb_add = uicontrol(tmph.ll_ui, pb_set{:},...
    'Position'       ,[.01, .85, .3, .12],...
    'TooltipString'  ,'Add Line',...
    'String'         ,'Add',...
    'Enable'         , 'off',...
    'Callback'       , {@edit_line, 'Add'});

% Edit
tmph.pb_edit = uicontrol(tmph.ll_ui, pb_set{:},...
    'Position'       ,[.01, .7, .3, .12],...
    'TooltipString'  ,'Edit Line',...
    'Enable'         , 'off',...
    'String'         ,'Edit',...
    'Callback'       , {@edit_line, 'Edit'});

% Rename
tmph.pb_ren = uicontrol(tmph.ll_ui, pb_set{:},...
    'Position'       ,[.35, .7, .3, .12],...
    'TooltipString'  ,'Rename Line',...
    'Enable'         , 'off',...
    'String'         ,'Rename',...
    'Callback'       , {@edit_line, 'Rename'});

% Delete
tmph.pb_del = uicontrol(tmph.ll_ui, pb_set{:},...
    'Position'       ,[.69, .7, .3, .12],...
    'TooltipString'  ,'Delete Line',...
    'Enable'         , 'off',...
    'String'         ,'Delete',...
    'Callback'       , {@edit_line, 'Delete'});

% North-0
tmph.tx_north = uicontrol(tmph.ll_ui, tx_set{:},...
    'Position'       , [.01 .5 .2 .1],...
    'TooltipString'  , 'Northing 0-point (km)',...
    'String'         , '0 North');
tmph.ed_north = uicontrol(tmph.ll_ui, ed_set{:},...
    'Position'       , [.23 .5 .25 .12],...
    'TooltipString'  , 'Northing 0-point (km)',...
    'Callback'       ,{@line_data_info, 'north'});

% East-0
tmph.tx_east = uicontrol(tmph.ll_ui, tx_set{:},...
    'Position'       , [.51 .5 .2 .1],...
    'TooltipString'  , 'Easting 0-point (km)',...
    'String'         , '0 East');
tmph.ed_east = uicontrol(tmph.ll_ui, ed_set{:},...
    'Position'       , [.73 .5 .25 .12],...
    'TooltipString'  , 'Easting 0-point (km)',...
    'Callback'       ,{@line_data_info, 'east'});

% Angle
tmph.tx_ang = uicontrol(tmph.ll_ui, tx_set{:},...
    'Position'       , [.01 .35 .2 .1],...
    'TooltipString'  , 'Survey line angle (deg)',...
    'String'         , 'Angle');
tmph.ed_ang = uicontrol(tmph.ll_ui, ed_set{:},...
    'Position'       , [.23 .35 .25 .12],...
    'TooltipString'  , 'Survey line angle (deg)',...
    'Callback'       ,{@line_data_info, 'ang'});

% Coordinate System
tmph.tx_sys = uicontrol(tmph.ll_ui, tx_set{:},...
    'Position'       , [.51 .35 .2 .1],...
    'TooltipString'  , 'Coordinate System (e.g. "14 N")',...
    'String'         , 'System');
tmph.ed_sys = uicontrol(tmph.ll_ui, ed_set{:},...
    'Position'       , [.73 .35 .25 .12],...
    'TooltipString'  , 'Coordinate System (e.g. "14 N")',...
    'Callback'       ,{@line_data_info, 'sys'});

% Min freq
tmph.tx_minfreq = uicontrol(tmph.ll_ui, tx_set{:},...
    'Position'       , [.01 .2 .2 .1],...
    'TooltipString'  , 'Min. freq. to use for inversion (Hz)',...
    'String'         , 'Min f');
tmph.ed_minfreq = uicontrol(tmph.ll_ui, ed_set{:},...
    'Position'       , [.23 .2 .25 .12],...
    'TooltipString'  , 'Min. freq. to use for inversion (Hz)',...
    'Callback'       ,{@line_data_info, 'minfreq'});

% Max freq
tmph.tx_maxfreq = uicontrol(tmph.ll_ui, tx_set{:},...
    'TooltipString'  , 'Max. freq. to use for inversion (Hz)',...
    'Position'       , [.51 .2 .2 .1],...
    'String'         , 'Max f');
tmph.ed_maxfreq = uicontrol(tmph.ll_ui, ed_set{:},...
    'Position'       , [.73 .2 .25 .12],...
    'TooltipString'  , 'Max. freq. to use for inversion (Hz)',...
    'Callback'       ,{@line_data_info, 'maxfreq'});

%  Error Amplitude
tmph.tx_erram = uicontrol(tmph.ll_ui, tx_set{:},...
    'Position'       , [.01 .05 .2 .1],...
    'TooltipString'  , 'Max. error resistivity for inversion (%)',...
    'String'         , 'Err-Res');
tmph.ed_erram = uicontrol(tmph.ll_ui, ed_set{:},...
    'Position'       , [.23 .05 .25 .12],...
    'TooltipString'  , 'Max. error resistivity for inversion (%)',...
    'Callback'       ,{@line_data_info, 'erram'});

% Error Phase
tmph.tx_errph = uicontrol(tmph.ll_ui, tx_set{:},...
    'Position'       , [.51 .05 .2 .1],...
    'TooltipString'  , 'Max. error of phase for inversion (%)',...
    'String'         , 'Err-Pha');
tmph.ed_errph = uicontrol(tmph.ll_ui, ed_set{:},...
    'Position'       , [.73 .05 .25 .12],...
    'TooltipString'  , 'Max. error of phase for inversion (%)',...
    'Callback'       ,{@line_data_info, 'errph'});

%% 1.e Plotting
tmph.pl_ui = uipanel(hEdi2Mare, box_set{:},...
    'Position'       , [.205,.34,.185,.15],...
    'Title'          , 'Plotting');

% Original
tmph.cb_orig = uicontrol(tmph.pl_ui, cb_set{:},...
    'String'         , ' Original',...
    'TooltipString'  , 'Show original data',...
    'Position'       , [.05, .65, .45, .25],...
    'Callback'       , {@show_curve, 'orig'});

% Static Shift
tmph.cb_static = uicontrol(tmph.pl_ui, cb_set{:},...
    'String'         , ' Static Shift',...
    'FontWeight'     , 'bold',...
    'TooltipString'  , 'Show data with static shift applied',...
    'Position'       , [.55, .35, .45, .25],...
    'Callback'       , {@show_curve, 'static'});

% Smoothed
tmph.cb_smooth = uicontrol(tmph.pl_ui, cb_set{:},...
    'String'         , ' Smooth (D+)',...
    'TooltipString'  , 'Show smoothed data',...
    'Position'       , [.05, .35, .45, .25],...
    'Callback'       , {@show_curve, 'smooth'});

% Error
tmph.cb_err = uicontrol(tmph.pl_ui, cb_set{:},...
    'String'         , ' Errrobars',...
    'TooltipString'  , 'Show Errorbars',...
    'Position'       , [.55, .65, .34, .25],...
    'Callback'       , {@show_curve, 'err'});

% TEM
tmph.cb_tem = uicontrol(tmph.pl_ui, cb_set{:},...
    'String'         , ' TEM',...
    'TooltipString'  , 'Show TEM data',...
    'ForegroundColor', [0 .6 0],...
    'Position'       , [.65, .05, .25, .25],...
    'Callback'       , {@show_curve, 'tem'});

% TE
tmph.cb_te = uicontrol(tmph.pl_ui, cb_set{:},...
    'String'         , ' XY',...
    'TooltipString'  , 'Show XY data (most of the time TE)',...
    'ForegroundColor', 'r',...
    'Position'       , [.05, .05, .25, .25],...
    'Callback'       , {@show_curve, 'te'});

% TM
tmph.cb_tm = uicontrol(tmph.pl_ui, cb_set{:},...
    'String'         , ' YX',...
    'TooltipString'  , 'Show YX data (most of the time TM)',...
    'ForegroundColor', 'b',...
    'Position'       , [.35, .05, .25, .25],...
    'Callback'       , {@show_curve, 'tm'});

%% 1.f Writing
tmph.wr_ui = uipanel(hEdi2Mare, box_set{:},...
    'Position'       , [.015,.34,.185,.12],...
    'Title'          , 'Writing');

% Write
tmph.pb_write = uicontrol(tmph.wr_ui, pb_set{:},...
    'Position'       , [.1, .05, .8, .4],...
    'TooltipString'  , 'Write to *.emdata-file',...
    'String'         , 'Write *.emdata',...
    'Callback'       , @write_emdata);

% Name
tmph.tx_emdata = uicontrol(tmph.wr_ui, tx_set{:},...
    'Position'       , [.05 0.65 .4 .2],...
    'String'         , '.emdata-Name');
tmph.ed_emdata = uicontrol(tmph.wr_ui, ed_set{:},...
    'Position'       , [.45 .55 .5 .4],...
    'TooltipString'  , 'Name of *.emdata-file',...
    'Callback'       , {@line_data_info, 'emdata'});

%% 1.g Delete Data
tmph.de_ui = uipanel(hEdi2Mare, box_set{:},...
    'Position'       , [.205,.51,.185,.08],...
    'Title'          , '(De)select data');
% Deselect/Select
tmph.hdeselect = uicontrol(tmph.de_ui, tb_set{:},...
    'Position'       , [.1, 0.2, .3, .6],...
    'TooltipString'  , 'Deselect data',...
    'String'          , 'Deselect',...
    'Callback'       , {@deselect_callback, 0});
tmph.hselect = uicontrol(tmph.de_ui, tb_set{:},...
    'Position'       , [.6, 0.2, .3, .6],...
    'TooltipString'  , 'Select data',...
    'String'          , 'Select',...
    'Callback'       , {@deselect_callback, 1});

%% 2. Plots
ax_set = {'Parent' hEdi2Mare 'box' 'on' 'Visible' 'on'};
% 2.1a Plot Survey
tmph.surv_ax  = axes(ax_set{:},...
    'Position'      ,[.035,.06,.14,.23]);
set(get(tmph.surv_ax, 'Title'), 'String', 'Survey Outline', 'Interpreter',...
    'LaTex', 'FontSize',16)
set(get(tmph.surv_ax, 'XLabel'), 'String', 'Easting (km)')
set(get(tmph.surv_ax, 'YLabel'), 'String', 'Northing (km)')

% 2.1b Plot Frequencies
tmph.freq_ax = axes(ax_set{:},...
    'Position'      ,[.18 ,.06,.2,.23],...
    'YAxisLocation'  ,'right');
set(get(tmph.freq_ax, 'Title'), 'String', 'Frequencies (Hz)', 'Interpreter',...
    'LaTex', 'FontSize',16)
set(get(tmph.freq_ax, 'XLabel'), 'String', 'Station')
set(tmph.freq_ax, 'YScale', 'log')

% 2.2a Plot Real(Z)
tmph.real_ax = axes(ax_set{:},...
    'Position'       ,[.42,.06,.27,.38],...
    'YGrid'          ,'on',...
    'ylim'           ,[0, 1000],...
    'xlim'           ,[.01, 3000]);
set(get(tmph.real_ax, 'XLabel'), 'String', 'Frequency (Hz)')
set(get(tmph.real_ax, 'Title'), 'String', 'Real(Impedance)~~~$\Re$(Z)~~[km/s]',...
    'Interpreter', 'LaTex', 'FontSize',16)
set(tmph.real_ax, 'XDir', 'rev')
set(tmph.real_ax, 'XScale', 'log', 'YScale', 'log')

% 2.2b Plot Imag(Z)
tmph.imag_ax = axes(ax_set{:},...
    'Position'       ,[.7,.06,.27,.38],...
    'YGrid'          ,'on',...
    'ylim'           ,[0, 1000],...
    'YAxisLocation'  ,'right',...
    'xlim'          ,[.01, 3000]);
set(get(tmph.imag_ax, 'XLabel'), 'String', 'Frequency (Hz)')
set(get(tmph.imag_ax, 'Title'), 'String', 'Imag(Impedance)~~~$\Im$(Z)~~[km/s]',...
    'Interpreter', 'LaTex', 'FontSize',16)
set(tmph.imag_ax, 'XDir', 'rev')
set(tmph.imag_ax, 'XScale', 'log', 'YScale', 'log')

% 2.3a Plot Apparent Resistivity
tmph.rhoa_ax = axes(ax_set{:},...
    'Position'       ,[.42,.56,.27,.38],...
    'YGrid'          ,'on',...
    'ylim'           ,[0, 1000],...
    'xlim'           ,[.01, 3000],...
    'XDir'           ,'rev');
set(get(tmph.rhoa_ax, 'XLabel'), 'String', 'Frequency (Hz)')
set(get(tmph.rhoa_ax, 'Title'), 'String',...
    'Apparent Resistivity~~~$\rho_a$~~~[$\Omega$.m]', 'Interpreter',...
    'LaTex', 'FontSize',16)
set(tmph.rhoa_ax, 'XScale', 'log', 'YScale', 'log')

% 2.3b Plot Phase
tmph.phas_ax = axes(ax_set{:},...
    'Position'       ,[.7,.56,.27,.38],...
    'YGrid'          ,'on',...
    'ylim'           ,[-180, 180],...
    'xlim'           ,[.01, 3000],...
    'YAxisLocation'  ,'right',...
    'XDir'           ,'rev');
set(get(tmph.phas_ax, 'XLabel'), 'String', 'Frequency (Hz)')
set(get(tmph.phas_ax, 'Title'), 'String', 'Phase~~~$\varphi$~~~[$^\circ$]',...
    'Interpreter', 'LaTex', 'FontSize',16)
set(tmph.phas_ax, 'XScale', 'log')

% 2.4 Link the different axis
linkaxes([tmph.real_ax, tmph.imag_ax, tmph.rhoa_ax, tmph.phas_ax], 'x')

% Save handles
storage('tmph', tmph)

%% Pre-allocate or load settings

% If project exists, load, otherwise create new one
if ne(exist(fullfile(pwd, [projectname, '.mat']), 'file'), 0)
    load_project(projectname)
else
    storage({'line' 'data' 'plt'}, {new_line, new_data, new_plot});
    post_settings
end

%%  Define and start timer for auto-saving
% The GUI auto-saves every 5 minutes. The first auto-saving happens after
% 10 minutes, giving enough time to load a previous auto-saved file before
% it is over-written with a new auto-save.
Edi2Mare_timer = timer('ExecutionMode', 'fixedRate', 'Period', 300, ...
    'StartDelay', 600, 'TimerFcn', {@save_project, 2});
start(Edi2Mare_timer);


%% Make the GUI visible.
set(hEdi2Mare,'Visible','on');

%% Callbacks

% Show curve
    function show_curve(hObject, ~, handles)
        % Get required handle
        tplt = storage('plt');
        
        % Store status in plt
        tplt.(['show_', handles]) =  get(hObject, 'Value');
        
        % Store back
        storage('plt', tplt);
        
        % Calc and Plot
        calc_rhoaphase([], 'gui')
        
    end

% New project
    function new_project_callback(~, ~, ~)
        
        % Close GUI
        edi2mare_closereq(getappdata(0, 'hEdi2Mare'), [])
        
        % Save config file under another name, so Edi2MareGUI starts a new
        % project
        if exist(fullfile(pwd,'.edi2mare'), 'file') == 2
            movefile(fullfile(pwd,'.edi2mare'), fullfile(pwd,'.tedi2mare'), 'f')
        end
        
        % Call Edi2Mare
        Edi2Mare
        
        % Restore config file, in case the users closes the new project
        % unsaved
        if exist(fullfile(pwd,'.tedi2mare'), 'file') == 2
            movefile(fullfile(pwd,'.tedi2mare'), fullfile(pwd,'.edi2mare'), 'f')
        end
    end

% Open project (Dialog window)
    function open_project_callback(~, ~, ~)
        % Start uigetfile-dialog
        [project_name, project_path, filter] =...
            uigetfile({'*.mat','Project File (*.mat)';...
            '*.mat~','Backup File (*.mat~)'}, 'Open Project');
        
        % Check output and act upon it
        if isequal(project_name, 0) || isequal(project_path, 0)
            % do nothing
        elseif (strcmp('.mat', project_name(end-3:end)) == 0) && ...
                (strcmp('.mat~', project_name(end-4:end)) == 0)
            disp('Wrong file extension, MUST be .mat or .mat~')
        else
            
            % If a backupfile is chosen: Rename it
            if filter == 2
                
                % 1. Move rename .mat to temorary name, if exists
                if ne(exist(project_name(1:end-1), 'file'), 0)
                    movefile(project_name(1:end-1), ['temp', project_name])
                end
                
                % Rename .mat~ to .mat
                movefile(project_name, project_name(1:end-1))
                
                % Rename temporary name to .mat~
                if ne(exist(['temp', project_name], 'file'), 0)
                    movefile(['temp', project_name], project_name)
                end
                
                % Set Project name to .mat (remove ~)
                project_name = project_name(1:end-1);
            end
            
            % Change path
            cd(project_path)
            
            % Load project
            load_project(project_name(1:end-4))
            
            % Save project (also writes config-file)
            save_project([], [], 1)
            
        end
    end

% Zoom
    function zoom_callback(hObject, ~, handles)
        % Get zoom-handle
        hzoom = zoom(getappdata(0, 'hEdi2Mare'));
        
        % Get and set direction
        if strcmp(handles, 'in')
            set(hzoom, 'Direction', 'in')
        elseif strcmp(handles, 'out')
            set(hzoom, 'Direction', 'out')
        end
        
        % Get and set status
        status = reset_zoom(hObject);
        if status ~= 0
            zoom on
        end
        if status == 0
            zoom off;
        end
    end

% Pan
    function pan_callback(hObject, ~, ~)
        % Get and set status
        status = reset_zoom(hObject);
        if status ~= 0
            pan on
        end
        if status == 0
            pan off;
        end
    end

% Data Cursor
    function data_cursor_callback(hObject, ~, ~)
        % Get and set status
        status = reset_zoom(hObject);
        if status ~= 0
            datacursormode on
        end
        if status == 0
            datacursormode off;
        end
    end

% Data (de)select
    function deselect_callback(hObject, ~, type)
        % Get and set status
        status = reset_zoom(hObject);
        
        % Ensure zoom/pan/datacursor are off
        pan off
        zoom off 
        datacursormode off

        ttmph = storage('tmph');
        if status
            
            % Update axes callback
            set(ttmph.real_ax, 'ButtonDownFcn', {@deselect_data, type});
            set(ttmph.imag_ax, 'ButtonDownFcn', {@deselect_data, type});
            set(ttmph.rhoa_ax, 'ButtonDownFcn', {@deselect_data, type});
            set(ttmph.phas_ax, 'ButtonDownFcn', {@deselect_data, type});
            
        else
       
            % Update axes callback
            set(ttmph.real_ax, 'ButtonDownFcn','');
            set(ttmph.imag_ax,'ButtonDownFcn','');
            set(ttmph.rhoa_ax,'ButtonDownFcn','');
            set(ttmph.phas_ax,'ButtonDownFcn','');
            
        end
        storage('tmph', ttmph);
        
    end

% Close Edi2Mare
    function edi2mare_closereq(hObject, ~)
        
        % Auto-save data (.mat~)
        save_project([], [], 2)
        
        % Stop and destroy timer
        if strcmp(get(Edi2Mare_timer, 'Running'), 'on')
            stop(Edi2Mare_timer);
        end
        delete(Edi2Mare_timer)
        
        % Delete figure
        delete(hObject)
        
    end

%% Utility functions

% Mutually exclude zoom push-buttons
    function status = reset_zoom(hObject)
        ttmph = storage('tmph');
        
        % Get status
        status = get(hObject, 'Value');
        
        % Set all to zero
        set(ttmph.hzoomin,     'Value', 0 )
        set(ttmph.hzoomout,    'Value', 0 )
        set(ttmph.hpan,        'Value', 0 )
        set(ttmph.hdatacursor, 'Value', 0 )
        set(ttmph.hdeselect,   'Value', 0 )
        set(ttmph.hselect,     'Value', 0 )
        
        % Restate status
        set(hObject, 'Value', status);
        
        storage('tmph', ttmph);
    end

end
