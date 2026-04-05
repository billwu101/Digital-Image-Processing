close all; clear; clc;

picture = ["Moon.jpeg","WashingtonDC-Band1-Blue-512.tif","gamma_0.67.jpg","gamma_1.jpg","gamma_1.5.jpg"];


for index = 1:size(picture,2)
    HistogramEqualizationfc(picture(index));
end

