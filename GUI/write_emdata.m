function write_emdata(~, ~, ~)
% Edi2Mare-internal routine; Writes the .emdata-file.
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


%% Load handles
[dbd, plt, line] = storage({'db_data' 'plt' 'line'});

%% stMT
stMT.names = plt.chosen_sel;

% Check if North, East, and Angle are defined; and if data is chosen
if gt(isempty(line.east) + isempty(line.north) + isempty(line.ang) + isempty(line.dataname), 0)
    warndlg('North, East, and angle not defined, or no data is selected!',...
        ':: Edi2Mare ::             Warning');
    return
end

% Get unique frequency range
freq = [];
cfreq = 0;
% If min/max freq are not set, set them to ridiculous low/high values
if lt(line.minfreq, 0)
    line.minfreq = 0.00000001;
end
if lt(line.maxfreq, 0)
    line.maxfreq = 1000000;
end
for name = plt.chosen_savename'
    cname = name{:};
    % Actual and selected freq
    afreq = dbd.(cname).freq(logical(dbd.(cname).select));
    % Indeces of freqs within range
    idx = and(afreq > line.minfreq, afreq < line.maxfreq );
    % Add to array
    freq = [freq, afreq(logical(idx))]; %#ok
    % Add the number to total number of frequencies
    cfreq = cfreq + sum(idx);
end
stMT.frequencies = unique(freq);

%% stUTM
ang          = line.ang - 90;
stUTM        = struct();
stUTM.grid   = str2double(line.sys(isstrprop(line.sys, 'digit')));
stUTM.hemi   = line.sys(isstrprop(line.sys, 'alpha'));
stUTM.east0  = line.east*1000;
stUTM.north0 = line.north*1000;
stUTM.theta  = ang;

%% Build Receiver Matrix
stMT.receivers = zeros(length(stMT.names), 8);
ri = 0;

% Rotation matrix
R = [[cos(ang*pi/180), -sin(ang*pi/180)];[sin(ang*pi/180), cos(ang*pi/180)]];

for name = plt.chosen_savename'
    ri = ri+1;
    
    % Remove zero point from Easting and Northing and rotate
    rcoor = R*(dbd.(name{:}).coor(1:2)-[stUTM.east0, stUTM.north0])';
    stMT.receivers(ri,1) = rcoor(2);
    stMT.receivers(ri,2) = rcoor(1);
    
    % Apply z-shift and negative convention of MARE2DEM
    stMT.receivers(ri,3) = -dbd.(name{:}).coor(3)+dbd.(name{:}).zshift;
    
end

%% Build data matrix
idata = zeros(cfreq*4, 6);
ni = 0;
for ii = 1:length(stMT.frequencies)
    rfreq = stMT.frequencies(ii);
    for i=1:length(stMT.names)
        data = dbd.(plt.chosen_savename{i});
        % Only write, if freq for this offset exists, and is selected
        dfreq = data.freq(logical(data.select));
        if  any(abs(rfreq-dfreq) < stMT.frequencies(ii)/1000)
            
            rii =  logical(abs(data.freq-rfreq) < rfreq/1000);
            n = ni*4+1;
            ni = ni+1;
            
            % Write Data Type, Freq-Nr, Rec-Nr
            % We use for the inversion:
            %          104 PhsZxy
            %          106 PhsZyx
            %          123 log10RhoZxy
            %          125 log10RhoZyx
            idata(n:n+3,1) = [123,104,125,106];
            idata(n:n+3,2) = [ii,ii,ii,ii];
            idata(n:n+3,3) = [i,i,i,i];
            idata(n:n+3,4) = [i,i,i,i];

            % Write XY-Data
            idata(n,5)   = log10(data.staticshift(1)*data.xy_a(rii));
            idata(n+1,5) = data.xy_p(rii);
            
            % Write YX-Data
            idata(n+2,5) = log10(data.staticshift(2)*data.yx_a(rii));
            idata(n+3,5) = data.yx_p(rii);
            
            % Write rho_a error
            if line.erram > 0
                % Log-Error: log10(x+dx)-log10(x)
                idata(n,6)   = log10((1+line.erram/100)*data.staticshift(1)*data.xy_a(rii))-idata(n,5); 
                idata(n+2,6) = log10((1+line.erram/100)*data.staticshift(2)*data.yx_a(rii))-idata(n+2,5);
            else
                idata(n,6)   = log10(sqrt(data.xy_va(rii)));
                idata(n+2,6) = log10(sqrt(data.yx_va(rii)));
            end

            % Write phase error
            if line.errph > 0
                idata(n+1,6) = line.errph/100*data.xy_p(rii);
                idata(n+3,6) = line.errph/100*data.yx_p(rii);
            else
                idata(n+1,6) = sqrt(data.xy_vp(rii));
                idata(n+3,6) = sqrt(data.yx_vp(rii));
            end
            
%             line.erram, line.errph
%             idata(n:n+3, :)
%             disp('----')
            
        end     
    end
end

% Call writeEMData2Dile
writeEMData2DFile([line.emdata, '.emdata'], 'Created by Edi2Mare' ,...
    stUTM, [], stMT, idata)

% Display a message confirming the writing
helpdlg(['Data written to "', line.emdata, '.emdata".'],...
    ':: Edi2Mare ::             Info');

end
