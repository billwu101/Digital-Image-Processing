close all; clear; clc;

% 讀取資料夾內所有圖片
fileList = [dir('*.jpeg'); dir('*.jpg'); dir('*.png'); dir('*.tiff'); dir('*.tif'); dir('*.bmp')];

for f = 1:length(fileList)
    processImage(fileList(f).name);
end