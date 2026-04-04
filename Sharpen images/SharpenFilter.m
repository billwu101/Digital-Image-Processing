close all; clear; clc;

% 讀取資料夾內所有圖片（排除含 "result" 的檔名）
allFiles = [dir('*.jpeg'); dir('*.jpg'); dir('*.png'); dir('*.tiff'); dir('*.tif'); dir('*.bmp')];
mask = ~contains({allFiles.name}, 'result');
fileList = allFiles(mask);

for f = 1:length(fileList)
    processImage(fileList(f).name);
end

