% Pseudocolor image processing: apply different colormaps to a grayscale image

close all; clear; clc;

scriptDir = fileparts(mfilename('fullpath'));
picDir    = fullfile(scriptDir, 'Picture');

fileList = dir(fullfile(picDir, '*.jpg'));
fileList = [fileList; dir(fullfile(picDir, '*.jpeg'))];
fileList = [fileList; dir(fullfile(picDir, '*.png'))];
fileList = [fileList; dir(fullfile(picDir, '*.bmp'))];
fileList = [fileList; dir(fullfile(picDir, '*.tif'))];

if isempty(fileList)
    error('No images found.');
end

for i = 1:length(fileList)
    img  = imread(fullfile(picDir, fileList(i).name));
    if size(img, 3) == 3
        grayImg = rgb2gray(img);   % RGB → grayscale
    else
        grayImg = img(:,:,1);      % already grayscale
    end

    %% --- (e) Three standard colormaps ---
    % Each colormap maps gray intensity [0,255] to a different color scheme:
    %   gray   : neutral grayscale, no added hue, best for unbiased viewing
    %   jet    : blue→cyan→green→yellow→red rainbow, highlights mid-range well
    %   hot    : black→red→yellow→white, mimics thermal / heat maps
    %   parula : cool-blue to warm-yellow, perceptually uniform (MATLAB default)

    maps  = {'gray', 'jet', 'hot', 'parula'};
    nMaps = numel(maps);

    figure('Name', ['Standard Colormaps — ' fileList(i).name]);
    sgtitle(['Standard Colormaps: ' fileList(i).name]);

    for m = 1:nMaps
        subplot(1, nMaps, m);
        imagesc(grayImg);
        colormap(gca, maps{m});
        colorbar;
        axis image off;
        title(maps{m});
    end

    [~, img_name, ~] = fileparts(fileList(i).name);
    out_dir = fullfile(scriptDir, 'result');
    if ~exist(out_dir, 'dir'); mkdir(out_dir); end
    saveas(gcf, fullfile(out_dir, [img_name '_pseudocolor.png']));

    idx = double(im2uint8(grayImg)) + 1;
    for m = 1:nMaps
        cdata   = feval(maps{m}, 256);
        colored = reshape(cdata(idx(:), :), [size(grayImg,1), size(grayImg,2), 3]);
        imwrite(colored, fullfile(out_dir, [img_name '_' maps{m} '.png']));
    end
end
