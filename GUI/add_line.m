function add_line(inpcase)
% Edi2Mare-internal routine; it is called by pressing button 'Add line'.
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


%% 1. Initialization tasks

% Get required handles
plt = storage('plt');

% Get amount of data
nv = 20;
nrstat = length(plt.data_savename);
pwidth = max(200*ceil(nrstat/nv), 300);

% Add or Edit
if strcmp(inpcase, 'add')
    % Create new line
    new = new_line();
    new.data = zeros(nrstat,1);
    new.dataname = 'Edit Line Name';
else
    new = storage('line');
end

% Create and then hide the GUI as it is being constructed.
pntpst = get(0,'PointerLocation');
hAddLine = figure(...
    'Visible'        , 'off',...
    'NumberTitle'    , 'off',...
    'Name'           , 'Choose Stations',...
    'MenuBar'        , 'none',...
    'Position'       , [pntpst(1), pntpst(2)-pwidth/2, pwidth, 580],...
    'Color'          , 'white',...
    'Resize'         , 'off',...
    'WindowStyle'    , 'modal',...
    'CloseRequestFcn', @closereq);


%% 2. Construct the components

% Load button and file path
uicontrol(hAddLine,...
    'Style'    ,'pushbutton',...
    'String'   ,'Done',...
    'Position' ,[pwidth/2+40,550,100,25],...
    'Callback' ,@pb_done_callback);
uicontrol(hAddLine,...
    'Style'    ,'edit',...
    'BackgroundColor',  'white',...
    'String'   , new.dataname,...
    'Position' ,[pwidth/2-140,550,155,25],...
    'Callback' ,{@cb_callback, 'name'});

tx_set = {'Style'          'text'...
    'HorizontalAlignment'  'left'...
    'Background'           'white' };
cb_set = {'Style'          'checkbox' ...
    'Value'                0 ...
    'BackgroundColor'      'white'};

% Create checkboxes and text
i = 0;
ii = 0;
for ni = 1:nrstat
    i = i+1;

    % Station Name
    uicontrol(hAddLine, tx_set{:},...
        'String'   ,plt.data_sel{ni},...
        'Position' ,[30+ii*200, 530-i*25, 160, 20]);

    % Checkbox
    uicontrol(hAddLine, cb_set{:},...
        'Position' ,[5+ii*200 535-i*25 20 20],...
        'Value'    , new.data(ni),...
        'Callback' ,{@cb_callback, ni});

    if eq(i, nv)
        i = 0;
        ii = ii+1;
    end
end

% Store handles
setappdata(hAddLine, 'new', new)

% Make the GUI visible.
set(hAddLine, 'Visible','on')

% Wait until data is chosen
uiwait(hAddLine)

%% Callbacks for hAddLine

% Save tick state, name
    function cb_callback(hObject, ~, handles)

        % Get handles
        tnew = getappdata(hAddLine, 'new');

        if ischar(handles)
            tnew.dataname = get(hObject, 'String');
        else

            % Check status
            isChecked = get(hObject, 'Value');

            % Stored check-status
            tnew.data(handles) = isChecked;

        end

        % Store back
        setappdata(hAddLine, 'new', tnew);
    end

% Close this sub-GUI ('Done'-button)
    function pb_done_callback(~, ~, ~)

        % Get required handles
        [tdb, tplt, ttmph] = storage({'db_line' 'plt' 'tmph'});
        tnew = getappdata(hAddLine, 'new');

        % If none was selected, abort
        if eq(sum(tnew.data), 0)
            closereq
            return
        end

        % Ensure new savename is unique and valid
        newname = regexprep(['L_', tnew.dataname], '[^a-z_A-Z0-9]','');
        tnew.savename = genvarname(newname, tplt.line_savename);

        % Add new string and savestring, update count
        if strcmp(inpcase, 'add')
            tplt.line = size(tplt.line_sel, 1)+1;
            tplt.line_sel{tplt.line, 1} = tnew.dataname;
            tplt.line_savename{tplt.line, 1} = tnew.savename;
            tnew.emdata = tnew.dataname;
            set(ttmph.ed_emdata,   'String',  tnew.emdata)
        end

        % Set new name
        tdb.(tplt.line_savename{tplt.line, 1}) = tnew;

        % Set strings
        set(ttmph.dd_line, 'String', tplt.line_sel)
        set(ttmph.dd_line, 'Value',  tplt.line)

        % Store chosen
        tplt.data = 1;
        tplt.chosen_sel = tplt.data_sel(logical(tnew.data));
        tplt.chosen_savename = tplt.data_savename(logical(tnew.data));

        % Store back
        storage({'db_line' 'plt' 'tmph'}, {tdb tplt ttmph});

        % Plot
        surveyplotter
        calc_rhoaphase([], 'gui')

        % Delete GUI
        uiresume(hAddLine)
        delete(hAddLine)

        % Auto-save
        save_project([], [], 2)

    end

% Close hAddLine (Delete GUI)
    function closereq(~, ~, ~)
        uiresume(hAddLine)
        delete(hAddLine)
    end

end
