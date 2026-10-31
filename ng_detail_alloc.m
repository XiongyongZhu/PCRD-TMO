function [detail_max_p, detail_max_n, ...
    alloc_stats] = ng_detail_alloc(...
    detail_img, f_log, grad_median, ...
    edge_conf, f_stats)
% Rate-distortion gray-level allocation with
% edge-confidence-weighted statistics.
%
%   detail_max_p - positive detail gray-level budget
%                  (integer, >= 2)
%   detail_max_n - negative detail gray-level budget
%                  (integer, >= 2)

    eps_val = 1e-8;

    % Base budget (Eq. base_budget), B_base = 32
    base_budget = max(12, round(32 / ...
        (1 + grad_median * 12)));

    % Log-domain luminance range and median boundary
    if ~isempty(f_stats)
        x_min = f_stats.x_min;
        x_max = f_stats.x_max;
        x_0   = f_stats.x_0;
    else
        f_log_vec = f_log(:);
        x_min = min(f_log_vec);
        x_max = max(f_log_vec);
        x_0   = median(f_log_vec);
    end

    pos_mask = detail_img > 0;
    neg_mask = detail_img < 0;

    % Edge-confidence-weighted statistics of the two sides
    total_pos = sum(edge_conf(pos_mask), 'double');
    if total_pos > eps_val
        pos_vals = detail_img(pos_mask);
        mu_p  = sum(pos_vals .* ...
            edge_conf(pos_mask)) / total_pos;
        diff_sq = (pos_vals - mu_p).^2 .* ...
            edge_conf(pos_mask);
        sigma_p = sqrt(...
            sum(diff_sq, 'double') / total_pos);
    else
        mu_p = 0; sigma_p = 1;
    end

    total_neg = sum(edge_conf(neg_mask), 'double');
    if total_neg > eps_val
        neg_vals = -detail_img(neg_mask);
        mu_n  = sum(neg_vals .* ...
            edge_conf(neg_mask)) / total_neg;
        diff_sq = (neg_vals - mu_n).^2 .* ...
            edge_conf(neg_mask);
        sigma_n = sqrt(...
            sum(diff_sq, 'double') / total_neg);
    else
        mu_n = 0; sigma_n = 1;
    end

    % Allocation weights: position factor times strength ratio
    pos_denom = max(x_max - x_min, eps_val);
    rho_p = (x_max - x_0) / pos_denom;
    rho_n = (x_0 - x_min) / pos_denom;
    xi_p  = max(mu_p / (sigma_p + eps_val), 1);
    xi_n  = max(mu_n / (sigma_n + eps_val), 1);
    w_p = rho_p * xi_p;
    w_n = rho_n * xi_n;

    % Balance-aware total budget (Eq. balance_factor)
    balance = 2 * min(w_p, w_n) / ...
        (w_p + w_n + eps_val);
    detail_budget = max(8, round(base_budget * ...
        (1 - balance * 0.5)));

    % Proportional allocation
    detail_max_p = detail_budget * w_p / ...
        (w_p + w_n + eps_val);
    detail_max_n = detail_budget * w_n / ...
        (w_p + w_n + eps_val);
    detail_max_p = max(0, ...
        min(detail_budget, detail_max_p));
    detail_max_n = max(0, ...
        min(detail_budget, detail_max_n));
    detail_max_p = round(detail_max_p);
    detail_max_n = round(detail_max_n);

    % At least two gray levels per side
    detail_max_p = max(detail_max_p, 2);
    detail_max_n = max(detail_max_n, 2);
    detail_budget = detail_max_p + detail_max_n;

    % Statistics report
    alloc_stats = struct();
    alloc_stats.detail_budget = detail_budget;
    alloc_stats.base_budget   = base_budget;
    alloc_stats.balance       = balance;
    alloc_stats.detail_ratio  = mean(detail_img(:) ~= 0);
    alloc_stats.w_p           = w_p;
    alloc_stats.w_n           = w_n;
    alloc_stats.mu_p          = mu_p;
    alloc_stats.sigma_p       = sigma_p;
    alloc_stats.mu_n          = mu_n;
    alloc_stats.sigma_n       = sigma_n;

end