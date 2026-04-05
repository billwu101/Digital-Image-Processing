close all; clear; clc;

imgArray = imread("WashingtonDC-Band1-Blue-512.tif");

if(size(imgArray,3) == 3)
    imgArray = rgb2gray(imgArray);
end


level = 0:255;

Histogram = myHistogram(imgArray);

figure('Name', 'Histogram');

subplot(1,2,1)
imshow(imgArray);
subplot(1,2,2)
b = bar(level, Histogram,'c');
xlabel('Gray level');
ylabel('# of pixels');
title('Histogram');