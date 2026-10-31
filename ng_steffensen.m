function [t_stdd, th1, th2, count] = ...
    ng_steffensen(src_bright, x0, r1, r2, ...
    r3, ymax, ymin, isAdapt, max_iterations, lambda)
% Steffensen iteration for the optimal output
% standard deviation.

    if ~exist('isAdapt','var'), isAdapt = true; end
    if ~exist('max_iterations','var'), ...
        max_iterations = 50; end
    if ~exist('lambda', 'var'), lambda = 1.0; end

    tolerance = 10e-2;
    sigma_curr = x0;

    for i = 1 : max_iterations
        [src_bright, sigma_1, ~, ~] = ...
            ng_estimate_sigma(src_bright, ...
            sigma_curr, r1, r2, r3, ymax, ...
            ymin, isAdapt, lambda);
        [src_bright, sigma_2, thresh_1, ...
            thresh_2] = ng_estimate_sigma(...
            src_bright, sigma_1, r1, r2, ...
            r3, ymax, ymin, isAdapt, lambda);

        denom = sigma_2 - 2*sigma_1 + sigma_curr;
        if abs(denom) < 1e-12
            sigma_next = sigma_curr;
        else
            sigma_next = sigma_curr - ...
                (sigma_1 - sigma_curr)^2 / denom;
        end

        if isnan(sigma_next) || isinf(sigma_next)
            sigma_next = sigma_curr;
        end
        sigma_next = max(1, min(255, sigma_next));

        error = abs(sigma_next - sigma_curr);

        % Convergence check
        if error < tolerance || ...
            i + 1 >= max_iterations
            t_stdd = sigma_next;

            % Segment boundaries of the converged solution
            th1 = max(1, thresh_1);
            th2 = min(ymax, max(th1 + 1, thresh_2));

            break;
        else
            sigma_curr = sigma_next;
        end
    end

    % Fallback if the loop exits without convergence
    if ~exist('t_stdd', 'var')
        t_stdd = sigma_curr;
        th1 = max(1, round(ymax / 3));
        th2 = min(ymax - 1, ...
            max(th1 + 1, round(2 * ymax / 3)));
        warning('ng_steffensen did not ' ...
            'converge; fallback used');
    end
    count = i;

end