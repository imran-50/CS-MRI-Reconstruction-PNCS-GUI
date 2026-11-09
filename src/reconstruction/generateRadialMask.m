function mask = generateRadialMask(N, numSpokes)
% GENERATERADIALMASK Generates a radial undersampling k-space trajectory mask.
%
% Inputs:
%   N         - Image dimensions (N x N)
%   numSpokes - Number of radial spokes
%
% Output:
%   mask      - Binary double mask of size N x N (1 for sampled, 0 otherwise)

    [x, y] = meshgrid(-N/2:N/2-1, -N/2:N/2-1);
    theta = linspace(0, pi, numSpokes);
    mask = false(N, N);
    for i = 1:length(theta)
        t = theta(i);
        xLine = round(x * cos(t) + y * sin(t));
        mask = mask | (xLine == 0);
    end
    mask = double(mask);
end
