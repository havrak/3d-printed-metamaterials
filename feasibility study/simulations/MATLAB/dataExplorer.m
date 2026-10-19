% ---- Question A: phase range on the major axis for different pillar heights ----
function dataExplorer()

dirpath = '../Data/';   % <-- edit
f0      = 30;                   % GHz
lambda0 = 300/f0;               % mm
clearance = 0.2;                % mm - Clearance around geometrical feature

mag_floor_dB = -1.0;             % |S| floor for usable points
slope_max    = 400;              % deg/mm slope guard (resonance)
resid_max    = 0.05;             % eigenbasis validity

cfg = load_touchstone_tree(dirpath, f0);        % new(dirpath, f0);

% swept parameter names, discovered from the data (everything but 'a')
all_params = {'ratio', 'epsilon_r', 'H_pillar', 'P_ratio'};
params = all_params(cellfun(@(p) has_field(cfg, p), all_params));



S = build_struct(cfg, params, lambda0, clearance);

% ----------  GUI  ------------------------------------
fig = uifigure('Name', 'Question Ay - phase explorer', ...
    'Position', [100 100 1150 680]);

root = uigridlayout(fig, [2 2]);
root.ColumnWidth = {300, '1x'};
root.RowHeight   = {'1x', 180};      % plot sparse, magnitude strip
root.Padding     = [10 10 10 10];
root.ColumnSpacing = 10;

% ---- sidebar ----
nb = numel(params);
side = uigridlayout(root, [nb + 3, 3]);
side.Layout.Row = [1 2];
side.Layout.Column = 1;
side.ColumnWidth = {70, '1x', 45};
side.RowHeight   = [repmat({70}, 1, nb), {30, 30, '1x'}];
side.Padding     = [0 0 0 0];
side.RowSpacing  = 6;

controls = struct();
for k = 1:nb
    p    = params{k};

    lbl = uilabel(side, 'Text', p);
    lbl.Layout.Row = k;  lbl.Layout.Column = 1;

    controls.(p).list = uilistbox(side, ...
        'Items', compose('%g', S.vals.(p)), ...
        'ItemsData', S.vals.(p), ...
        'Multiselect', 'on');
    controls.(p).list.Layout.Row = k;  controls.(p).list.Layout.Column = 2;

    controls.(p).fix = uicheckbox(side, 'Text', 'fix', ...
        'Value', 0, 'ValueChangedFcn', @(~,~) refresh());
    controls.(p).fix.Layout.Row = k;  controls.(p).fix.Layout.Column = 3;
end

controls.showMinor = uicheckbox(side, ...
    'Text', 'Show minor axis', ...
    'Value', 1, 'ValueChangedFcn', @(~,~) refresh());
controls.showMinor.Layout.Row = nb + 1;
controls.showMinor.Layout.Column = [1 2];

btn = uibutton(side, 'Text', 'Refresh / print stats', ...
    'ButtonPushedFcn', @(~,~) refresh());
btn.Layout.Row = nb + 2;
btn.Layout.Column = [1 2];

txt = uitextarea(side, ...
    'Editable', 'off', ...
    'FontName', 'Consolas', ...
    'FontSize', 10, ...
    'Value', {'(no data yet)'});
txt.Layout.Row = nb + 3;
txt.Layout.Column = [1 3];

% ---- plot ----
ax = uiaxes(root);
ax.Layout.Row = 1;  ax.Layout.Column = 2;
xlabel(ax, 'a (mm)'); ylabel(ax, 'Phase delay (deg)');
title(ax, 'Phase vs a'); grid(ax, 'on'); hold(ax, 'on');

axm = uiaxes(root);
axm.Layout.Row = 2; axm.Layout.Column = 2;
xlabel(axm, 'a (mm)'); ylabel(axm, '|S| (dB)');
title(axm, 'Reflected magnitude'); grid(axm, 'on'); hold(axm, 'on');
linkaxes([ax axm], 'x');             % shared a-axis

refresh();

