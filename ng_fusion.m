function [ldr, report] = ng_fusion(base, ...
    detail, hdr, opts)
% NG_FUSION - Fuse the global TM output with
% the detail layer.
%
%   base   - global TM output (double, HxW)
%   detail - detail layer (double, HxW, signed)
%   hdr    - original HDR image (double, HxWx3)
%   opts   - .detail_max_p/.detail_max_n:
%            detail amplitude budgets
%            .gamma: color restoration gamma;
%            .hdr_lum: optional HDR luminance
%
%   ldr    - fused LDR image (uint8, HxWx3)
%   report - structure with intermediate results

    gamma        = opts.gamma;
    detail_max_p = opts.detail_max_p;
    detail_max_n = opts.detail_max_n;

    % HDR luminance
    if isfield(opts, 'hdr_lum') && ...
        ~isempty(opts.hdr_lum)
        hdr_lum = opts.hdr_lum;
    else
        hdr_lum = ng_lum(hdr);
    end

    % The budget takes the smaller side (Stage 4 of Algorithm 1)
    detail_max = min(detail_max_p, detail_max_n);

    % Hard clipping of the compensated detail
    detail_capped = min(max(detail, ...
        -detail_max), detail_max);

    fused = base + detail_capped;

    % Color restoration (Eq. color_restore)
    ldr = ng_color_reconstruct(fused, ...
        hdr, hdr_lum, gamma);

    % Report
    detail_p = max(detail, 0);
    detail_n = -min(detail, 0);
    report = struct();
    report.base_scaled   = base;
    report.detail_scaled = detail;
    if detail_max > 0
        report.detail_capped = detail_capped;
    else
        report.detail_capped = detail;
    end
    report.detail_p      = detail_p;
    report.detail_n      = detail_n;
    report.fused         = fused;
    report.detail_max    = detail_max;

end