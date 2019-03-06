function save_project(~, ~, type)
% Edi2Mare-internal routine; (Auto-) Save active Edi2Mare-project. Without
% input, it saves the project.
%
% * INPUT *
%
% * type ; integer: 1 - save     to projectname.mat
%                   2 - autosave to projectname.mat~
%                   3 - save-as-dialog
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


% Save As project (Dialog window)
if eq(type, 3)
    % Open uiputfile-dialog
    [project_name, project_path] =...
        uiputfile({'*.mat','Project File (*.mat)'}, 'Save Project As');

    % Check output and take action
    if isequal(project_name, 0) || isequal(project_path, 0)
        type = 0;
    elseif strcmp('.mat', project_name(end-3:end)) == 0
        disp('Wrong file extension, MUST be .mat')
        type = 0;
    else
        % Change to the directory
        cd(project_path)
        % Store Project directory and path

        plt = storage('plt');
        plt.projectname = project_name(1:end-4);
        storage('plt', plt);

        % Save Project
        type = 1;
    end

end

% Get variables from hEdi2Mare
[out.plt, out.db_data, out.db_line] = storage({'plt' 'db_data', 'db_line'});

if eq(type, 1) % Save

    % If there is no projectname, start 'Save As...', otherwise 'Save'
    if strcmp('', out.plt.projectname)
        save_project([], [], 3)

    else
        save(fullfile(pwd, [out.plt.projectname, '.mat']), '-struct', 'out')

        % Set project-name
        tmph = storage('tmph');
        set(tmph.hproject, 'string', out.plt.projectname)
        storage('tmph', tmph);

        % Write config-file .edi2mare

        % Open config file
        cfile = fopen(fullfile(pwd, '.edi2mare') ,'wt');

        % Write project name
        fprintf(cfile,[out.plt.projectname, '\n']);

        % Write window position
        fprintf(cfile, '%g %g %g %g',...
            get(getappdata(0, 'hEdi2Mare'), 'Position'));

        % Save file
        fclose(cfile);

    end


elseif eq(type, 2) % Autosave

    % At Various points, the project is auto-saved to a backup file
    % <pwd/projectname.mat~>, e.g. by hitting the close button X.

    % Autosave only if it has a project-name
    if ~strcmp(storage('projectname'), '')
        save(fullfile(pwd, [out.plt.projectname, '.mat~']), '-struct', 'out')
    end

end


end
