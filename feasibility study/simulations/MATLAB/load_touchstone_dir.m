function cfg = load_touchstone_dir(dirpath, f0)
% load_touchstone_dir  Parse a directory of CST-exported .s2p files.
%   Metadata is taken from the result-navigator CSV (Run ID join) if present,
%   otherwise from the ".s2p" header (legacy fallback).
%   cfg(i) fields: a, H_pillar, ratio, epsilon_r, P_ratio,
%                  S11, S22, S12, S21, freq

    files = dir(fullfile(dirpath, '*.s2p'));
    assert(~isempty(files), 'No .s2p files found in %s', dirpath);

    % ---- locate the result-navigator CSV ---------------------------------
    csvFiles = dir(fullfile(dirpath, '*Result*Navigator*.csv'));
    if isempty(csvFiles)
        csvFiles = dir(fullfile(dirpath, '*.csv'));   % looser match
    end

    idMap = struct();           % id -> parameter struct
    useCSV = false;
    if ~isempty(csvFiles)
        idMap = read_run_csv(fullfile(dirpath, csvFiles(1).name));
        if ~isempty(fieldnames(idMap))
            useCSV = true;
            fprintf('Using metadata CSV: %s\n', csvFiles(1).name);
        end
    end
    if ~useCSV
        fprintf('No metadata CSV found - falling back to .s2p headers.\n');
    end

    % ---- empty struct template -------------------------------------------
    cfg = struct('a', [], 'H_pillar', [], 'ratio', [], ...
                 'epsilon_r', [], 'P_ratio', [], ...
                 'S11', [], 'S22', [], 'S12', [], 'S21', [], 'freq', []);
    cfg = repmat(cfg, 0, 1);

    for n = 1:numel(files)
        fpath = fullfile(dirpath, files(n).name);
        runID = parse_run_id(files(n).name);

        a = NaN; Hp = NaN; ratio = NaN; er = NaN; Pr = NaN;

        % ---- metadata: CSV first, header fallback ------------------------
        if useCSV && ~isnan(runID) && isfield(idMap, sprintf('r%d', runID))
            m = idMap.(sprintf('r%d', runID));
            a     = getfield_or_nan(m, 'a');
            Hp    = getfield_or_nan(m, 'H_pillar');
            ratio = getfield_or_nan(m, 'ratio');
            er    = getfield_or_nan(m, 'epsilon_r');
            Pr    = getfield_or_nan(m, 'P_ratio');
        end

        % ---- read the S-parameters (always from the file) ----------------
        [f, S] = read_s2p(fpath);

        % ---- legacy header fallback if CSV gave nothing ------------------
        if any(isnan([a Hp ratio er Pr]))
            [a2, Hp2, ratio2, er2, Pr2] = read_header(fpath, f0);
            a     = fillnan(a, a2);
            Hp    = fillnan(Hp, Hp2);
            ratio = fillnan(ratio, ratio2);
            er    = fillnan(er, er2);
            Pr    = fillnan(Pr, Pr2);
        end

        [~, kk] = min(abs(f - f0));
        Sv = S(kk, :);

        c = struct('a', a, 'H_pillar', Hp, 'ratio', ratio, ...
                   'epsilon_r', er, 'P_ratio', Pr, ...
                   'S11', Sv(1), 'S21', Sv(2), 'S12', Sv(3), 'S22', Sv(4), ...
                   'freq', f(kk));
        cfg(end+1) = c;  %#ok<AGROW>
    end
end


function runID = parse_run_id(fname)
% parse_run_id  Extract <id> from "..._3D_Run_RunID_<id>.s2p"
    tok = regexp(fname, 'RunID_(\d+)', 'tokens', 'once');
    if isempty(tok)
        runID = NaN;
    else
        runID = str2double(tok{1});
    end
end

