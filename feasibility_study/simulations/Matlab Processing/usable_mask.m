function keep = usable_mask(a, phi_major, mag_major, resid, floor_dB, slope_max, resid_max)
    mag_dB = 20*log10(mag_major);
    a_col = a(:); ph = phi_major(:);
    dphi = nan(size(a_col));
    dphi(1:end-1) = diff(ph) ./ diff(a_col);
    keep = (mag_dB > floor_dB) & (abs(dphi) < slope_max) & (resid < resid_max);
    keep(isnan(dphi)) = (mag_dB(isnan(dphi)) > floor_dB) & (resid(isnan(dphi)) < resid_max);
end