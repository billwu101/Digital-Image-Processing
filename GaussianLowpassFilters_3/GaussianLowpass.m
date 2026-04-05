close all; clear; clc;

% Read all images in current folder
fileList = [dir('*.jpeg'); dir('*.jpg'); dir('*.png'); dir('*.tiff'); dir('*.tif'); dir('*.bmp')];

for f = 1:length(fileList)
    processImage(fileList(f).name);
end