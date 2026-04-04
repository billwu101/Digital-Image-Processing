clc; clear; close all;

% 讀圖
img = imread('Moon.jpeg');   % 你也可以換成自己的圖片
%img = imread('hurricaneAndrew.tif');   % 你也可以換成自己的圖片


img = im2double(img);

% 左邊：真正的 box kernel
k1 = (1/9) * [1 1 1;
              1 1 1;
              1 1 1];

% 右邊：加權平均 kernel（比較接近 Gaussian）
k2 = (1/16) * [1 2 1;
               2 4 2;
               1 2 1];

% 做濾波
out1 = imfilter(img, k1, 'replicate');
out2 = imfilter(img, k2, 'replicate');

% 顯示結果
figure;
subplot(1,3,1); imshow(img, []);  title('Original');
subplot(1,3,2); imshow(out1, []); title('Box kernel: 1/9');
subplot(1,3,3); imshow(out2, []); title('Weighted kernel: 1/16');