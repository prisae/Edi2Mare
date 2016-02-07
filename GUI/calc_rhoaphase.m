function [rhoa, phas] = calc_rhoaphase(data, type)
% Edi2Mare-internal routine to calculate apparent resistivity and phase and
% store the result in 'data'.
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

plt = storage('plt');

% Check two type cases; only calc rhoaphase, or also adjust variance
if ~plt.fromedi
    plotter

elseif strcmp(type, 'rhoaphas')
    [rhoa, phas] = calcrhoaphas(data.real, data.imag, data.freq);

elseif strcmp(type, 'gui')

    % Get handles
    data = storage('data');

    % Loop over the two curve types
    curves = {'xy' 'yx'};
    for n_2 = 1:length(curves)

        % Get type
        curve = curves{n_2};

        % Real and Imag
        dre = data.([curve, '_r']);
        dim = data.([curve, '_i']);

        % Calc. Apparent resistivity and Phase
        [data.([curve, '_a']),  data.([curve, '_p'])] =...
            calcrhoaphas(dre, dim, data.freq);

        % Calc Variance of rhoa, phase
        var = data.([curve, '_v']);
        [data.([curve, '_va']), data.([curve, '_vp'])] =...
            calcvar(dre, dim, var, data.freq);

    end

    % Store data
    storage('data', data);

    % Plot
    plotter
end

    function [rhoa, phas] = calcrhoaphas(dtre, dtim, dtfr)

        % Calc. Apparent resistivity (After Cagniard, 1953)
        %     ProcMT output is: -> E [mV/km]; -> B [nT]
        rhoa = 0.2*abs(complex(dtre, dtim)).^2./dtfr;

        % Calc. Phase
        %     MARE2DEM expects phases in the first quadrant
        %     The same as ProcMT plots it
        phas = atan(dtim./dtre)*180/pi;

    end

    function [vara, varp] = calcvar(dtre, dtim, dtvar, dtfr)

        % Calc Variance of rhoa, phase
        %     Equation 2, Chave et al 2007, GJI
        %     Without mu0, Z is with B, not H!
        vara = abs(complex(dtre, dtim)).*dtvar./(pi*dtfr);
        varp = abs(asin(dtvar./abs(complex(dtre, dtim))));

    end
end