% ----------  refresh  --------------------------------
    function refresh()
        update_availability();
        fixed = struct(); free = {};
        for kk = 1:nb
            p   = params{kk};
            sel = get(controls.(p).list, 'Value');   % ItemsData -> numeric
            if isempty(sel)
                sel = get(controls.(p).list, 'ItemsData');
            end
            if get(controls.(p).fix, 'Value')
                fixed.(p) = sel;
            else
                free{end+1} = p; %#ok<AGROW>
            end
        end

        if numel(free) > 1
            title(ax, sprintf('Too many free params (%s). Fix all but one.', ...
                strjoin(free, ', ')));
            return
        end

        mask = true(size(S.a));
        fn = fieldnames(fixed);
        for kk = 1:numel(fn)
            p = fn{kk};
            mask = mask & ismember(S.(p), fixed.(p));
        end

        sel = find(mask);
        if isempty(sel)
            title(ax, 'No configurations match the selection.');
            return
        end

        if isempty(free)
            groups = {sel}; glabel = {''};
        else
            p = free{1};
            gvals = unique(S.(p)(sel));
            groups = cell(1, numel(gvals));
            glabel = cell(1, numel(gvals));
            for g = 1:numel(gvals)
                groups{g} = sel(S.(p)(sel) == gvals(g));
                glabel{g} = sprintf('%s=%g', p, gvals(g));
            end
        end

        % ----------  draw  ----------
        cla(ax);  hold(ax, 'on');
        cla(axm); hold(axm, 'on');
        colors = lines(max(numel(groups), 1));
        stats = [];

        for g = 1:numel(groups)
            idx = groups{g};
            [aa, so] = sort(S.a(idx));
            idx = idx(so);

            phi_major = S.phi_major(idx);
            phi_minor = S.phi_minor(idx);
            mag_major = S.mag_major(idx);
            mag_minor = S.mag_minor(idx);
            resid     = S.resid(idx);

            % wrapped copy for the mask / arc statistics (wrap-safe)
            phi_major_w = mod(phi_major, 360);

            % unwrapped copy for display, referenced to first point -> 0
            pm_u = unwrap(deg2rad(phi_major)) * 180/pi;  pm_u = pm_u - pm_u(1);
            pn_u = unwrap(deg2rad(phi_minor)) * 180/pi;  pn_u = pn_u - pn_u(1);

            keep = usable_mask(aa, phi_major_w, mag_major, resid, ...
                mag_floor_dB, slope_max, resid_max);

            mag_major_dB = 20*log10(mag_major);
            mag_minor_dB = 20*log10(mag_minor);

            % magnitude (always, same axes)
            plot(axm, aa, mag_major_dB, '-o', 'Color', colors(g,:), ...
                'LineWidth', 1.2, 'DisplayName', glabel{g});


            if numel(groups) == 1 && get(controls.showMinor, 'Value')
                % single-curve view: major + minor, legend inside (no width steal)
                plot(ax, aa, pm_u, '-o', 'Color', colors(g,:), ...
                    'LineWidth', 1.3, 'DisplayName', 'major');
                plot(ax, aa, pn_u, '-s', 'Color', [0.6 0.6 0.6], ...
                    'LineWidth', 1.1, 'DisplayName', 'minor');
                legend(ax, 'Location', 'southwest');
                plot(axm, aa, mag_minor_dB, '-s', 'Color', [0.6 0.6 0.6], ...
                    'LineWidth', 1.1, 'DisplayName', 'minor');
                legend(axm, 'Location', 'best');
            else
                % multi-curve view: major only
                plot(ax, aa, pm_u, '-o', 'Color', colors(g,:), ...
                    'LineWidth', 1.2, 'DisplayName', glabel{g});
            end

            % usable points marked at unwrapped coordinates
            plot(ax, aa(keep), pm_u(keep), 'o', 'MarkerSize', 8, ...
                'MarkerEdgeColor', 'r');

            [arc, lo, hi, run_txt] = largest_usable_run(aa, phi_major_w, keep);
            stats(end+1, :) = [g, arc, lo, hi, ...
                mean(phi_minor(keep) - phi_major(keep))]; %#ok<AGROW>
        end

        if numel(groups) > 1 && get(controls.showMinor, 'Value')
            lg = legend(ax, 'Location', 'southwest');
            lg.Interpreter = 'none';
        end
        xlim(ax, [min(aa), max(aa)]);
        yline(axm, mag_floor_dB, '--', 'floor');
        title(ax, 'Phase vs a  (black circles = usable points)');

        % ----------  statistics (text area + console)  ----------
        statsConsoleText = {};
        statsConsoleText{end+1} = '===== selection =====';

        fn = fieldnames(fixed);
        for kk = 1:numel(fn)
            statsConsoleText{end+1} = sprintf('fixed %-10s = %s', ...
                fn{kk}, mat2str(fixed.(fn{kk})));
        end
        if ~isempty(free)
            statsConsoleText{end+1} = sprintf('free  %s', free{1});
        else
            statsConsoleText{end+1} = 'all fixed (single curve)';
        end
        statsConsoleText{end+1} = '';

        statsConsoleText{end+1} = sprintf('%-16s %8s  %-13s %8s', ...
            'group','arc','span','dphi');
        statsConsoleText{end+1} = repmat('-', 1, 50);

        if ~isempty(stats)
            statsSorted = sortrows(stats, -2);        % longest arc first
            for r = 1:size(statsSorted,1)
                g = statsSorted(r,1);
                if g >= 1 && g <= numel(glabel)
                    lbl = glabel{g};
                else
                    lbl = sprintf('group %g', g);
                end
                statsConsoleText{end+1} = sprintf('%-16s %8.1f  %-13s %8.1f', ...
                    lbl, statsSorted(r,2), ...
                    sprintf('%.0f-%.0f', statsSorted(r,3), statsSorted(r,4)), ...
                    statsSorted(r,5));
            end

            if size(statsSorted,1) > 1
                gb = statsSorted(1,1);
                if gb >= 1 && gb <= numel(glabel)
                    lbl = glabel{gb};
                else
                    lbl = sprintf('group %g', gb);
                end
                statsConsoleText{end+1} = '';
                statsConsoleText{end+1} = sprintf('Longest usable arc: %.1f deg  (%s)', ...
                    statsSorted(1,2), lbl);
                statsConsoleText{end+1} = sprintf('Pass A (>= 300 deg): %d', ...
                    statsSorted(1,2) >= 300);
            end
        else
            statsConsoleText{end+1} = '(no usable data)';
        end

        txt.Value = statsConsoleText;

        for k = 1:numel(statsConsoleText)
            fprintf('%s\n', statsConsoleText{k});
        end
    end

    function update_availability()
        % which params are currently fixed, and to what
        fixedNames = {};
        fixedVals  = {};
        for kk = 1:nb
            p = params{kk};
            if get(controls.(p).fix, 'Value')
                sel = get(controls.(p).list, 'Value');
                if ~isempty(sel)
                    fixedNames{end+1} = p;      %#ok<AGROW>
                    fixedVals{end+1}  = sel;    %#ok<AGROW>
                end
            end
        end

        for kk = 1:nb
            p = params{kk};
            isFixed = strcmp(p, fixedNames);

            % constraints = all fixed params EXCEPT p itself
            mask = true(size(S.a));
            for c = 1:numel(fixedNames)
                if ~strcmp(fixedNames{c}, p)
                    mask = mask & ismember(S.(fixedNames{c}), fixedVals{c});
                end
            end

            avail = unique(S.(p)(mask));

            % remember the current selection, keep only still-valid entries
            cur = get(controls.(p).list, 'Value');
            if isempty(cur), cur = get(controls.(p).list, 'ItemsData'); end
            cur = cur(ismember(cur, avail));
            if isempty(cur) && ~isempty(avail)
                cur = avail(1);   % fall back to first available
            end

            % repopulate the listbox
            controls.(p).list.Items     = compose('%g', avail);
            controls.(p).list.ItemsData = avail;
            if ~isempty(cur)
                controls.(p).list.Value = cur;
            end
        end
    end
