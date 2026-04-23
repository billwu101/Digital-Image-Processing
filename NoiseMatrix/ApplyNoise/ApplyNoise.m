% Apply Noise to Grayscale Stripes Image
% Three noise levels: Low / Medium / High
% Displays a 3x4 grid: each row = one level, cols = Original/Gaussian/S&P/Uniform
clear;close all;clc;
% ── Add noise function directories to MATLAB path ─────────────────────────
noise_root = fileparts(fileparts(mfilename('fullpath')));
addpath(fullfile(noise_root, 'GaussianNoise'));
addpath(fullfile(noise_root, 'SaltPepperNoise'));
addpath(fullfile(noise_root, 'UniformNoise'));

% ── Load original image ───────────────────────────────────────────────────
hw4_root = fileparts(noise_root);
img = imread(fullfile(hw4_root, 'Picture', 'grayscale_stripes.png'));
if size(img, 3) == 3, img = rgb2gray(img); end
[M, N] = size(img);

% ── Noise level definitions ───────────────────────────────────────────────
%   Fields: label, gauss_std, Pa, Pb, uni_a, uni_b
levels(1) = struct('label','Low',    'gauss_std',10,  'Pa',0.01,'Pb',0.01,'uni_a',-20, 'uni_b',20 );
levels(2) = struct('label','Medium', 'gauss_std',25,  'Pa',0.05,'Pb',0.05,'uni_a',-50, 'uni_b',50 );
levels(3) = struct('label','High',   'gauss_std',50,  'Pa',0.15,'Pb',0.15,'uni_a',-100,'uni_b',100);

gauss_mean = 0;
clip = @(x) uint8(min(255, max(0, double(x))));
img_d = double(img);

% ── Display 3x4 grid ─────────────────────────────────────────────────────
figure('Position', [50 50 1400 780]);

if ~exist('result', 'dir'), mkdir('result'); end

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

    % Save individual noisy images
    tag = lower(lv.label);
    imwrite(noisy_gaussian, fullfile('result', sprintf('gaussian_%s.png',    tag)));
    imwrite(noisy_sp,       fullfile('result', sprintf('saltpepper_%s.png',  tag)));
    imwrite(noisy_uniform,  fullfile('result', sprintf('uniform_%s.png',     tag)));
end

sgtitle('Grayscale Stripes with Added Noise (Low / Medium / High)');

imwrite(img, fullfile('result', 'original.png'));
exportgraphics(gcf, fullfile('result', 'ApplyNoise_result.png'), 'Resolution', 300);

fprintf('Done. Results saved to ApplyNoise/result/\n');
for k = 1:3
    tag = lower(levels(k).label);
    fprintf('  gaussian_%s.png | saltpepper_%s.png | uniform_%s.png\n', tag, tag, tag);
end
fprintf('  ApplyNoise_result.png  (comparison figure)\n');
