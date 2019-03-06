function plotter
% Edi2Mare-internal routine; Plot curves
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

%% Load handles and clean up
[tmph, data, plt, line] = storage({'tmph' 'data' 'plt' 'line'});
delete(findobj('Tag','del_line'))  % deletes ALL line-plots/scatter

%% Early exit, if no data available or no plots required, clean-up

% If no data is chosen return
if isempty(data.dataname)
    return
end

% If none of the wanted curves is ticked, return
init_check = plt.show_orig + plt.show_static + plt.show_smooth + plt.show_tem;
if ~init_check
    return
end

% Freq-band & selected
idx = zeros(size(data.freq));
if line.minfreq > 0
    idx = idx + (data.freq < line.minfreq);
end
if line.maxfreq > 0
    idx = idx+(data.freq > line.maxfreq);
end
idx = ~logical(~idx.*data.select);

% Data-types
if and(plt.show_orig, plt.show_static)
    types = {'orig' 'static'};
elseif plt.show_orig
    types = {'orig'};
elseif plt.show_static
    types = {'static'};
else
    types = {};
end

% Set correct figure, just in case
set(0,'currentfigure',getappdata(0, 'hEdi2Mare'))

% Loop over orig, static
for ltype = types
    type = ltype{:};
    
    % Line properties
    gxy_prop    = {'^' 'Color' [.8 .8 .8 ] 'MarkerFaceColor' [.8 .8 .8] 'LineWidth' 1};
    gyx_prop    = {'v' 'Color' [.8 .8 .8 ] 'MarkerFaceColor' [.8 .8 .8] 'LineWidth' 1};
    if and(strcmp(type, 'orig'), ~plt.show_static)
        xy_prop    = {'r^' 'MarkerFaceColor' 'r' 'LineWidth' 1};
        yx_prop    = {'bv' 'MarkerFaceColor' 'b' 'LineWidth' 1};
    elseif and(strcmp(type, 'orig'), plt.show_static)
        xy_prop    = {'^' 'Color' [.6 .6 .6] 'MarkerFaceColor' [.6 .6 .6] 'LineWidth' 1};
        yx_prop    = {'v' 'Color' [.6 .6 .6] 'MarkerFaceColor' [.6 .6 .6] 'LineWidth' 1};
    elseif  strcmp(type, 'static')
        xy_prop  = {'r^' 'MarkerFaceColor' 'r' 'LineWidth' 1};
        yx_prop  = {'bv' 'MarkerFaceColor' 'b' 'LineWidth' 1};
    end
    
    % Static shift
    if strcmp(type, 'orig')
        ssxy = 1;
        ssyx = 1;
    else
        ssxy = data.staticshift(1);
        ssyx = data.staticshift(2);
    end
    
    if plt.fromedi
        %% Real
        
        % Set axes current
        set(getappdata(0, 'hEdi2Mare'), 'currentaxes', tmph.real_ax);
        hold(tmph.real_ax, 'on')
        
        if plt.show_te
            % Get error
            err_xy = calc_error(line.erram, data.xy_v, data.xy_r, plt.show_err);
            
            % Draw data within freq-range
            tmph.(['realxy',type]) = errorbar(tmph.real_ax, data.freq(~idx),...
                sqrt(ssxy)*data.xy_r(~idx), sqrt(ssxy)*err_xy(~idx), xy_prop{:},...
                'Tag', 'del_line');
            
            % Grey outside of range
            if gt(sum(idx), 0)
                tmph.(['grealxy',type]) = errorbar(tmph.real_ax, data.freq(idx),...
                    sqrt(ssxy)*data.xy_r(idx), sqrt(ssxy)*err_xy(idx), gxy_prop{:},...
                    'Tag', 'del_line');
            end
        end
        if plt.show_tm
            % Get error
            err_yx = calc_error(line.erram, data.yx_v, data.yx_r, plt.show_err);
            
            % Draw data within freq-range
            tmph.(['realyx',type]) = errorbar(tmph.real_ax, data.freq(~idx),...
                sqrt(ssyx)*-data.yx_r(~idx), sqrt(ssyx)*err_yx(~idx), yx_prop{:},...
                'Tag', 'del_line');
            
            % Grey outside of range
            if gt(sum(idx), 0)
                tmph.(['grealyx',type]) = errorbar(tmph.real_ax, data.freq(idx),...
                    sqrt(ssyx)*-data.yx_r(idx), sqrt(ssxy)*err_yx(idx), gyx_prop{:},...
                    'Tag', 'del_line');
            end
        end
        
        % Hold off
        hold(tmph.real_ax, 'off')
        
        %% Imag
        
        % Set axes current
        set(getappdata(0, 'hEdi2Mare'), 'currentaxes', tmph.imag_ax);
        hold(tmph.imag_ax, 'on')
        
        if plt.show_te
            % Get error
            err_xy = calc_error(line.erram, data.xy_v, data.xy_i, plt.show_err);
            
            % Draw data within freq-range
            tmph.(['imagxy',type]) = errorbar(tmph.imag_ax, data.freq(~idx),...
                sqrt(ssxy)*data.xy_i(~idx), sqrt(ssxy)*err_xy(~idx), xy_prop{:},...
                'Tag', 'del_line');
            
            % Grey outside of range
            if gt(sum(idx), 0)
                tmph.(['gimagxy',type]) = errorbar(tmph.imag_ax, data.freq(idx),...
                    sqrt(ssxy)*data.xy_i(idx), sqrt(ssxy)*err_xy(idx), gxy_prop{:},...
                    'Tag', 'del_line');
            end
        end
        if plt.show_tm
            % Get error
            err_yx = calc_error(line.erram, data.yx_v, data.yx_i, plt.show_err);
            
            % Draw data within freq-range
            tmph.(['imagyx',type]) = errorbar(tmph.imag_ax, data.freq(~idx),...
                sqrt(ssyx)*-data.yx_i(~idx), sqrt(ssyx)*err_yx(~idx), yx_prop{:},...
                'Tag', 'del_line');
            
            % Grey outside of range
            if gt(sum(idx), 0)
                tmph.(['gimagyx',type]) = errorbar(tmph.imag_ax, data.freq(idx),...
                    sqrt(ssyx)*-data.yx_i(idx), sqrt(ssyx)*err_yx(idx),...
                    gyx_prop{:}, 'Tag', 'del_line');
            end
        end
        
        % Hold off
        hold(tmph.imag_ax, 'off')
    end
    
    %% Apparent Resistivity
    
    % Set axes current
    set(getappdata(0, 'hEdi2Mare'), 'currentaxes', tmph.rhoa_ax);
    hold(tmph.rhoa_ax, 'on')
    
    if plt.show_te
        % Get error
        err_xy = calc_error(line.erram, data.xy_va, data.xy_a, plt.show_err);
        
        % Draw data within freq-range
        tmph.(['rhoaxy',type]) = errorbar(tmph.rhoa_ax, data.freq(~idx),...
            ssxy*data.xy_a(~idx), ssxy*err_xy(~idx), xy_prop{:}, 'Tag', 'del_line');
        
        % Grey outside of range
        if gt(sum(idx), 0)
            tmph.(['grhoxy',type]) = errorbar(tmph.rhoa_ax, data.freq(idx),...
                ssxy*data.xy_a(idx), ssxy*err_xy(idx), gxy_prop{:}, 'Tag', 'del_line');
        end
    end
    if plt.show_tm
        % Get error
        err_yx = calc_error(line.erram, data.yx_va, data.yx_a, plt.show_err);
        
        % Draw data within freq-range
        tmph.(['rhoayx',type]) = errorbar(tmph.rhoa_ax, data.freq(~idx),...
            ssyx*data.yx_a(~idx), ssyx*err_yx(~idx), yx_prop{:}, 'Tag', 'del_line');
        
        % Grey outside of range
        if gt(sum(idx), 0)
            tmph.(['grhoyx',type]) = errorbar(tmph.rhoa_ax, data.freq(idx),...
                ssyx*data.yx_a(idx), ssyx*err_yx(idx), gyx_prop{:}, 'Tag', 'del_line');
        end
    end
    
    % Hold off
    hold(tmph.rhoa_ax, 'off')
    
    %% Phase
    
    % Set axes current
    set(getappdata(0, 'hEdi2Mare'), 'currentaxes', tmph.phas_ax);
    hold(tmph.phas_ax, 'on')
    
    if plt.show_te
        % Get error
        err_xy = calc_error(line.errph, data.xy_vp, data.xy_p, plt.show_err);
        
        % Draw data within freq-range
        tmph.(['phasxy',type]) = errorbar(tmph.phas_ax, data.freq(~idx),...
            data.xy_p(~idx), err_xy(~idx), xy_prop{:}, 'Tag', 'del_line');
        
        % Grey outside of range
        if gt(sum(idx), 0)
            tmph.(['gphasxy',type]) = errorbar(tmph.phas_ax, data.freq(idx),...
                data.xy_p(idx), err_xy(idx), gxy_prop{:}, 'Tag', 'del_line');
        end
    end
    if plt.show_tm
        % Get error
        err_yx = calc_error(line.errph, data.yx_vp, data.yx_p, plt.show_err);
        
        % Draw data within freq-range
        tmph.(['phasyx',type]) = errorbar(tmph.phas_ax, data.freq(~idx),...
            data.yx_p(~idx), err_yx(~idx), yx_prop{:}, 'Tag', 'del_line');
        
        % Grey outside of range
        if gt(sum(idx), 0)
            tmph.(['gphasyx',type]) = errorbar(tmph.phas_ax, data.freq(idx),...
                data.yx_p(idx), err_yx(idx), gyx_prop{:}, 'Tag', 'del_line');
        end
    end
    
    % Hold off
    hold(tmph.phas_ax, 'off')
    
    
