function edit_line(~, ~, handles)
% Edi2Mare-internal routine: Right-click to add, rename, or delete data or a line.
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

% Settings
mf_set = {'NumberTitle'    'off'...
    'WindowStyle'          'modal'...
    'MenuBar'              'none'...
    'Color'                'white'...
    'Resize'               'off'};

% Add, edit, rename, or delete entry
if strcmp(handles, 'Add') % ADD ENTRY
    add_line('add')
elseif strcmp(handles, 'Edit') % EDIT ENTRY
    add_line('edit')
elseif strcmp(handles, 'Rename') % RENAME ENTRY
    plt = storage('plt');
    name = plt.line_sel{plt.line};

    % Rename GUI
    pntpst1 = get(0,'PointerLocation');
    hRen = figure(mf_set{:},...
        'Name'           , 'Rename',...
        'Position'       , [pntpst1(1)-100, pntpst1(2)-30, 200, 35],...
        'KeyPressFcn'    , {@pb_renstring_callback, []});
    uicontrol(hRen,...
        'Style'    ,'edit',...
        'String'   , name,...
        'BackgroundColor',  'white',...
        'Position' ,[5,5,155,25],...
        'Callback' ,{@pb_renstring_callback, hRen});
    uicontrol(hRen,...
        'Style'    ,'pushbutton',...
        'String'   ,'OK',...
        'Position' ,[165,5,30,25],...
        'Callback' ,{@pb_renstring_callback, hRen});

elseif strcmp(handles, 'Delete') % DELETE ENTRY

    plt = storage('plt');

    if lt(size(plt.line_sel, 1), 2)
        % Just beep if only one measurement or line exists
        beep
    else

        % Delete GUI
        name = plt.line_sel{plt.line};
        pntpst1 = get(0,'PointerLocation');
        hDel = figure(mf_set{:},...
            'Name'           , 'Delete',...
            'Position'       , [pntpst1(1)-125, pntpst1(2)-30, 250, 35],...
            'KeyPressFcn'    , {@pb_delstring_callback, []});
        uicontrol(hDel,...
            'Style'    ,'text',...
            'Background'    , 'white',...
            'String'   ,['Delete <', name,'> ?'],...
            'Position' ,[5,5,205,20]);
        uicontrol(hDel,...
            'Style'    ,'pushbutton',...
            'String'   ,'OK',...
            'Position' ,[215,5,30,25],...
            'Callback' ,{@pb_delstring_callback, hDel});
    end

end

end
%% Callbacks

% Rename a line
function [] = pb_renstring_callback(hObject, ~, obj)

% Get main RENAME-GUI, depending if callback from...
if isempty(obj)                            % figure
    mfig = hObject;
else                                       % edit-box
    mfig = obj;
end

% Get string
kids = get(mfig, 'Children');
newstring = get(kids(2), 'String');

% Get handle
[tplt, ttmph, tline] = storage({'plt', 'tmph', 'line'});

% String has only to be replaced if it was changed
if ~strcmp(tplt.line_sel{tplt.line}, newstring)

    % Change string
    tplt.line_sel{tplt.line} = newstring;

    % Set strings
    set(ttmph.dd_line, 'String', tplt.line_sel)
    set(ttmph.dd_line, 'Value',  tplt.line)

    % Store name
    tline.dataname = newstring;

    % Adjust Line Name in GUI
    set(ttmph.hline, 'string', newstring)

    % Store back
    storage({'plt' 'tmph' 'line'}, {tplt ttmph tline});

end

% Delete Rename-GUI
delete(mfig)

% Auto-save
save_project([], [], 2)

end

% Delete a line
function [] = pb_delstring_callback(hObject, ~, obj)

% Get main DELETE-GUI, depending if callback from...
if isempty(obj)                            % figure
    mfig = hObject;
else                                       % pushbutton
    mfig = obj;
end

% Get handles
[tdb, tplt, ttmph] = storage({'db_line' 'plt' 'tmph'});

% Remove from db
tdb = rmfield(tdb, tplt.line_savename{tplt.line, 1});

% Remove string, and reset counter to 1
chosen = tplt.line ~= linspace(1, ...
    size(tplt.line_sel, 1), size(tplt.line_sel, 1));

tplt.line_sel = tplt.line_sel(chosen);
tplt.line_savename = tplt.line_savename(chosen);
tplt.line = 1;

% Reset chosen to all
tplt.data = 1;
tplt.chosen_sel = tplt.data_sel;
tplt.chosen_savename = tplt.data_savename;

% Set strings
set(ttmph.dd_line, 'String', tplt.line_sel)
set(ttmph.dd_line, 'Value',  tplt.line)
set(ttmph.ed_emdata,   'String',  tplt.line_sel)

% Store back
storage({'db_line' 'plt' 'tmph'}, {tdb, tplt, ttmph});

% Plot
surveyplotter
calc_rhoaphase([], 'gui')

% Delete Delete-GUI
delete(mfig)

% Auto-save
save_project([], [], 2)

end
