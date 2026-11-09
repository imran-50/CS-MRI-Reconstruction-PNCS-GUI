function [recon, psnr_vals, ssim_vals] = runPNCS(imgOriginal, kSpaceUnder, mask, K, progressCallback)
% RUNPNCS Pixel-Level Non-Local Compressed Sensing MRI Reconstruction.
% Based on: Hou et al., IEEE Access, vol. 11, pp. 42389-42402, 2023.
%
% Inputs:
%   imgOriginal      - Fully sampled ground truth image (for PSNR/SSIM tracking)
%   kSpaceUnder      - Centered undersampled k-space (fftshift applied)
%   mask             - Binary sampling mask (1=sampled, 0=unsampled)
%   K                - Number of iterations (Default: 30)
%   progressCallback - (Optional) function handle @(iter, total, psnr, ssim)

    if nargin < 4 || isempty(K), K = 30; end
    if nargin < 5, progressCallback = []; end

    maxVal = max(imgOriginal(:));
    if maxVal == 0, maxVal = 1; end

    sigma_max = 80 * (maxVal / 255);
    sigma_min = 1.33 * (maxVal / 255);
    sigma_vec = logspace(log10(sigma_max), log10(sigma_min), K);

    Lk = abs(ifft2(ifftshift(kSpaceUnder)));
    D0 = kSpaceUnder;
    M = double(mask == 0);
    prev_ref = zeros(size(Lk));

    psnr_vals = zeros(1, K);
    ssim_vals = zeros(1, K);

    for k = 1:K
        if k == 1
            stage = 'basic';
            refImg = Lk;
        else
            stage = 'wiener';
            refImg = prev_ref;
        end

        Lk_ref = PNR(Lk, refImg, sigma_vec(k), stage);

        Dk = fftshift(fft2(Lk_ref));
        Lk = ifft2(ifftshift(D0 + Dk .* M));
        prev_ref = Lk_ref;

        imgEst = abs(Lk);
        psnr_vals(k) = psnr(imgEst, imgOriginal);
        ssim_vals(k) = ssim(imgEst, imgOriginal);

        if ~isempty(progressCallback)
            progressCallback(k, K, psnr_vals(k), ssim_vals(k));
        end
    end
    recon = abs(Lk);
end
