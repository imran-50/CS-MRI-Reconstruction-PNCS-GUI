classdef PNCS_MRI_APP < matlab.apps.AppBase

    properties (Access = public)
        UIFigure                      matlab.ui.Figure
        SHOWMASKButton                matlab.ui.control.Button
        StatusLabel                   matlab.ui.control.Label
        ProgressGauge                 matlab.ui.control.LinearGauge
        ProgressGaugeLabel            matlab.ui.control.Label
        NumberofSpokesEditField       matlab.ui.control.NumericEditField
        NumberofSpokesEditFieldLabel  matlab.ui.control.Label
        RUNPNCSButton                 matlab.ui.control.Button
        LOADIMAGEButton               matlab.ui.control.Button
        UIAxes_4                      matlab.ui.control.UIAxes
        UIAxes_3                      matlab.ui.control.UIAxes
        UIAxes_2                      matlab.ui.control.UIAxes
        UIAxes_Original               matlab.ui.control.UIAxes
    end

    properties (Access = private)
        originalImage
        mask
        numSpokes = 30
        kSpaceFull
        kSpaceUnder
        imgZF
        reconImage
        psnr_vals
        ssim_vals
        defaultDataDir
    end

    methods (Access = private)

        function updateProgress(app, iter, total, pVal, sVal)
            progressPercent = (iter / total) * 100;
            app.ProgressGauge.Value = progressPercent;
            app.StatusLabel.Text = sprintf('Iteration %d/%d | PSNR: %.2f dB', iter, total, pVal);
            drawnow;
        end

        function LOADIMAGEButtonPushed(app, event)
            if isempty(app.defaultDataDir) || ~exist(app.defaultDataDir, 'dir')
                appDir = fileparts(mfilename('fullpath'));
                app.defaultDataDir = fullfile(fileparts(appDir), 'data', 'sample_mri');
            end

            [file, path] = uigetfile({'*.jpg;*.png;*.tif;*.bmp'}, 'Select MRI Image', app.defaultDataDir);
            if isequal(file, 0), return; end

            imgPath = fullfile(path, file);
            img = im2double(imread(imgPath));
            if size(img, 3) > 1, img = rgb2gray(img); end
            app.originalImage = imresize(mat2gray(img), [256, 256]);

            imshow(app.originalImage, 'Parent', app.UIAxes_Original);
            title(app.UIAxes_Original, 'Original MRI');
            app.StatusLabel.Text = 'Status: Image Loaded';
        end

        function SHOWMASKButtonPushed(app, event)
            if isempty(app.originalImage)
                uialert(app.UIFigure, 'Load an image first.', 'No Image');
                return;
            end
            N = size(app.originalImage, 1);
            app.numSpokes = app.NumberofSpokesEditField.Value;

            app.mask = generateRadialMask(N, app.numSpokes);
            imshow(app.mask, [], 'Parent', app.UIAxes_2);
            title(app.UIAxes_2, sprintf('Radial Mask (%d Spokes)', app.numSpokes));

            app.kSpaceFull = fftshift(fft2(app.originalImage));
            app.kSpaceUnder = app.kSpaceFull .* app.mask;

            app.imgZF = abs(ifft2(ifftshift(app.kSpaceUnder)));
            imshow(app.imgZF, [], 'Parent', app.UIAxes_3);
            pZF = psnr(app.imgZF, app.originalImage);
            title(app.UIAxes_3, sprintf('Zero-Filled (PSNR: %.1f dB)', pZF));
            app.StatusLabel.Text = 'Status: Mask and Zero-Filled Ready';
        end

        function RUNPNCSButtonPushed(app, event)
            if isempty(app.originalImage)
                uialert(app.UIFigure, 'Load an image first.', 'Missing Input');
                return;
            end

            app.SHOWMASKButtonPushed(event);
            app.StatusLabel.Text = 'Status: Running PNCS...';

            [app.reconImage, app.psnr_vals, app.ssim_vals] = runPNCS(...
                app.originalImage, app.kSpaceUnder, app.mask, 30, ...
                @(it, tot, p, s) app.updateProgress(it, tot, p, s));

            imshow(app.reconImage, [], 'Parent', app.UIAxes_4);
            title(app.UIAxes_4, sprintf('PNCS Recon (PSNR: %.1f dB)', app.psnr_vals(end)));
            app.StatusLabel.Text = 'Status: Reconstruction Complete!';
        end

        function NumberofSpokesEditFieldValueChanged(app, event)
            app.numSpokes = app.NumberofSpokesEditField.Value;
        end
    end

    methods (Access = private)

        function createComponents(app)
            app.UIFigure = uifigure('Visible', 'off');
            app.UIFigure.Position = [100 100 680 600];
            app.UIFigure.Name = 'PNCS MRI Reconstruction App (Hou et al. 2023)';

            app.UIAxes_Original = uiaxes(app.UIFigure);
            title(app.UIAxes_Original, 'Original MRI');
            app.UIAxes_Original.Position = [20 250 300 200];

            app.UIAxes_2 = uiaxes(app.UIFigure);
            title(app.UIAxes_2, 'Radial Mask');
            app.UIAxes_2.Position = [350 250 300 200];

            app.UIAxes_3 = uiaxes(app.UIFigure);
            title(app.UIAxes_3, 'Zero-Filled Image');
            app.UIAxes_3.Position = [20 30 300 200];

            app.UIAxes_4 = uiaxes(app.UIFigure);
            title(app.UIAxes_4, 'Reconstructed MRI');
            app.UIAxes_4.Position = [350 30 300 200];

            app.LOADIMAGEButton = uibutton(app.UIFigure, 'push');
            app.LOADIMAGEButton.ButtonPushedFcn = createCallbackFcn(app, @LOADIMAGEButtonPushed, true);
            app.LOADIMAGEButton.Position = [30 540 110 30];
            app.LOADIMAGEButton.Text = 'LOAD IMAGE';

            app.SHOWMASKButton = uibutton(app.UIFigure, 'push');
            app.SHOWMASKButton.ButtonPushedFcn = createCallbackFcn(app, @SHOWMASKButtonPushed, true);
            app.SHOWMASKButton.Position = [160 540 110 30];
            app.SHOWMASKButton.Text = 'SHOW MASK';

            app.RUNPNCSButton = uibutton(app.UIFigure, 'push');
            app.RUNPNCSButton.ButtonPushedFcn = createCallbackFcn(app, @RUNPNCSButtonPushed, true);
            app.RUNPNCSButton.Position = [290 540 110 30];
            app.RUNPNCSButton.Text = 'RUN PNCS';

            app.NumberofSpokesEditFieldLabel = uilabel(app.UIFigure);
            app.NumberofSpokesEditFieldLabel.Position = [420 545 110 22];
            app.NumberofSpokesEditFieldLabel.Text = 'Radial Spokes:';

            app.NumberofSpokesEditField = uieditfield(app.UIFigure, 'numeric');
            app.NumberofSpokesEditField.ValueChangedFcn = createCallbackFcn(app, @NumberofSpokesEditFieldValueChanged, true);
            app.NumberofSpokesEditField.Position = [535 545 50 22];
            app.NumberofSpokesEditField.Value = 30;

            app.ProgressGauge = uigauge(app.UIFigure, 'linear');
            app.ProgressGauge.Position = [30 480 370 20];

            app.StatusLabel = uilabel(app.UIFigure);
            app.StatusLabel.Position = [420 480 240 22];
            app.StatusLabel.Text = 'Status: Ready';

            app.UIFigure.Visible = 'on';
        end
    end

    methods (Access = public)
        function app = PNCS_MRI_APP
            appDir = fileparts(mfilename('fullpath'));
            addpath(genpath(fullfile(fileparts(appDir), 'src')));
            createComponents(app);
            registerApp(app, app.UIFigure);
            if nargout == 0, clear app; end
        end

        function delete(app)
            delete(app.UIFigure);
        end
    end
end
