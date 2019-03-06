function load_data(~, ~, ~)
% Edi2Mare-internal routine; reads *.edi/*.wln, *.tem, and coordinates.txt.
% Coordinates.txt-format: ##_MT-Name   Easting, Northing, Altitude
%                         01_TestStation 200000  5000000  2200
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

% Get handle
[plt, tmph, line] = storage({'plt' 'tmph' 'line'});

% Select folder
folder = uigetdir;
if eq(folder, 0)
    return
end

% Get MT filenames
files = dir([folder,'/*.edi']);
if isempty(files)
    files = dir([folder,'/*.wln']);
    plt.fromedi = 0;
    if isempty(files)
        errordlg(['No EDIs/WLNs found in ', folder, '. Loading cancelled.'],...
                  'Error reading EDIs/WLNs', 'modal')
        return
    end
end

% Read coordinate file
if ne(exist([folder, '/coordinates.txt'], 'file'), 2)
    errordlg(['Coordinate-file coordinate.txt is missing in ',...
        folder, '. Loading cancelled.'], 'Error reading coordinate.txt', 'modal')
    return
else
    fid = fopen([folder, '/coordinates.txt']);
    stations = textscan(fid, '%s %f %f %f');
    fclose(fid);
end

ix = 0;
% Loop through files
for file = files'
    ix = ix+1;

    % Get the filename, and create a unique variable name from it
    tname = regexp(file.name, '\.', 'split');
    if ~isempty(regexp(tname{1}, '^\d+_', 'ONCE'))
        tname = regexp(tname{1}, '_', 'split');
        fname = ['MT', sprintf('%.2d', str2double(tname{1}))];
    else
        fname = regexprep(tname{1}, '[^a-zA-Z0-9]','');
    end

    % Get the actual data
    data.(fname) = getmtdata(folder, file, plt.fromedi);

    % Get index for coordinates and name
    ind = strncmp(fname(3:end), stations{1}, 2);

    % Add coordinates
    data.(fname).coor = [stations{2}(ind), stations{3}(ind), stations{4}(ind)];

    % Get station name
    tname = stations{1}(ind);
    tname = tname{:};
    tname = tname(4:end);

    % Store names in data and plt
    data.(fname).dataname  = tname;
    data.(fname).savename  = fname;
    data.(fname).fdatapath = [folder, file.name];
    plt.data_sel{ix, 1} = tname;
    plt.data_savename{ix, 1} = fname;

    % Initial Static Shift, initial Z-Shift
    data.(fname).staticshift  = [1,1];
    data.(fname).zshift = 0;

end

% Get TEM filenames, if input are EDIs
if plt.fromedi
    tfiles = dir([folder,'/*.tem']);
    if ~isempty(tfiles)
        % Get MT-names, to associate TEMs with MTs
        mtnames = fieldnames(data);
    end

    % Loop through TEM-files
    for file = tfiles'
        % Get the filename, and create a unique variable name from it
        fname =regexp(file.name, '\.', 'split');
        fname = regexprep(fname(1),'[^0-9]','');

        for i = 1:numel(mtnames)
            if strcmp(mtnames{i}(end-1:end), fname{:}(end-1:end))
                % Get the actual data
                data.(mtnames{i}).tem = gettemdata(folder, file);
            end
        end
    end
end

% Sort names
[plt.data_savename, inds] = sort(plt.data_savename);
plt.data_sel = plt.data_sel(inds);

% Show original data, if wln also static shift
set(tmph.cb_orig,     'Value',  1 )
plt.show_orig = 1;

% Enable drop-downs
set(tmph.dd_data, 'Enable', 'on')
set(tmph.dd_line, 'Enable', 'on')

% Create 'All' Line in line and plt
line.dataname = 'All';
line.savename = 'all';
set(tmph.ed_emdata, 'String', line.savename)
line.emdata = line.savename;
line.data = ones(length(files),1);
plt.line_sel{1, 1} = 'All';
plt.line_savename{1, 1} = 'all';
plt.chosen_sel = plt.data_sel;
plt.chosen_savename = plt.data_savename;
if ~plt.fromedi
    line.erram = 10;
    line.errph = 10;
    set(tmph.ed_erram, 'String', num2str(line.erram))
    set(tmph.ed_errph, 'String', num2str(line.errph))
end

% Disable Load
set(tmph.pb_load, 'enable', 'off')

% Set strings
set(tmph.dd_data, 'String', plt.data_sel)
set(tmph.dd_data, 'Value',  plt.data)
set(tmph.dd_line, 'String', plt.line_sel)
set(tmph.dd_line, 'Value',  plt.line)

% Store data; save first measurement as data
storage({'plt', 'db_data', 'data', 'line', 'tmph'},...
    {plt data data.(plt.data_savename{1}) line tmph});

% Switch off elemens if data from wln-file (also in post-settings)
if eq(plt.fromedi, 0)
    set(tmph.cb_smooth,   'enable',  'off' )
    set(tmph.cb_tem,      'enable',  'off' )
    set(tmph.cb_static,   'enable',  'off' )
    set(tmph.pb_fit,      'enable',  'off' )
    set(tmph.ed_ss_xy,    'enable',  'off' )
    set(tmph.ed_ss_yx,    'enable',  'off' )
    set(tmph.tx_ss_xy,    'enable',  'off' )
    set(tmph.tx_ss_yx,    'enable',  'off' )
end

% Plot
set(tmph.pb_ren,  'enable', 'on')
set(tmph.pb_edit, 'enable', 'on')
set(tmph.pb_del,  'enable', 'on')
set(tmph.pb_add,  'enable', 'on')
set(tmph.pb_fit,  'enable', 'on')
surveyplotter
calc_rhoaphase([], 'gui')

end

function out = getmtdata(folder, file, fromedi)
% Read data from edi into structure

% Open file
fid = fopen([folder, '/', file.name], 'r');

if fromedi % EDIs

    % All keys: Frequency, Zxy and Zyx, for each real, imag, and variance
    keys =  {'freq', 'xy_r', 'xy_i', 'xy_v', 'yx_r', 'yx_i', 'yx_v'};
    % ikeys: First four letters of desired variables
    ikeys = {'FREQ', 'ZXYR', 'ZXYI', 'ZXY.', 'ZYXR', 'ZYXI', 'ZYX.'};

    % Loop through the entire file
    line=1;
    getline = 1;
    while line~=-1
        if eq(getline, 1)
            line = fgets(fid);
        else
            getline = 1;
        end
        % Ensure line has at list 5 characters, and check if it matches an ikeys
        if length(line)>5 &&  any(strcmp(line(2:5), ikeys))
            % Get key
            key = keys{strcmp(line(2:5), ikeys)};
            % Pre-allocate tdat
            tdat=[];
            % Loop until through lines
            while line~=-1
                % Get data line
                line = fgets(fid);
                % If line is empty or has a '>' -> end reached, break
                if or(isempty(strtrim(line)), strcmp(line(1), '>'))
                    % Do not read newline, first go through with this one
                    getline = 0;
                    % save tdat to out
                    out.(key) = tdat;
                    break
                end
                % Add current data to existing data
                tdat = [tdat, str2num(line)]; %#ok
            end
        end
    end

else % WLNs
    % There are different variations of wln-formats. This part is very
    % fragile and should be improved. Currently just two formats are
    % supported.
    tdat = textscan(fid, '%f %f %f %f %f %f %f %f %f', 'HeaderLines', 4);
    out.freq  = tdat{:,1}';
    if sum(isnan(tdat{:,9})) > 1
        % Format 1: freq, xy_a, xy_p, yx_a, yx_p
        out.xy_a = tdat{:,2}';
        out.xy_p = tdat{:,3}';
        out.yx_a = tdat{:,4}';
        out.yx_p = tdat{:,5}'+180;
    else
        % Format 2: freq, ?, xy_a, ?, xy_p, ?, yx_a, ?, yx_p
        out.xy_a = tdat{:,3}';
        out.xy_p = tdat{:,5}';
        out.yx_a = tdat{:,7}';
        out.yx_p = tdat{:,9}'+180;
    end
    out.xy_va = nan(size(out.freq));
    out.xy_vp = nan(size(out.freq));
    out.yx_va = nan(size(out.freq));
    out.yx_vp = nan(size(out.freq));
end

out.select = ones(size(out.freq));
fclose(fid);

end

function out = gettemdata(folder, file)
% Read data from tem

% Open file
fid = fopen([folder, '/', file.name], 'r');

% Pre-allocate tdat
out=[];

% Loop through the entire file
line=1;
while line~=-1
    line = fgets(fid);
    % Find <DATA>
    if length(line)>6 && strcmp(line(2:5), 'DATA')
        while line~=-1
            line = fgets(fid);
            % Leave out comments
            if ~strcmp(line(1), '#')
                % If line is empty or has a '>' -> end reached, break
                if isempty(strtrim(line))
                    break
                end
                % Get line, reduce to period and app res
                temp = str2num(line); %#ok (not a scalar)
                temp = temp(:, 1:2:3);

                % TEM time-to-frequency scaling for comparison (static shift corr.)
                %        Sternberg et. al., Geophysics, 1988
                %        f(Hz) = 194/t(ms)
                temp(1) = 194./temp(1);

                % Add current data to existing data
                out = [out; temp]; %#ok
            end
        end
    end
end
fclose(fid);

end
