% 函式：對單張圖片執行四種 padding 的 median filter 並顯示結果
function processImage(picture_name)
    imgArray = imread(picture_name);

    if(size(imgArray,3) == 3)
        imgArray = rgb2gray(imgArray);        % 彩色圖轉灰階
    end

    imgArray = double(imgArray);
    pad      = 1;                             % for 3x3 kernel, pad = floor(3/2)

    out_partial = medianPartial(imgArray, pad);   % Partial Kernel Padding
    out_zero    = medianZero(imgArray, pad);      % Zero Padding
    out_rep     = medianReplicate(imgArray, pad); % Replicate Padding
    out_mir     = medianMirror(imgArray, pad);    % Mirror Padding

    out_partial = uint8(out_partial);
    out_zero    = uint8(out_zero);
    out_rep     = uint8(out_rep);
    out_mir     = uint8(out_mir);

    % Verification using medfilt2
    ref          = medfilt2(uint8(imgArray), [3 3]);
    diff_partial = max(abs(double(out_partial) - double(ref)), [], 'all');
    fprintf('[%s] Max difference (Partial Kernel) from medfilt2: %d\n', picture_name, diff_partial);

    figure('Name', picture_name);
    subplot(2,3,1); imshow(uint8(imgArray)); title('Origin');
    subplot(2,3,2); imshow(out_partial);     title('Partial Kernel');
    subplot(2,3,3); imshow(out_zero);        title('Zero Padding');
    subplot(2,3,4); imshow(out_rep);         title('Replicate Padding');
    subplot(2,3,5); imshow(out_mir);         title('Mirror Padding');

    save_figure(picture_name);
end
