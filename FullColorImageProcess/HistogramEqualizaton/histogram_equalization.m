% Histogram equalization on color images
%   Method 1: equalize each R, G, B channel independently
%   Method 2: equalize only the V (Value) channel in HSV space

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

for i = 1:length(fileList)
    img = imread(fullfile(picDir, fileList(i).name));

    %% --- Method 1: RGB histogram equalization (each channel separately) ---
    R_eq = histeq(img(:,:,1));
    G_eq = histeq(img(:,:,2));
    B_eq = histeq(img(:,:,3));
    img_rgb_eq = cat(3, R_eq, G_eq, B_eq);

    %% --- Method 2: HSV histogram equalization (V channel only) ---
    hsvImg = rgb2hsv(img);
    V_eq   = histeq(im2uint8(hsvImg(:,:,3)));   % equalize V
    hsvImg(:,:,3) = im2double(V_eq);
    img_hsv_eq = hsv2rgb(hsvImg);

    %% --- Display ---
    figure;
    sgtitle(fileList(i).name);

    % Row 1: images
    subplot(2,3,1); imshow(img);        title('Original');
    subplot(2,3,2); imshow(img_rgb_eq); title('RGB Equalized');
    subplot(2,3,3); imshow(img_hsv_eq); title('HSV Equalized (V only)');

    % Row 2: histograms of grayscale brightness for comparison
    subplot(2,3,4);
    imhist(rgb2gray(img));
    title('Histogram: Original');

    subplot(2,3,5);
    imhist(rgb2gray(img_rgb_eq));
    title('Histogram: RGB Equalized');

    subplot(2,3,6);
    imhist(rgb2gray(im2uint8(img_hsv_eq)));
    title('Histogram: HSV Equalized');

    [~, img_name, ~] = fileparts(fileList(i).name);
    out_dir = fullfile(scriptDir, 'result');
    if ~exist(out_dir, 'dir'); mkdir(out_dir); end
    saveas(gcf, fullfile(out_dir, [img_name '_histeq.png']));

    imwrite(img_rgb_eq,           fullfile(out_dir, [img_name '_rgb_eq.png']));
    imwrite(im2uint8(img_hsv_eq), fullfile(out_dir, [img_name '_hsv_eq.png']));
end