function idMap = read_run_csv(csvpath)
% read_run_csv  Read the CST result-navigator CSV into idMap.r<id> = struct.
%
%   Format produced by CST:
%     - header names and values wrapped in double quotes
%     - columns separated by TAB
%     - values may be padded with spaces inside the quotes
%
%   Example:
%     " 3D Run ID" \t "H_pillar" \t "a" \t "epsilon_r"
%     "1"          \t "2.2"      \t "0.4" \t "5"
%
%   The parser is deliberately manual: it reads raw lines, splits on TAB,
%   strips quotes and whitespace, and converts numerically. This avoids any
%   dependence on readtable's delimiter/quote heuristics.
%
%   Returns idMap with fields idMap.r<id> = struct of parameters.

    idMap = struct();

    % ---- read all non-empty lines ----------------------------------------
    fid = fopen(csvpath, 'r');
    assert(fid > 0, 'Cannot open CSV: %s', csvpath);

    lines = {};
    while true
        l = fgetl(fid);
        if ~ischar(l), break; end
        if isempty(strtrim(l)), continue; end
        % drop UTF-8 BOM if present on the first line
        if isempty(lines) && ~isempty(l)
            l = regexprep(l, '^\xEF\xBB\xBF', '');
        end
        lines{end+1} = l; %#ok<AGROW>
    end
    fclose(fid);

    assert(numel(lines) >= 2, 'CSV has no data rows: %s', csvpath);

    % ---- header ----------------------------------------------------------
    hdr  = split_tab_strip(lines{1});      % cellstr of column names
    nCol = numel(hdr);

    % ---- locate the Run ID column ---------------------------------------
    idCol = find_id_col(hdr, {'3D Run ID','Run ID','RunID','ID'});
    assert(~isempty(idCol), 'No Run ID column in: %s', csvpath);

    % ---- parse each data row --------------------------------------------
    for r = 2:numel(lines)
        fields = split_tab_strip(lines{r});

        % tolerate short rows (pad) or long rows (ignore extras)
        if numel(fields) < nCol
            fields(end+1:nCol) = {''};
        end

        % Run ID
        id = str2double(fields{idCol});
        if isnan(id)
            warning('Skipping row %d: unparsable Run ID', r);
            continue
        end

        % parameters
        m = struct();
        for c = 1:nCol
            if c == idCol, continue; end
            name = hdr{c};
            num  = str2double(fields{c});
            if ~isnan(num)
                m.(name) = num;
            end
        end

        idMap.(sprintf('r%d', id)) = m;
    end
end

function col = find_id_col(hdr, candidates)
% find_id_col  Locate a column index in a cellstr of header names.
%   Case-insensitive, trims whitespace before comparing.
    col = [];
    hdr = strtrim(hdr);
    for k = 1:numel(candidates)
        idx = find(strcmpi(hdr, candidates{k}), 1);
        if ~isempty(idx)
            col = idx;
            return
        end
    end
end

function v = getfield_or_nan(m, name)
    if isfield(m, name)
        v = m.(name);
    else
        v = NaN;
    end
end

function out = fillnan(cur, legacy)
    if isnan(cur)
        out = legacy;
    else
        out = cur;
    end
end

function [f, S] = read_s2p(fpath)
% read_s2p  Read magnitude-angle .s2p, return freq vector and Nx4 complex S.
    fid = fopen(fpath, 'r');
    f = []; S = [];
    while true
        line = fgetl(fid);
        if ~ischar(line), break; end
        tline = strtrim(line);
        if isempty(tline) || startsWith(tline, '!') || startsWith(tline, '#')
            continue
        end
        vals = sscanf(tline, '%f');
        if numel(vals) >= 9
            f(end+1,1) = vals(1);            %#ok<AGROW>
            S11 = vals(2) * exp(1i*deg2rad(vals(3)));
            S21 = vals(4) * exp(1i*deg2rad(vals(5)));
            S12 = vals(6) * exp(1i*deg2rad(vals(7)));
            S22 = vals(8) * exp(1i*deg2rad(vals(9)));
            S(end+1,:) = [S11, S21, S12, S22];  %#ok<AGROW>
        end
    end
    fclose(fid);
end

function [a, Hp, ratio, er, Pr] = read_header(fpath, f0)
    a = NaN; Hp = NaN; ratio = NaN; er = NaN; Pr = NaN;
    fid = fopen(fpath, 'r');
    while true
        line = fgetl(fid);
        if ~ischar(line), break; end
        tline = strtrim(line);
        if startsWith(tline, '! Parameters')
        end
    end
end

function parts = split_tab_strip(line)
% split_tab_strip  Split a TAB-separated line into trimmed, quote-stripped parts.
%   Handles leading/trailing tabs and quoted values such as  " 2.2 " .

    parts = strsplit(line, sprintf('\t'), 'CollapseDelimiters', false);

    for k = 1:numel(parts)
        s = strtrim(parts{k});
        s = strrep(s, '"', '');     % strip all double quotes
        s = strtrim(s);             % trim again after quote removal
        parts{k} = s;
    end
end