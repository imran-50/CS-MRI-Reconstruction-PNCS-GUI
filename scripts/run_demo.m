% ============================================================================
% SCRIPTS/RUN_DEMO.M
% Replicates PNCS reconstruction and downstream tumor segmentation evaluation.
% ============================================================================
close all; clear; clc;

% 1. Dynamically resolve project root
scriptDir = fileparts(mfilename('fullpath'));
projectRoot = fileparts(scriptDir);
addpath(genpath(fullfile(projectRoot, 'src')));

% 2. Relative sample paths
mriPath  = fullfile(projectRoot, 'data', 'sample_mri', 'brain_tumor_359.png');
maskPath = fullfile(projectRoot, 'data', 'sample_masks', 'tumor_mask_359.png');

if ~exist(mriPath, 'file')
    fprintf('Demo sample not found at: %s\n', mriPath);
    fprintf('Please place your sample brain MRI slice in data/sample_mri/\n');
    return;
end

fprintf('Loading image: %s\n', mriPath);
img = im2double(imread(mriPath));
if size(img, 3) > 1, img = rgb2gray(img); end
img = imresize(mat2gray(img), [256, 256]);
N = size(img, 1);

% 3. Generate Undersampled k-Space
numSpokes = 30;
fprintf('Generating radial undersampling mask with %d spokes...\n', numSpokes);
mask = generateRadialMask(N, numSpokes);

kSpaceFull = fftshift(fft2(img));
kSpaceUnder = kSpaceFull .* mask;

imgZF = abs(ifft2(ifftshift(kSpaceUnder)));
psnr_zf = psnr(imgZF, img);
ssim_zf = ssim(imgZF, img);
fprintf('Zero-Filled Reconstruction | PSNR: %.2f dB | SSIM: %.4f\n', psnr_zf, ssim_zf);

% 4. Run PNCS Reconstruction
fprintf('Executing PNCS Reconstruction (30 iterations)...\n');
[reconImg, psnr_vals, ssim_vals] = runPNCS(img, kSpaceUnder, mask, 30, ...
    @(iter, total, p, s) fprintf('  Iteration %02d/%d | PSNR: %.2f dB | SSIM: %.4f\n', iter, total, p, s));

% 5. Downstream Clinical Tumor Segmentation
fprintf('\nPerforming downstream tumor segmentation...\n');
[segRecon, overlayRecon] = segment_tumor(reconImg);

if exist(maskPath, 'file')
    gtMask = imread(maskPath);
    if size(gtMask, 3) > 1, gtMask = rgb2gray(gtMask); end
    gtMask = imresize(logical(gtMask), [N, N]);

    metrics = compute_segmentation_metrics(gtMask, segRecon);
    fprintf('==================================================\n');
    fprintf('DOWNSTREAM CLINICAL SEGMENTATION METRICS:\n');
    fprintf('==================================================\n');
    fprintf('  Dice Similarity Coefficient : %.4f\n', metrics.Dice);
    fprintf('  Jaccard Index (IoU)         : %.4f\n', metrics.Jaccard);
    fprintf('  Sensitivity (Recall)        : %.4f\n', metrics.Sensitivity);
    fprintf('  Specificity                 : %.4f\n', metrics.Specificity);
    fprintf('  Accuracy                    : %.4f\n', metrics.Accuracy);
    fprintf('==================================================\n');
end

% 6. Visualization
figure('Name', 'Reconstruction and Clinical Validation', 'Position', [100, 100, 1200, 700]);
subplot(2, 3, 1); imshow(img, []); title('Original Fully Sampled MRI');
subplot(2, 3, 2); imshow(mask, []); title(sprintf('Radial Mask (%d Spokes)', numSpokes));
subplot(2, 3, 3); imshow(imgZF, []); title(sprintf('Zero-Filled (PSNR: %.2f dB)', psnr_zf));
subplot(2, 3, 4); imshow(reconImg, []); title(sprintf('PNCS Reconstructed (PSNR: %.2f dB)', psnr_vals(end)));
subplot(2, 3, 5); imshow(segRecon, []); title('Segmented Tumor Mask');
subplot(2, 3, 6); imshow(overlayRecon, []); title('Clinical Tumor Overlay');
