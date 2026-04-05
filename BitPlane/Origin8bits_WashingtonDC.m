close all; clear; clc;

imgArray = imread("WashingtonDC-Band1-Blue-512.tif");

if(size(imgArray,3) == 3)
    imgArray = rgb2gray(imgArray);
end

imgArrayBitPlane = zeros(size(imgArray,1),size(imgArray,2),8,'uint8');
Reconstruct = zeros(size(imgArray,1),size(imgArray,2),'uint8');     %uint8
ReconstructNum = 4;


for indexI = 1:size(imgArray,1)
    for indexJ = 1:size(imgArray,2)

        bits = dec2bin(imgArray(indexI,indexJ), 8) - '0';           %by GPT的寫法

        array = zeros(1,8);

        for index = 1:8
            if(bits(index) == 0)
                imgArrayBitPlane(indexI,indexJ,index) = 0;
            elseif(bits(index) == 1)
                imgArrayBitPlane(indexI,indexJ,index) = 255;
            end
        end

        array(1:ReconstructNum) = bits(1:ReconstructNum);

        Reconstruct(indexI,indexJ) = bin2dec(char(array + '0'));

    end
end


figure('Name', '8 bits plane');

subplot(3,4,1);
imshow(imgArray);
title('Original');

subplot(3,4,2);
imshow(Reconstruct);
title("Reconstruct with : " + num2str(ReconstructNum) + "bits");


for index = 1:8
    subplot(3,4,4 + index);
    imshow(imgArrayBitPlane(:,:,index));
    title([num2str(9 - index),' bit']);
end