function [groups, pos] = match_patches(I, patchSize, windowSize, numPatches, step)
% MATCH_PATCHES Locates similar non-local 2D patches in search window.

    [h, w]   = size(I);
    halfP   = floor(patchSize / 2);
    halfWin = floor(windowSize / 2);
    refY = halfP + 1:step:h - halfP;
    refX = halfP + 1:step:w - halfP;
    groups = cell(numel(refY) * numel(refX), 1);
    pos    = cell(size(groups));
    idx = 1;

    for y = refY
        for x = refX
            refPatch = I(y - halfP:y + halfP, x - halfP:x + halfP);
            y0 = max(y - halfWin, halfP + 1); y1 = min(y + halfWin, h - halfP);
            x0 = max(x - halfWin, halfP + 1); x1 = min(x + halfWin, w - halfP);
            cand = zeros(patchSize^2, (y1 - y0 + 1) * (x1 - x0 + 1));
            cPos = zeros(size(cand, 2), 2);
            dists = zeros(1, size(cand, 2));
            k = 1;
            for yy = y0:y1
                for xx = x0:x1
                    p = I(yy - halfP:yy + halfP, xx - halfP:xx + halfP);
                    cand(:, k) = p(:);
                    cPos(k, :) = [yy, xx];
                    dists(k)   = sum((p(:) - refPatch(:)).^2);
                    k = k + 1;
                end
            end
            [~, srt] = sort(dists(1:k-1));
            sel = srt(1:min(numPatches, k-1));
            group = [refPatch(:), cand(:, sel)];
            while size(group, 2) < numPatches + 1
                group = [group, refPatch(:)];
            end
            groups{idx} = group(:);
            pos{idx}    = [[y, x]; cPos(sel, :)];
            idx = idx + 1;
        end
    end
end
