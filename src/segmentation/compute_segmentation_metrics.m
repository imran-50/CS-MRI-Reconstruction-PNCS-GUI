function metrics = compute_segmentation_metrics(groundTruthMask, predictedMask)
% COMPUTE_SEGMENTATION_METRICS Evaluates clinical boundary overlap metrics.

    GT  = logical(groundTruthMask);
    SEG = logical(predictedMask);

    if ~isequal(size(GT), size(SEG))
        SEG = imresize(SEG, size(GT), 'nearest');
    end

    TP = sum(GT(:) & SEG(:));
    FP = sum(~GT(:) & SEG(:));
    FN = sum(GT(:) & ~SEG(:));
    TN = sum(~GT(:) & ~SEG(:));

    denom_dice = (2 * TP + FP + FN);
    denom_jacc = (TP + FP + FN);

    metrics = struct();
    if denom_dice == 0
        metrics.Dice = 1.0;
    else
        metrics.Dice = 2 * TP / denom_dice;
    end

    if denom_jacc == 0
        metrics.Jaccard = 1.0;
    else
        metrics.Jaccard = TP / denom_jacc;
    end

    if (TP + FN) == 0
        metrics.Sensitivity = 1.0;
    else
        metrics.Sensitivity = TP / (TP + FN);
    end

    if (TN + FP) == 0
        metrics.Specificity = 1.0;
    else
        metrics.Specificity = TN / (TN + FP);
    end

    metrics.Accuracy = (TP + TN) / (TP + TN + FP + FN);
end
