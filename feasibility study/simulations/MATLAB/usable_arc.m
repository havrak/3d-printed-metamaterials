function [span, lo, hi] = usable_arc(phases_deg)
% usable_arc  Span of the smallest arc containing all given phases.
%   All inputs are taken modulo 360. The result is the complement of the
%   largest angular gap between consecutive (sorted) points.

    ph = sort(mod(phases_deg(:), 360));
    if numel(ph) < 2
        span = 0; lo = ph(1); hi = ph(1); return
    end

    % gaps between consecutive points, including the wrap-around gap
    gaps      = diff([ph; ph(1) + 360]);
    [gap_max, k] = max(gaps);

    % the usable arc starts just after the largest gap
    lo   = ph(mod(k, numel(ph)) + 1);
    hi   = ph(k);
    span = 360 - gap_max;
end