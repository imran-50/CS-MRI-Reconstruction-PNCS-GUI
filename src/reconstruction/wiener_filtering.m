function Ik = wiener_filtering(Ib, Ip, sigma, patchSize, windowSize, numPatches, step, alpha)
% WIENER_FILTERING 3D Collaborative Wiener Filtering step.

    [h, w] = size(Ib);
    rec = zeros(h, w); wt = zeros(h, w);
    [Gb, Pb] = match_patches(Ib, patchSize, windowSize, numPatches, step);
    [Gp, ~ ] = match_patches(Ip, patchSize, windowSize, numPatches, step);

    for k = 1:numel(Gb)
        vecB = Gb{k}; vecP = Gp{k};
        MpB  = reshape(vecB, patchSize, patchSize, numPatches + 1);
        MpP  = reshape(vecP, patchSize, patchSize, numPatches + 1);
        CB = haar2d_forward(MpB);
        CP = haar2d_forward(MpP);
        Cc = alpha * CB + (1 - alpha) * CP;
        Cf = (abs(Cc).^2 ./ (abs(Cc).^2 + sigma^2 + eps)) .* CB;
        MpF = haar2d_inverse(Cf, [patchSize, patchSize]);
        for p = 1:size(Pb{k}, 1)
            y = Pb{k}(p, 1); x = Pb{k}(p, 2);
            ys = y - floor(patchSize / 2); xs = x - floor(patchSize / 2);
            ye = ys + patchSize - 1;       xe = xs + patchSize - 1;
            yy = max(1, ys):min(h, ye);    xx = max(1, xs):min(w, xe);
            pp = MpF(1:numel(yy), 1:numel(xx), p);
            rec(yy, xx) = rec(yy, xx) + pp;
            wt(yy, xx)  = wt(yy, xx)  + 1;
        end
    end
    Ik = rec ./ max(wt, 1e-6);
end
