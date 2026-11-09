function Ik_ref = PNR(Ik, Ik_prev, sigma, stage)
% PNR Patch-based Non-local Regularization step.

    switch stage
        case 'basic'
            P = 13; W = 23; N = 16; step = 12; tau = 6;
        case 'wiener'
            P = 21; W = 13; N = 64; step = 21; tau = 6; alpha = 0.5;
        otherwise
            error('stage must be basic or wiener');
    end

    [h, w] = size(Ik);
    rec = zeros(h, w); wt = zeros(h, w);
    [G, Pos] = match_patches(Ik, P, W, N, step);

    for k = 1:numel(G)
        Mp = reshape(G{k}, P, P, N + 1);
        if strcmp(stage, 'basic')
            for p = 1:N + 1
                Mp(:, :, p) = bi_hard_threshold(Mp(:, :, p), sigma, tau);
            end
        end
        for p = 1:size(Pos{k}, 1)
            y = Pos{k}(p, 1); x = Pos{k}(p, 2);
            ys = y - floor(P / 2); xs = x - floor(P / 2);
            ye = ys + P - 1;       xe = xs + P - 1;
            yy = max(1, ys):min(h, ye); xx = max(1, xs):min(w, xe);
            pt = Mp(1:numel(yy), 1:numel(xx), p);
            rec(yy, xx) = rec(yy, xx) + pt;
            wt(yy, xx)  = wt(yy, xx)  + 1;
        end
    end
    Ik_basic = rec ./ max(wt, 1e-6);

    if strcmp(stage, 'wiener')
        Ik_ref = wiener_filtering(Ik_basic, Ik_prev, sigma, P, W, N, step, alpha);
    else
        Ik_ref = Ik_basic;
    end
end