end

function tf = has_field(cfg, name)
tf = isfield(cfg, name) && any(~isnan([cfg.(name)]));
end

function S = build_struct(cfg, params, lam0, clearance)

% ---- fit check on the raw config list ----
a_all    = [cfg.a].';
ratio_all= [cfg.ratio].';
if isfield(cfg, 'P_ratio') && any(~isnan([cfg.P_ratio]))
    P_all = [cfg.P_ratio].' * lam0;
else
    P_all = repmat(lam0/2, numel(cfg), 1);
end

b_all    = a_all ./ ratio_all;
half_ext = sqrt((a_all.^2 + b_all.^2) / 2);   % 45-deg bounding box
fits     = half_ext <= (P_all/2 - clearance);

fprintf('build_struct: %d of %d configs fail the fit check (removed)\n', ...
    nnz(~fits), numel(fits));

cfg = cfg(fits);                  % <-- drop violating configs here

% ---- everything below operates on the filtered list ----
S.a = [cfg.a].';
for k = 1:numel(params)
    S.(params{k}) = [cfg.(params{k})].';
end

S.phi_major = zeros(numel(cfg),1);
S.phi_minor = zeros(numel(cfg),1);
S.resid     = zeros(numel(cfg),1);
S.mag_major = zeros(numel(cfg),1);
S.mag_minor = zeros(numel(cfg),1);
for i = 1:numel(cfg)
    [theta_star, pm, pn, rs] = principal_phases(cfg(i).S11, cfg(i).S22, cfg(i).S12, cfg(i).S21);
    S.phi_major(i) = pm;
    S.phi_minor(i) = pn;
    S.resid(i)     = rs;
    S.mag_major(i) = abs(cfg(i).S11);
    S.mag_minor(i) = abs(cfg(i).S22);
    % disp(theta_star); % for our UC this should be at 45 degrees
end

% ---- rebuild available values from the surviving configs ----
S.vals = struct();
for k = 1:numel(params)
    S.vals.(params{k}) = unique(S.(params{k}));
end
end