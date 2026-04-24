% PSNR Evaluation
% Computes PSNR for noisy images and their restored versions
% (Median filter and Alpha-Trimmed Mean filter) across all noise types
% and noise levels. Displays a table and grouped bar chart.
%
% Prerequisite: run ApplyNoise.m and Restore.m first to generate images.
clear; close all; clc;

% ── Paths ─────────────────────────────────────────────────────────────────
psnr_root    = fileparts(mfilename('fullpath'));
hw4_root     = fileparts(psnr_root);
noisy_dir    = fullfile(hw4_root, 'NoiseMatrix', 'ApplyNoise', 'result');
restore_dir  = fullfile(hw4_root, 'Restore', 'result');

% ── Load clean reference image ────────────────────────────────────────────
orig = imread(fullfile(hw4_root, 'Picture', 'grayscale_stripes.png'));
if size(orig, 3) == 3, orig = rgb2gray(orig); end

% ── PSNR function ─────────────────────────────────────────────────────────
psnr_fn = @(img, ref) ...
    20 * log10(255 / sqrt(mean((double(img(:)) - double(ref(:))).^2)));

% ── Definitions ──────────────────────────────────────────────────────────
levels(1) = struct('label','Low',    'tag','low');
levels(2) = struct('label','Medium', 'tag','medium');
levels(3) = struct('label','High',   'tag','high');

noise_types  = {'gaussian', 'saltpepper', 'uniform'};
noise_labels = {'Gaussian', 'Salt & Pepper', 'Uniform'};

% ── Compute PSNR for all combinations ────────────────────────────────────
% psnr_table(level, noise_type, method): method 1=Noisy, 2=Median, 3=AlphaTrim
psnr_table = zeros(3, 3, 3);

fprintf('\n=== PSNR Evaluation (dB) ===\n\n');
fprintf('%-8s  %-13s  %-10s  %-10s  %-10s\n', ...
    'Level', 'Noise type', 'Noisy', 'Median', 'Alpha-Trim');
fprintf('%s\n', repmat('-', 1, 58));

for k = 1:3
    lv = levels(k);
    for t = 1:3
        ntype = noise_types{t};

        noisy          = imread(fullfile(noisy_dir,   sprintf('%s_%s.png',          ntype, lv.tag)));
        restored_med   = imread(fullfile(restore_dir, sprintf('median_%s_%s.png',   ntype, lv.tag)));
        restored_alpha = imread(fullfile(restore_dir, sprintf('alphatrim_%s_%s.png',ntype, lv.tag)));

        psnr_table(k, t, 1) = psnr_fn(noisy,          orig);
        psnr_table(k, t, 2) = psnr_fn(restored_med,   orig);
        psnr_table(k, t, 3) = psnr_fn(restored_alpha, orig);

        fprintf('%-8s  %-13s  %7.2f dB  %7.2f dB  %7.2f dB\n', ...
            lv.label, noise_labels{t}, ...
            psnr_table(k,t,1), psnr_table(k,t,2), psnr_table(k,t,3));
    end
    fprintf('\n');
end

% ── Bar chart: one figure per noise type ─────────────────────────────────
colors = [0.6 0.6 0.6; 0.2 0.5 0.9; 0.9 0.4 0.3];   % Noisy / Median / Alpha-Trim
method_labels = {'Noisy', 'Median', 'Alpha-Trim'};
level_labels  = {'Low', 'Medium', 'High'};

if ~exist(fullfile(psnr_root,'result'),'dir')
    mkdir(fullfile(psnr_root,'result'));
end

for t = 1:3
    fig = figure('Name', sprintf('PSNR — %s noise', noise_labels{t}), ...
                 'Position', [50 50 700 450]);

    % data: 3 groups (levels) × 3 bars (methods)
    data = squeeze(psnr_table(:, t, :));   % 3×3
    b = bar(data, 'grouped');
    for m = 1:3
        b(m).FaceColor = colors(m,:);
    end

    set(gca, 'XTickLabel', level_labels);
    xlabel('Noise Level');
    ylabel('PSNR (dB)');
    legend(method_labels, 'Location', 'best');
    title(sprintf('PSNR Comparison — %s Noise', noise_labels{t}));
    grid on;

    exportgraphics(fig, ...
        fullfile(psnr_root,'result',sprintf('PSNR_%s.png', noise_types{t})), ...
        'Resolution', 300);
end

fprintf('Done. Bar charts saved to PSNR/result/\n');
