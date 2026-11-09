function [binaryMask, tumorOverlay] = segment_tumor(mriImage, upperLimit, lowerThreshold)
% SEGMENT_TUMOR Morphological brain tumor extraction pipeline.
%
% Inputs:
%   mriImage       - Reconstructed or ground truth MRI image (2D grayscale)
%   upperLimit     - Intensity ceiling threshold (Default: 160)
%   lowerThreshold - Tumor intensity floor threshold (Default: 85)
%
% Outputs:
%   binaryMask     - Logical 2D mask of segmented tumor
%   tumorOverlay   - RGB visualization with green tumor segmentation overlay

    if nargin < 2 || isempty(upperLimit), upperLimit = 160; end
    if nargin < 3 || isempty(lowerThreshold), lowerThreshold = 85; end

    if max(mriImage(:)) <= 1.0
        f = mriImage * 255;
    else
        f = double(mriImage);
    end

    f(f > upperLimit) = 0;
    mask = f > lowerThreshold;

    nhood = ones(3, 3);
    bw = imopen(mask, nhood);

    L = bwlabeln(bw);
    stats = regionprops(L, 'Area');
    if isempty(stats)
        binaryMask = false(size(mriImage));
        tumorOverlay = cat(3, mat2gray(mriImage), mat2gray(mriImage), mat2gray(mriImage));
        return;
    end

    A = [stats.Area];
    [~, biggest] = max(A);
    f(L ~= biggest) = 0;

    imA = imadjust(uint8(f));
    filled_imA = imfill(imA, 'holes');
    se = strel('disk', 1);
    imgf = imerode(filled_imA, se);

    binaryMask = logical(imgf > 0);

    baseGray = mat2gray(mriImage);
    tumorOverlay = cat(3, baseGray, baseGray, baseGray);
    tumorOverlay(:, :, 2) = tumorOverlay(:, :, 2) + 0.5 * double(binaryMask);
    tumorOverlay = min(tumorOverlay, 1.0);
end
