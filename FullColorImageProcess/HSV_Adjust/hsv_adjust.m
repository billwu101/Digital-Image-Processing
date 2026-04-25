% HSV linear adjustment with interactive GUI sliders

close all; clear; clc;

scriptDir = fileparts(mfilename('fullpath'));
picDir = fullfile(scriptDir, '..', 'Picture');

fileList = dir(fullfile(picDir, '*.jpg'));
fileList = [fileList; dir(fullfile(picDir, '*.jpeg'))];
fileList = [fileList; dir(fullfile(picDir, '*.png'))];
fileList = [fileList; dir(fullfile(picDir, '*.bmp'))];
fileList = [fileList; dir(fullfile(picDir, '*.tif'))];

if isempty(fileList)
    error('No images found in Picture folder.');
end

img = imread(fullfile(picDir, fileList(1).name));
hsv0 = rgb2hsv(img);
H0 = hsv0(:,:,1);
S0 = hsv0(:,:,2);
V0 = hsv0(:,:,3);

fprintf('=== Value Range ===\n');
fprintf('  Hue        : [%.4f, %.4f]\n', min(H0(:)), max(H0(:)));
fprintf('  Saturation : [%.4f, %.4f]\n', min(S0(:)), max(S0(:)));
fprintf('  Value      : [%.4f, %.4f]\n', min(V0(:)), max(V0(:)));

%% Build GUI
fig = uifigure('Name', 'HSV Adjuster', 'Position', [50 50 1100 660]);

% --- Image axes ---
axL = uiaxes(fig, 'Position', [10  160 530 470]);
axR = uiaxes(fig, 'Position', [560 160 530 470]);
title(axL, ['Original: ' fileList(1).name]);
axL.XTick = []; axL.YTick = [];
axR.XTick = []; axR.YTick = [];
imshow(img, 'Parent', axL);

% --- Hue slider  [-0.5, 0.5] ---
uilabel(fig, 'Position', [20 120 140 22], 'Text', 'ΔHue (±0.5):', 'FontWeight', 'bold');
slH  = uislider(fig, 'Position', [170 130 800 3], 'Limits', [-0.5 0.5], 'Value', 0, ...
                'MajorTicks', -0.5:0.25:0.5);
lblH = uilabel(fig, 'Position', [990 120 80 22], 'Text', ' 0.00', 'HorizontalAlignment', 'right');

% --- Saturation slider [-1, 1] ---
uilabel(fig, 'Position', [20  75 140 22], 'Text', 'ΔSaturation (±1):', 'FontWeight', 'bold');
slS  = uislider(fig, 'Position', [170  85 800 3], 'Limits', [-1 1], 'Value', 0, ...
                'MajorTicks', -1:0.5:1);
lblS = uilabel(fig, 'Position', [990  75 80 22], 'Text', ' 0.00', 'HorizontalAlignment', 'right');

% --- Value slider [-1, 1] ---
uilabel(fig, 'Position', [20  30 140 22], 'Text', 'ΔValue (±1):', 'FontWeight', 'bold');
slV  = uislider(fig, 'Position', [170  40 800 3], 'Limits', [-1 1], 'Value', 0, ...
                'MajorTicks', -1:0.5:1);
lblV = uilabel(fig, 'Position', [990  30 80 22], 'Text', ' 0.00', 'HorizontalAlignment', 'right');

% --- Store shared data in figure UserData ---
fig.UserData = struct('H0', H0, 'S0', S0, 'V0', V0, ...
                      'axR', axR, 'slH', slH, 'slS', slS, 'slV', slV, ...
                      'lblH', lblH, 'lblS', lblS, 'lblV', lblV);

% Bind callbacks (ValueChangingFcn = live update while dragging)
slH.ValueChangingFcn = @(~,~) updateHSV(fig);
slS.ValueChangingFcn = @(~,~) updateHSV(fig);
slV.ValueChangingFcn = @(~,~) updateHSV(fig);
slH.ValueChangedFcn  = @(~,~) updateHSV(fig);
slS.ValueChangedFcn  = @(~,~) updateHSV(fig);
slV.ValueChangedFcn  = @(~,~) updateHSV(fig);

updateHSV(fig);  % initial render

%% ---------------------------------------------------------------
function updateHSV(fig)
    d = fig.UserData;
    dH = d.slH.Value;
    dS = d.slS.Value;
    dV = d.slV.Value;

    d.lblH.Text = sprintf('%+.2f', dH);
    d.lblS.Text = sprintf('%+.2f', dS);
    d.lblV.Text = sprintf('%+.2f', dV);

    Ha = mod(d.H0 + dH, 1);                    % Hue: wrap [0,1)
    Sa = min(max(d.S0 + dS, 0), 1);            % Saturation: clamp [0,1]
    Va = min(max(d.V0 + dV, 0), 1);            % Value: clamp [0,1]

    imgAdj = hsv2rgb(cat(3, Ha, Sa, Va));
    imshow(imgAdj, 'Parent', d.axR);
    title(d.axR, sprintf('Adjusted   ΔH=%+.2f   ΔS=%+.2f   ΔV=%+.2f', dH, dS, dV));
end
