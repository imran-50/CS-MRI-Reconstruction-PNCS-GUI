function Mp_out = bi_hard_threshold(Mp, sigma, tau)
% BI_HARD_THRESHOLD 2D Haar Wavelet thresholding on 2D patches.

    [q, m] = size(Mp);
    C = haar2d_forward(Mp);
    th = tau * sigma;
    C(abs(C) < th) = 0;
    C(ceil(q/2) + 1:end, :) = 0;
    C(:, ceil(m/2) + 1:end) = 0;
    Mp_out = haar2d_inverse(C, [q, m]);
end
