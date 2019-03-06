function load_project(name)
% Edi2Mare-internal routine; load a Edi2Mare-project.
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

% 1. Get current figure handle
newhandles = storage('tmph');

% 2. Get full file-path
projectfile = fullfile(pwd, [name, '.mat']);

% 3. Load saved entries
inp = load(projectfile);

% 4. Enable buttons
set(newhandles.pb_ren,  'enable', 'on')
set(newhandles.pb_edit, 'enable', 'on')
set(newhandles.pb_del,  'enable', 'on')
set(newhandles.pb_add,  'enable', 'on')
set(newhandles.pb_fit,  'enable', 'on')

% 5. Store data
storage({'plt' 'db_data' 'db_line' 'tmph'}, ...
    {inp.plt, inp.db_data, inp.db_line, newhandles});

% 6. Run post-settings
post_settings

end
