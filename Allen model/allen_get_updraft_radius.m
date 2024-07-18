function [r1, r2] = allen_get_updraft_radius(z, zi, updraft)
    % CALCULATE AVERAGE UPDRAFT SIZE
    zzi = z / zi;
    rbar = (.102 * zzi^(1/3)) * (1 - (.25 * zzi)) * zi;

    % CALCULATE INNER AND OUTER RADIUS OF ROTATED TRAPEZOID UPDRAFT
    r2 = rbar * rgain(updraft.gain); % multiply by random perturbation gain
    if r2 < 10
        r2 = 10; % limit small updrafts to 20m diameter
    end
    if r2 < 600
        r1r2 = .0011 * r2 + .14;
    else
        r1r2 = .8;
    end
    r1 = r1r2 * r2;
end