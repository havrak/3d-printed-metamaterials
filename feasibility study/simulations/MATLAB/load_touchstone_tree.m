function cfg = load_touchstone_tree(rootdir, f0)
% load_touchstone_tree  Recursively load and merge all subdirectories.
%   De-duplication uses a containers.Map keyed on the parameter signature;
%   the last occurrence of a key replaces earlier ones.

dirs = sort(find_dirs_with_s2p(rootdir));

% ---- gather per-directory blocks ------------------------------------
allcfg = {};
for d = 1:numel(dirs)
    thisDir = dirs{d};
    sub = load_touchstone_dir(thisDir, f0);
    if isempty(sub)
        continue
    end
    for i = 1:numel(sub)
        sub(i).source = thisDir;
    end
    fprintf('loaded %3d configs from %s\n', numel(sub), thisDir);
    allcfg{end+1} = sub;                        %#ok<AGROW>
end

assert(~isempty(allcfg), 'No .s2p data found under %s', rootdir);

% ---- unify field sets before concatenation --------------------------
tmpl       = allcfg{1};
tmplFields = fieldnames(tmpl);
for d = 1:numel(allcfg)
    allcfg{d} = match_fields(allcfg{d}, tmplFields, tmpl(1));
end

flat = [allcfg{:}];        % one flat struct array

% ---- de-duplicate with a Map (O(n)) ---------------------------------
keyMap = containers.Map('KeyType', 'char', 'ValueType', 'double');
nKeep  = 0;
keep   = zeros(numel(flat), 1);    % indices (into flat) of survivors
dupDir = {};                        % for reporting

for i = 1:numel(flat)
    k = param_key(flat(i));
    if isKey(keyMap, k)
        oldIdx = keyMap(k);
        % report the replacement; the new one supersedes
        dupDir{end+1} = sprintf('  DUPLICATE %s\n     earlier: %s\n     replaced by: %s', ...
            k, flat(oldIdx).source, flat(i).source); %#ok<AGROW>
    end
    keyMap(k)  = i;           % latest index wins
end

% survivors = the values currently in the map, in ascending order
survIdx = cell2mat(values(keyMap));
survIdx = sort(survIdx);
cfg = flat(survIdx);

% ---- report ----------------------------------------------------------
for d = 1:numel(dupDir)
    fprintf('%s\n', dupDir{d});
end
fprintf('merged: %d configs (%d duplicates removed)\n', ...
    numel(cfg), numel(flat) - numel(cfg));

    function s = match_fields(s, tfields, tmpl)
        % match_fields  Force every element of s to have exactly tfields, in order.
        for i = 1:numel(s)
            out = struct();
            for f = 1:numel(tfields)
                name = tfields{f};
                if isfield(s(i), name)
                    out.(name) = s(i).(name);
                else
                    tval = tmpl.(name);
                    if ischar(tval)
                        out.(name) = '';
                    elseif isnumeric(tval) || islogical(tval)
                        out.(name) = NaN;
                    else
                        out.(name) = [];
                    end
                end
            end
            s(i) = out;
        end
    end

    function dirs = find_dirs_with_s2p(rootdir)
        % find_dirs_with_s2p  All directories under rootdir containing at least one .s2p.
        dirs = {};
        stack = {rootdir};
        while ~isempty(stack)
            cur = stack{end};
            stack(end) = [];

            if ~isempty(dir(fullfile(cur, '*.s2p')))
                dirs{end+1} = cur; %#ok<AGROW>
            end

            sub = dir(cur);
            for k = 1:numel(sub)
                if sub(k).isdir && ~strcmp(sub(k).name, '.') && ~strcmp(sub(k).name, '..')
                    stack{end+1} = fullfile(cur, sub(k).name); %#ok<AGROW>
                end
            end
        end
    end

    function key = param_key(c)
        key = sprintf('a=%s|H=%s|r=%s|er=%s|Pr=%s', ...
            num2str(c.a), num2str(c.H_pillar), num2str(c.ratio), ...
            num2str(c.epsilon_r), num2str(c.P_ratio));
    end

  
end