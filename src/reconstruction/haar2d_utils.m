function C = haar2d_forward(X)
% HAAR2D_FORWARD Forward 2D Haar Wavelet Decomposition.
    [LoD, HiD] = wfilters('haar', 'd');
    if ndims(X) == 2
        C = quad2d(X, LoD, HiD);
    elseif ndims(X) == 3
        [~, ~, d] = size(X);
        C1 = quad2d(X(:, :, 1), LoD, HiD);
        C = zeros(size(C1, 1), size(C1, 2), d);
        C(:, :, 1) = C1;
        for k = 2:d
            C(:, :, k) = quad2d(X(:, :, k), LoD, HiD);
        end
    else
        error('Input must be 2-D or 3-D.');
    end
end

function CQ = quad2d(A, LoD, HiD)
    [cA, cH, cV, cD] = dwt2(A, LoD, HiD, 'mode', 'sym');
    CQ = [cA, cH; cV, cD];
end

function X = haar2d_inverse(C, outSize)
% HAAR2D_INVERSE Inverse 2D Haar Wavelet Synthesis.
    [LoR, HiR] = wfilters('haar', 'r');
    if ndims(C) == 2
        X = inv2d(C, LoR, HiR, outSize);
    elseif ndims(C) == 3
        [~, ~, d] = size(C);
        X = zeros(outSize(1), outSize(2), d);
        for k = 1:d
            X(:, :, k) = inv2d(C(:, :, k), LoR, HiR, outSize);
        end
    else
        error('Input must be 2-D or 3-D.');
    end
end

function Xs = inv2d(CQ, LoR, HiR, outSize)
    hA = ceil(outSize(1) / 2); wA = ceil(outSize(2) / 2);
    cA = CQ(1:hA,         1:wA);
    cH = CQ(1:hA,         wA+1:2*wA);
    cV = CQ(hA+1:2*hA,    1:wA);
    cD = CQ(hA+1:2*hA,    wA+1:2*wA);
    Xs = idwt2(cA, cH, cV, cD, LoR, HiR, 'mode', 'sym');
    Xs = Xs(1:outSize(1), 1:outSize(2));
end
