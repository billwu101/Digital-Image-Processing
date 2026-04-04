function processImage(filename)
    % 讀取圖片並轉為灰階
    img = imread(filename);

    if size(img, 3) == 3
        img = rgb2gray(img);
    end
    
    img = double(img);

    % Laplacian kernel
    kernel = [1  1  1;
              1 -8  1;
              1  1  1];

    % 對圖片做 Laplacian 卷積（使用 zero-padding）
    laplacian = conv2(img, kernel, 'same');

    % 銳化影像 = 原始影像 - Laplacian 影像
    sharpened = img - laplacian;

    % 截斷至 [0, 255]
    sharpened = max(0, min(255, sharpened));

    % 顯示三張圖
    [~, name, ~] = fileparts(filename);
    figure('Name', name);

    subplot(1, 3, 1);
    imshow(uint8(img));
    title('Original');

    subplot(1, 3, 2);
    
    % Laplacian 正規化至 [0,255] 以便顯示
    lap_display = laplacian - min(laplacian(:));
    lap_display = lap_display / max(lap_display(:)) * 255;

    imshow(uint8(lap_display));
    title('Laplacian');

    subplot(1, 3, 3);
    imshow(uint8(sharpened));
    title('Sharpened');

    save_figure(filename);
end
