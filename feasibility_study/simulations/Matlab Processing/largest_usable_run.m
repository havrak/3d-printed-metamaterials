function [arc, lo, hi, run_txt] = largest_usable_run(a, phi_major, keep)
% longest contiguous run of usable points; span measured as smallest arc.
    d = diff([false; keep(:); false]);
    st = find(d == 1); en = find(d == -1) - 1;
    if isempty(st)
        arc = 0; lo = NaN; hi = NaN; run_txt = 'none'; return
    end
    lens = en - st + 1;
    [~, r] = max(lens);
    s = st(r); e = en(r);
    ph = sort(mod(phi_major(s:e), 360));
    gaps = diff([ph; ph(1)+360]);
    [gap_max, kk] = max(gaps);
    arc = 360 - gap_max;
    lo  = ph(mod(kk, numel(ph)) + 1);
    hi  = ph(kk);
    run_txt = sprintf('a=%.2f..%.2f', a(s), a(e));
end