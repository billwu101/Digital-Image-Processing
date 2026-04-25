% Display original image and its R, G, B component images for all images in picture folder
close all;clear;clc;
scriptDir = fileparts(mfilename('fullpath'));
picDir = fullfile(scriptDir, '..', '..', 'Picture');

fileList = dir(fullfile(picDir, '*.jpg'));
fileList = [fileList; dir(fullfile(picDir, '*.jpeg'))];
fileList = [fileList; dir(fullfile(picDir, '*.png'))];
fileList = [fileList; dir(fullfile(picDir, '*.bmp'))];
fileList = [fileList; dir(fullfile(picDir, '*.tif'))];

for i = 1:length(fileList)
    img = imread(fullfile(picDir, fileList(i).name));

    R = img;
    R(:,:,2) = 0;
    R(:,:,3) = 0;

    G = img;
    G(:,:,1) = 0;
    G(:,:,3) = 0;

    B = img;
    B(:,:,1) = 0;
    B(:,:,2) = 0;

    figure;
    sgtitle(fileList(i).name);

    subplot(1,4,1);
    imshow(img);
    title('Original Image');

    subplot(1,4,2);
    imshow(R);
    title('Red Component');

    subplot(1,4,3);
    imshow(G);
    title('Green Component');

    subplot(1,4,4);
    imshow(B);
    title('Blue Component');
end
