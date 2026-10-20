% ---- design parameters ------------------------------------------
f0      = 30;                        % GHz
c0      = 299.792458;                % mm*GHz
lambda0 = c0 / f0;                   % mm

D_lam   = 8:0.25:14;                 % aperture diameter 
FD_list = [0.5 0.75 1.0 1.25 1.5];   % focal length / diameter
tilt_list = [0 10 20 30];            % feed tilt [deg]

nWraps   = nan(numel(FD_list), numel(D_lam), numel(tilt_list));
nThetaMax= nan(numel(FD_list), numel(D_lam), numel(tilt_list));

% ---- main sweep -------------------------------------------------
fprintf('%-8s %-8s %-8s %-12s %-12s\n', ...
    'D/lam', 'F/D', 'tilt', 'wraps', 'theta_max');
fprintf('%s\n', repmat('-', 1, 56));

for dt = 1:numel(D_lam)
    D  = D_lam(dt) * lambda0;
    R  = D/2;

    for ff = 1:numel(FD_list)
        F = FD_list(ff) * D;

        for tt = 1:numel(tilt_list)
            tilt = tilt_list(tt);

            % feed position (tilt about y-axis, |feed| = F)
            xf = F * sind(tilt);
            zf = F * cosd(tilt);

            % sample the aperture edge on a fine angle sweep:
            % theta_i depends only on feed->point distance, so the
            % maximum is always somewhere on the aperture rim.
            a_ring = linspace(0, 2*pi, 721);
            xe = R * cos(a_ring);
            ye = R * sin(a_ring);

            Ri = sqrt((xe - xf).^2 + ye.^2 + zf^2);

            % wrap count: unwrapped path-length phase at the edge / 360
            phi_raw = 360 * (Ri - zf) / lambda0;
            nWraps(ff,dt,tt)    = max(phi_raw) / 360;

            % max incidence angle (angle of feed->element ray from normal)
            theta_i = acosd(zf ./ Ri);
            nThetaMax(ff,dt,tt) = max(theta_i);

            fprintf('%-8.2f %-8.2f %-8d %-12.2f %-12.1f\n', ...
                D_lam(dt), FD_list(ff), tilt, ...
                nWraps(ff,dt,tt), nThetaMax(ff,dt,tt));
        end
    end
end

% ---- figure 1: number of wraps vs aperture size ----------------
figure('Name', 'Phase wraps vs aperture');
for tt = 1:numel(tilt_list)
    subplot(2,2,tt); hold on; grid on;
    for ff = 1:numel(FD_list)
        plot(D_lam, squeeze(nWraps(ff,:,tt)), '-o', ...
            'LineWidth', 1.3, ...
            'DisplayName', sprintf('F/D = %.2f', FD_list(ff)));
    end
    xlabel('Aperture D / \lambda_0');
    ylabel('Number of phase wraps');
    title(sprintf('Feed tilt = %d deg', tilt_list(tt)));
    legend('Location', 'northwest');
end

% ---- figure 2: max incidence angle vs F/D ------------
% Max incidence angle is constant for different aperture sizes with fixed 
% F/D ratio
figure('Name', 'Max incidence angle vs F/D');
for tt = 1:numel(tilt_list)
    subplot(2,2,tt); hold on; grid on;
    plot(FD_list, squeeze(nThetaMax(:,1,tt)), '-o', ...
        'LineWidth', 1.3);
    xlabel('F/D');
    ylabel('Max incidence angle \theta_{i,max} (deg)');
    title(sprintf('Feed tilt = %d deg', tilt_list(tt)));
    ylim([0 60]);
end