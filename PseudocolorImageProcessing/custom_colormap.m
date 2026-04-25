% (f) Custom colormap: emphasize mid-gray range [80, 160]
% Strategy:
%   Shadows  [  0, 79 ] : dark blue  → steel blue   (cool, receding)
%   Midtones [ 80,160 ] : vivid green→ yellow        (highlighted)
%   Lights   [161,255 ] : orange     → white         (bright, hot)

close all; clear; clc;

scriptDir = fileparts(mfilename('fullpath'));
picDir    = fullfile(scriptDir, 'Picture');

fileList = dir(fullfile(picDir, '*.jpg'));
fileList = [fileList; dir(fullfile(picDir, '*.jpeg'))];
fileList = [fileList; dir(fullfile(picDir, '*.png'))];
fileList = [fileList; dir(fullfile(picDir, '*.bmp'))];
fileList = [fileList; dir(fullfile(picDir, '*.tif'))];

if isempty(fileList)
    error('No images found.');
end

for i = 1:length(fileList)
    img = imread(fullfile(picDir, fileList(i).name));
    if size(img, 3) == 3
        grayImg = rgb2gray(img);
    else
        grayImg = img(:,:,1);
    end

    %% Build custom colormap
    N = 256;
    cmap = zeros(N, 3);

    shadow = 1:80;
    mid    = 81:161;
    bright = 162:256;

    t_s = linspace(0, 1, numel(shadow))';
    t_m = linspace(0, 1, numel(mid))';
    t_b = linspace(0, 1, numel(bright))';

    % Shadows: dark navy [0.05 0.05 0.30] → steel blue [0.27 0.51 0.71]
    cmap(shadow, 1) = 0.05 + t_s * (0.27 - 0.05);
    cmap(shadow, 2) = 0.05 + t_s * (0.51 - 0.05);
    cmap(shadow, 3) = 0.30 + t_s * (0.71 - 0.30);

    % Midtones: vivid green [0.13 0.70 0.15] → vivid yellow [1.00 0.90 0.00]
    cmap(mid, 1) = 0.13 + t_m * (1.00 - 0.13);
    cmap(mid, 2) = 0.70 + t_m * (0.90 - 0.70);
    cmap(mid, 3) = 0.15 + t_m * (0.00 - 0.15);

    % Highlights: orange [1.00 0.45 0.00] → white [1.00 1.00 1.00]
    cmap(bright, 1) = 1.00;
    cmap(bright, 2) = 0.45 + t_b * (1.00 - 0.45);
    cmap(bright, 3) = 0.00 + t_b * (1.00 - 0.00);

    %% Display
    figure('Name', ['Custom Colormap — ' fileList(i).name]);
    sgtitle(['Custom Colormap: ' fileList(i).name]);

    subplot(1, 2, 1);
    imagesc(grayImg); colormap(gca, gray()); colorbar;
    axis image off; title('Gray (reference)');

    subplot(1, 2, 2);
    imagesc(grayImg); colormap(gca, cmap); colorbar;
    axis image off;
    title({'Custom: shadow=blue, mid=green→yellow, bright=orange→white'});

    [~, img_name, ~] = fileparts(fileList(i).name);
    out_dir = fullfile(scriptDir, 'result');
    if ~exist(out_dir, 'dir'); mkdir(out_dir); end
    saveas(gcf, fullfile(out_dir, [img_name '_custom_cmap.png']));

    idx     = double(im2uint8(grayImg)) + 1;
    colored = reshape(cmap(idx(:), :), [size(grayImg,1), size(grayImg,2), 3]);
    imwrite(colored, fullfile(out_dir, [img_name '_custom_cmap_img.png']));
end