end

%% D+
if plt.show_smooth
    
    % Line properties
    xy_prop  = {'r' 'LineWidth' 1};
    yx_prop  = {'b' 'LineWidth' 1};
    
    % Static shift
    if eq(plt.show_static, 0)
        ssxy = 1;
        ssyx = 1;
    else
        ssxy = data.staticshift(1);
        ssyx = data.staticshift(2);
    end

    
    %% Calc
    
    if plt.show_te
        % Get error
        err_xy = calc_error(line.erram, data.xy_v, data.xy_i, 1);
        
        % Get Re/Im
        [sdatarxy, sdataixy, srhoaxy, sphasxy] = ...
            calc_dplus(data.freq(~idx), sqrt(ssxy)*data.xy_r(~idx),...
            sqrt(ssxy)*data.xy_i(~idx), err_xy(~idx), 'xy');
    end
    if plt.show_tm
        % Get error
        err_yx = calc_error(line.erram, data.yx_v, data.yx_i, 1);
        
        % Get Re/Im
        [sdataryx, sdataiyx, srhoayx, sphasyx] = ...
            calc_dplus(data.freq(~idx), sqrt(ssyx)*data.yx_r(~idx),...
            sqrt(ssyx)*data.yx_i(~idx), err_yx(~idx), 'yx');
    end
    
    %% Real
    
    % Set axes current
    set(getappdata(0, 'hEdi2Mare'), 'currentaxes', tmph.real_ax);
    hold(tmph.real_ax, 'on')
    
    if plt.show_te
        % Draw curve
        tmph.srealxy = plot(tmph.real_ax, data.freq(~idx),...
            sdatarxy, xy_prop{:}, 'Tag', 'del_line');
    end
    if plt.show_tm
        % Draw curve
        tmph.srealyx = plot(tmph.real_ax, data.freq(~idx),...
            -sdataryx, yx_prop{:}, 'Tag', 'del_line');
    end
    
    % Hold off
    hold(tmph.real_ax, 'off')
    
    %% Imag
    
    % Set axes current
    set(getappdata(0, 'hEdi2Mare'), 'currentaxes', tmph.imag_ax);
    hold(tmph.imag_ax, 'on')
    
    if plt.show_te
        % Draw curve
        tmph.simagxy = plot(tmph.imag_ax, data.freq(~idx),...
            sdataixy, xy_prop{:}, 'Tag', 'del_line');
    end
    if plt.show_tm
        % Draw curve
        tmph.simagx = plot(tmph.imag_ax, data.freq(~idx),...
            -sdataiyx, yx_prop{:}, 'Tag', 'del_line');
    end
    
    % Hold off
    hold(tmph.imag_ax, 'off')
    
    %% Apparent Resistivity
    
    % Set axes current
    set(getappdata(0, 'hEdi2Mare'), 'currentaxes', tmph.rhoa_ax);
    hold(tmph.rhoa_ax, 'on')
    
    if plt.show_te
        % Draw curve.*db_data.(name{:}).select
        tmph.srhoaxy = plot(tmph.rhoa_ax, data.freq(~idx),...
            srhoaxy, xy_prop{:}, 'Tag', 'del_line');
    end
    if plt.show_tm
        % Draw curve
        tmph.srhoayx = plot(tmph.rhoa_ax, data.freq(~idx),...
            srhoayx, yx_prop{:}, 'Tag', 'del_line');
    end
    
    % Hold off
    hold(tmph.rhoa_ax, 'off')
    
    %% Phase
    
    % Set axes current
    set(getappdata(0, 'hEdi2Mare'), 'currentaxes', tmph.phas_ax);
    hold(tmph.phas_ax, 'on')
    
    if plt.show_te
        % Draw curve
        tmph.sphasxy = plot(tmph.phas_ax, data.freq(~idx),...
            sphasxy, xy_prop{:}, 'Tag', 'del_line');
    end
    if plt.show_tm
        % Draw curve
        tmph.sphasyx = plot(tmph.phas_ax, data.freq(~idx),...
            sphasyx, yx_prop{:}, 'Tag', 'del_line');
    end
    
    % Hold off
    hold(tmph.phas_ax, 'off')
    
end

%% TEM
if and(isfield(data, 'tem'), plt.show_tem)
    
    % Set axes current
    set(getappdata(0, 'hEdi2Mare'), 'currentaxes', tmph.rhoa_ax);
    hold(tmph.rhoa_ax, 'on')
    
    % Draw curve
    tmph.('rhoaxytem') = plot(tmph.rhoa_ax, data.tem(:,1),...
        data.tem(:,2), 'Color', [0 .6 0], 'LineWidth', 2, 'Tag', 'del_line');
    
    % Hold off
    hold(tmph.rhoa_ax, 'off')
    
end

% Store back
storage('tmph', tmph);

% Calculate error
    function error = calc_error(err, var, data, doplt)
        std = sqrt(var);
        
        tplt = storage('plt');
        
        % If error is given, set to error, els use std = sqrt(variance)
        if or(err > 0, ~tplt.fromedi)
            error = doplt*err./100.*data;
        else
            error = doplt*std;
        end
    end

end
