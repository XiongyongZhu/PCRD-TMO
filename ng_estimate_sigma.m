function [src_bright, t_stdd, th1, th2] = ...
    ng_estimate_sigma(src_bright, src_std, ...
    r1, r2, r3, ymax, ymin, isAdapt, lambda)
% Estimate the segment boundaries and the
% output standard deviation of the hybrid PDF
% (uniform + trapezoidal mixture).
%   lambda = 0 -> uniform, 1 -> trapezoidal,
%   otherwise -> mixture.
%   (lambda is the mixture weight omega of the main text)

    delta_thresh = 2 * src_std;

    th1 = round((2 * src_bright - r1 * ymin - ...
        ymax * r3 - (r2 + r3) * delta_thresh) / ...
        (r1 + 2 * r2 + r3));
    if th1 < 1, th1 = 1; end
    th2 = round(th1 + delta_thresh);
    if th2 > ymax, th2 = ymax; end

    % Second moment by direct summation over the
    % three segments.
    sum_sq = 0;

    % Dark segment [ymin, th1)
    len1 = th1 - ymin;
    if len1 > 0
        i = ymin : th1 - 1;
        p_unif = r1 / len1;   % uniform component
        p_trap = i * 2 * r1 / (th1^2);
        % right-triangle component
        p = (1 - lambda) * p_unif + lambda * p_trap;
        sum_sq = sum_sq + ...
            sum(p .* (i - src_bright).^2);
    end

    % Middle segment [th1, th2)
    if th2 > th1
        i = th1 : th2 - 1;
        p = r2 / (th2 - th1);
        sum_sq = sum_sq + ...
            p * sum((i - src_bright).^2);
    end

    % Bright segment [th2, ymax]
    if th2 < ymax
        len3 = ymax - th2;
        i = th2 : ymax;
        p_unif = r3 / len3;
        p_trap = 2 * r3 * (ymax - i) / (len3^2);
        p = (1 - lambda) * p_unif + lambda * p_trap;
        sum_sq = sum_sq + ...
            sum(p .* (i - src_bright).^2);
    end

    t_stdd = sqrt(sum_sq);

    % Adaptive output mean
    if isAdapt
        src_bright = (r3 * (ymin + t_stdd) + ...
            r1 * (ymax - t_stdd)) / (r1 + r3);
    end

end