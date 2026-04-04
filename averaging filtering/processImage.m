% 函式：對單張圖片執行 averaging filter 並顯示結果
function processImage(picture_name)
    imgArray = imread(picture_name);

    if(size(imgArray,3) == 3)
        imgArray = rgb2gray(imgArray);        % 彩色圖轉灰階
    end

    BoxKernal = [1, 1, 1;
                 1, 1, 1;
                 1, 1, 1];

    BoxKernal = BoxKernal .* (1 / 9);

    out = conv2(double(imgArray), BoxKernal, 'same');
    out = uint8(out);

    figure('Name', picture_name);
    subplot(1,2,1);
    imshow(imgArray);
    title(picture_name + " (Origin)" );
    subplot(1,2,2);
    imshow(out);
    title(picture_name + " (Output)" );

    save_figure(picture_name);
end
