% Convert RGB to HSV using both rgb2hsv() and manual equations, then compare
close all;clear;clc;
scriptDir = fileparts(mfilename('fullpath'));
picDir = fullfile(scriptDir, '..', '..', 'Picture');

fileList = dir(fullfile(picDir, '*.jpg'));
fileList = [fileList; dir(fullfile(picDir, '*.jpeg'))];
fileList = [fileList; dir(fullfile(picDir, '*.png'))];
fileList = [fileList; dir(fullfile(picDir, '*.bmp'))];
fileList = [fileList; dir(fullfile(picDir, '*.tif'))];

for i = 1:length(fileList)
    img = imread(fullfile(picDir, fileList(i).name));

    %% --- Method 1: built-in rgb2hsv ---
    hsv1 = rgb2hsv(img);
    H1 = hsv1(:,:,1);
    S1 = hsv1(:,:,2);
    V1 = hsv1(:,:,3);

    %% --- Method 2: manual transform equations ---
    imgD = double(img) / 255;   % normalize to [0,1]
    R = imgD(:,:,1);
    G = imgD(:,:,2);
    B = imgD(:,:,3);

    M = max(imgD, [], 3);       % V = max(R,G,B)
    m = min(imgD, [], 3);
    C = M - m;                  % chroma

    V2 = M;

    % Saturation: S = C/V when V>0, else 0
    S2 = zeros(size(M));
    mask = V2 > 0;
    S2(mask) = C(mask) ./ V2(mask);

    % Hue in degrees then normalize to [0,1]
    H2 = zeros(size(M));

    maskR = (M == R) & (C > 0);
    maskG = (M == G) & (C > 0);
    maskB = (M == B) & (C > 0);

    H2(maskR) = mod((G(maskR) - B(maskR)) ./ C(maskR), 6);
    H2(maskG) = (B(maskG) - R(maskG)) ./ C(maskG) + 2;
    H2(maskB) = (R(maskB) - G(maskB)) ./ C(maskB) + 4;

    H2 = H2 / 6;  % convert [0,6) -> [0,1)

    %% --- Difference (absolute error) ---
    diffH = abs(H1 - H2);
    diffS = abs(S1 - S2);
    diffV = abs(V1 - V2);

    %% --- Figure: rgb2hsv (row 1) vs manual equations (row 2) ---
    figure;
    sgtitle(fileList(i).name);

    subplot(2,4,1); imshow(img);                     title('Original');
    subplot(2,4,2); imshow(H1); colormap(gca, hsv);  title('Hue (rgb2hsv)');
    subplot(2,4,3); imshow(S1);                      title('Saturation (rgb2hsv)');
    subplot(2,4,4); imshow(V1);                      title('Value (rgb2hsv)');

    subplot(2,4,5); imshow(img);                     title('Original');
    subplot(2,4,6); imshow(H2); colormap(gca, hsv);  title('Hue (Equations)');
    subplot(2,4,7); imshow(S2);                      title('Saturation (Equations)');
    subplot(2,4,8); imshow(V2);                      title('Value (Equations)');

    %% --- Figure 3: absolute difference ---
%     figure;
%     sgtitle(['[Difference]  ' fileList(i).name]);
%
%     subplot(1,3,1); imshow(diffH, []); colorbar; title(sprintf('Hue diff  max=%.2e', max(diffH(:))));
%     subplot(1,3,2); imshow(diffS, []); colorbar; title(sprintf('Sat diff  max=%.2e', max(diffS(:))));
%     subplot(1,3,3); imshow(diffV, []); colorbar; title(sprintf('Val diff  max=%.2e', max(diffV(:))));
end
