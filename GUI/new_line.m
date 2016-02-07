function line = new_line
% Edi2Mare-internal routine; Initial values for new line.
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

% Line structure
line          = struct();
line.dataname = '';
line.savename = 'none';
line.east     = [];
line.north    = [];
line.ang      = [];
line.sys      = [];
line.minfreq  = -1;
line.maxfreq  = -1;
line.erram    = -1;
line.errph    = -1;
line.data     = [];
line.emdata   = line.savename;

end
