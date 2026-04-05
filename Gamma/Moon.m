close all; clear; clc;

imgArray = imread("Moon.jpeg");

if(size(imgArray,3) == 3)
    imgArray = rgb2gray(imgArray);
end

%做gamma轉換前的前置
imgArrayDouble = im2double(imgArray);

c = 1;r = [0.04 0.1 0.2 0.4 0.67 1 1.5 2.5 5 10 25];

imgArrayGammaS = zeros(size(imgArray,1),size(imgArray,2),size(r,2));

%三層迴圈 (Matlab不需要)

% for indexK = 1:size(r,2)
%     for indexI = 1:size(imgArray,1)
%         for indexJ = 1:size(imgArray,2)
%             imgArrayGammaS(indexI,indexJ,indexK) = c * power(imgArrayDouble(indexI,indexJ),r(indexK));
%         end
%     end
% end

%錯誤矩陣次方

% for index = 1:size(r,2)
%     imgArrayGammaS(:,:,index) = c * (imgArrayDouble ^ r(index));
% end

%更加好的寫法 by GPT

for index = 1:size(r,2)
    imgArrayGammaS(:,:,index) = c .* (imgArrayDouble .^ r(index));
end

%原始寫法
% figure;
% imshow(imgArray);
% 
% for index = 1:size(r,2)
%     figure;
%     imshow(imgArrayGammaS(:,:,index));
% end


%利用Subplot by GPT

figure('Name', 'Gamma Correction');

subplot(3,4,1);
imshow(imgArrayDouble);
title('Original');

for index = 1:length(r)
    subplot(3,4,index+1);
    imshow(imgArrayGammaS(:,:,index));
    imwrite(imgArrayGammaS(:,:,index), 'gamma_'  + string(r(index)) + '.jpg');
    title(['gamma = ', num2str(r(index))]);
end


