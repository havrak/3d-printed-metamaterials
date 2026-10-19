function [theta_star, phi_major, phi_minor, resid] = principal_phases(Sxx, Syy, Sxy, Syx)
% principal_phases  Rotate a 2x2 reflection matrix to its eigenbasis.
%   S is given in the x/y basis; the congruence transform R*S*R.' diagonalises it.
%   Returns the angle of best decorrelation, the two principal-axis phases (deg),
%   and the residual off-diagonal energy (validation metric).

    S = [Sxx, Sxy; Syx, Syy];

    theta_scan = 0:0.5:90;
    best_resid  = inf;
    theta_star  = NaN;
    Rp_best     = [];

    for theta = theta_scan
        c = cosd(theta);
        s = sind(theta);
        R = [c, s; -s, c];
        Rp = R * S * R.';
        resid = abs(Rp(1,2)) + abs(Rp(2,1));
        if resid < best_resid
            best_resid = resid;
            theta_star = theta;
            Rp_best    = Rp;
        end
    end

    resid     = best_resid;
    phi_major = angle(Rp_best(1,1)) * 180/pi;
    phi_minor = angle(Rp_best(2,2)) * 180/pi;
end