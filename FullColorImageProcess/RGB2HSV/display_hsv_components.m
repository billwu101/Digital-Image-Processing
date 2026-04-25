% Convert RGB to HSV and display Hue, Saturation, Value component images

scriptDir = fileparts(mfilename('fullpath'));
picDir = fullfile(scriptDir, '..', '..', 'Picture');

fileList = dir(fullfile(picDir, '*.jpg'));
fileList = [fileList; dir(fullfile(picDir, '*.jpeg'))];
fileList = [fileList; dir(fullfile(picDir, '*.png'))];
fileList = [fileList; dir(fullfile(picDir, '*.bmp'))];
fileList = [fileList; dir(fullfile(picDir, '*.tif'))];

for i = 1:length(fileList)
    img = imread(fullfile(picDir, fileList(i).name));

    % rgb2hsv expects double in [0,1] and returns H,S,V each in [0,1]
    hsvImg = rgb2hsv(img);

    H = hsvImg(:,:,1); % Hue
    S = hsvImg(:,:,2); % Saturation
    V = hsvImg(:,:,3); % Value

    figure;
    sgtitle(fileList(i).name);

    subplot(1,4,1);
    imshow(img);
    title('Original Image');

    subplot(1,4,2);
    imshow(H);
    colormap(gca, hsv);  % use HSV colormap to represent hue intuitively
    title('Hue');

    subplot(1,4,3);
    imshow(S);
    title('Saturation');

    subplot(1,4,4);
    imshow(V);
    title('Value');
end
