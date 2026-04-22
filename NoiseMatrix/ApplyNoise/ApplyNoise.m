% Apply Noise to Grayscale Stripes Image
% Calls GaussianNoise, SaltPepperNoise, and UniformNoise functions.

% ── Add noise function directories to MATLAB path ─────────────────────────
noise_root = fileparts(fileparts(mfilename('fullpath')));
addpath(fullfile(noise_root, 'GaussianNoise'));
addpath(fullfile(noise_root, 'SaltPepperNoise'));
addpath(fullfile(noise_root, 'UniformNoise'));

% ── Load original image ───────────────────────────────────────────────────
hw4_root = fileparts(noise_root);
img = imread(fullfile(hw4_root, 'CreateStripes', 'grayscale_stripes.png'));
if size(img, 3) == 3, img = rgb2gray(img); end
[M, N] = size(img);

% ── Noise parameters ──────────────────────────────────────────────────────
gauss_mean = 0;   gauss_std = 25;
Pa = 0.05;        Pb = 0.05;
uni_a = -50;      uni_b = 50;

% ── Generate / apply noise via functions ─────────────────────────────────
n_gauss   = GaussianNoise(M, N, gauss_mean, gauss_std);     % additive noise
n_uniform = UniformNoise(M, N, uni_a, uni_b);               % additive noise
noisy_sp  = SaltPepperNoise(img, Pa, Pb);                   % returns corrupted image

clip = @(x) uint8(min(255, max(0, x)));
img_d          = double(img);
noisy_gaussian = clip(img_d + n_gauss);
noisy_uniform  = clip(img_d + n_uniform);

% ── Display comparison ───────────────────────────────────────────────────
figure('Position', [50 50 1400 380]);

subplot(1,4,1); imshow(img);           title('Original');
subplot(1,4,2); imshow(noisy_gaussian); title(sprintf('+ Gaussian\n\\mu=%g, \\sigma=%g', gauss_mean, gauss_std));
subplot(1,4,3); imshow(noisy_sp);      title(sprintf('+ Salt & Pepper\nPa=%.2f, Pb=%.2f', Pa, Pb));
subplot(1,4,4); imshow(noisy_uniform); title(sprintf('+ Uniform\na=%g, b=%g', uni_a, uni_b));

sgtitle('Grayscale Stripes with Added Noise');

% ── Save results ──────────────────────────────────────────────────────────
if ~exist('result', 'dir'), mkdir('result'); end

imwrite(img,            fullfile('result', 'original.png'));
imwrite(noisy_gaussian, fullfile('result', 'gaussian_applied.png'));
imwrite(noisy_sp,       fullfile('result', 'saltpepper_applied.png'));
imwrite(noisy_uniform,  fullfile('result', 'uniform_applied.png'));
exportgraphics(gcf,     fullfile('result', 'ApplyNoise_result.png'), 'Resolution', 300);

fprintf('Done. Results saved to ApplyNoise/result/\n');
fprintf('  original.png\n');
fprintf('  gaussian_applied.png    (mu=%g, sigma=%g)\n', gauss_mean, gauss_std);
fprintf('  saltpepper_applied.png  (Pa=%.2f, Pb=%.2f)\n', Pa, Pb);
fprintf('  uniform_applied.png     (a=%g, b=%g)\n', uni_a, uni_b);
fprintf('  ApplyNoise_result.png   (comparison figure)\n');
