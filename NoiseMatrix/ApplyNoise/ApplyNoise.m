% Apply Noise to all images in the Picture folder
% Three noise levels: Low / Medium / High
% For each image: 3x4 grid (row=level, col=Original/Gaussian/S&P/Uniform)
clear; close all; clc;

% ── Add noise function directories to MATLAB path ─────────────────────────
noise_root = fileparts(fileparts(mfilename('fullpath')));
addpath(fullfile(noise_root, 'GaussianNoise'));
addpath(fullfile(noise_root, 'SaltPepperNoise'));
addpath(fullfile(noise_root, 'UniformNoise'));

% ── Find all images in Picture folder ────────────────────────────────────
hw4_root  = fileparts(noise_root);
pic_dir   = fullfile(hw4_root, 'Picture');
exts      = {'*.png','*.jpg','*.jpeg','*.bmp','*.tif','*.tiff'};
img_files = [];
for e = 1:numel(exts)
    img_files = [img_files; dir(fullfile(pic_dir, exts{e}))]; %#ok<AGROW>
end

if isempty(img_files)
    error('No images found in %s', pic_dir);
end
fprintf('Found %d image(s) in Picture/\n\n', numel(img_files));

% ── Noise level definitions ───────────────────────────────────────────────
levels(1) = struct('label','Low',    'gauss_std',10,  'Pa',0.01,'Pb',0.01,'uni_a',-20, 'uni_b',20 );
levels(2) = struct('label','Medium', 'gauss_std',25,  'Pa',0.05,'Pb',0.05,'uni_a',-50, 'uni_b',50 );
levels(3) = struct('label','High',   'gauss_std',50,  'Pa',0.15,'Pb',0.15,'uni_a',-100,'uni_b',100);

gauss_mean = 0;
clip = @(x) uint8(min(255, max(0, double(x))));

% ── Process each image ───────────────────────────────────────────────────
for fi = 1:numel(img_files)
    fname   = img_files(fi).name;
    [~, img_name, ~] = fileparts(fname);

    img = imread(fullfile(pic_dir, fname));
    if size(img, 3) == 3, img = rgb2gray(img); end
    [M, N] = size(img);
    img_d  = double(img);

    % Output subfolder per image
    out_dir = fullfile('result', img_name);
    if ~exist(out_dir, 'dir'), mkdir(out_dir); end

    fprintf('Processing: %s  (%dx%d)\n', fname, M, N);

    fig = figure('Name', sprintf('ApplyNoise — %s', img_name), ...
                 'Position', [50 50 1400 780]);

    for k = 1:3
        lv = levels(k);

        n_gauss        = GaussianNoise(M, N, gauss_mean, lv.gauss_std);
        n_uniform      = UniformNoise(M, N, lv.uni_a, lv.uni_b);
        noisy_sp       = SaltPepperNoise(img, lv.Pa, lv.Pb);
        noisy_gaussian = clip(img_d + n_gauss);
        noisy_uniform  = clip(img_d + n_uniform);

        row = (k-1)*4;
        subplot(3,4,row+1); imshow(img);
            title(sprintf('[%s] Original', lv.label));
        subplot(3,4,row+2); imshow(noisy_gaussian);
            title(sprintf('[%s] Gaussian\n\\mu=%g, \\sigma=%g', lv.label, gauss_mean, lv.gauss_std));
        subplot(3,4,row+3); imshow(noisy_sp);
            title(sprintf('[%s] Salt & Pepper\nPa=%.2f, Pb=%.2f', lv.label, lv.Pa, lv.Pb));
        subplot(3,4,row+4); imshow(noisy_uniform);
            title(sprintf('[%s] Uniform\na=%g, b=%g', lv.label, lv.uni_a, lv.uni_b));

        tag = lower(lv.label);
        imwrite(noisy_gaussian, fullfile(out_dir, sprintf('gaussian_%s.png',   tag)));
        imwrite(noisy_sp,       fullfile(out_dir, sprintf('saltpepper_%s.png', tag)));
        imwrite(noisy_uniform,  fullfile(out_dir, sprintf('uniform_%s.png',    tag)));
    end

    sgtitle(sprintf('%s — Added Noise (Low / Medium / High)', img_name));
    imwrite(img, fullfile(out_dir, 'original.png'));
    exportgraphics(fig, fullfile(out_dir, 'ApplyNoise_result.png'), 'Resolution', 300);

    fprintf('  Saved to result/%s/\n\n', img_name);
end

fprintf('Done.\n');
