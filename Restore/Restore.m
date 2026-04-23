% Restore noisy images using Median Filter and Alpha-Trimmed Mean Filter.
%
% Processes all noise types (Gaussian, Salt & Pepper, Uniform) at three
% levels (Low, Medium, High). Computes PSNR against the clean original.
%
% Alpha-trimmed mean: 3×3 window, d=2 → trim 1 pixel from each end,
%   average the remaining 7.  (d=0 → mean filter; d=8 → median filter)
% Median filter: built-in medfilt2 with 3×3 window.
clear;close all;clc;

% ── Paths ─────────────────────────────────────────────────────────────────
restore_root = fileparts(mfilename('fullpath'));
hw4_root     = fileparts(restore_root);
result_dir   = fullfile(hw4_root, 'NoiseMatrix', 'ApplyNoise', 'result');

% ── Load clean reference image ────────────────────────────────────────────
orig = imread(fullfile(hw4_root, 'Picture', 'grayscale_stripes.png'));
if size(orig, 3) == 3, orig = rgb2gray(orig); end

% ── Filter parameters ─────────────────────────────────────────────────────
win_size = [3 3];
d        = 2;        % trim d/2 pixels from each end of sorted window

% ── Noise level and type definitions ─────────────────────────────────────
levels(1) = struct('label','Low',    'tag','low');
levels(2) = struct('label','Medium', 'tag','medium');
levels(3) = struct('label','High',   'tag','high');

noise_types  = {'gaussian', 'saltpepper', 'uniform'};
noise_labels = {'Gaussian', 'Salt & Pepper', 'Uniform'};

if ~exist(fullfile(restore_root,'result'),'dir')
    mkdir(fullfile(restore_root,'result'));
end

psnr_fn = @(img, ref) ...
    20 * log10(255 / sqrt(mean((double(img(:)) - double(ref(:))).^2)));

% ── Report header ─────────────────────────────────────────────────────────
fprintf('\n=== Restoration PSNR (dB)  window=%dx%d, alpha-trim d=%d ===\n\n', ...
    win_size(1), win_size(2), d);
fprintf('%-8s  %-13s  %-10s  %-10s  %-10s\n', ...
    'Level','Noise type','Noisy','Median','Alpha-Trim');
fprintf('%s\n', repmat('-',1,58));

% ── Main loop: one figure per noise level ────────────────────────────────
for k = 1:3
    lv = levels(k);

    fig = figure('Name', sprintf('Restoration — %s', lv.label), ...
                 'Position', [50 50 1400 780]);

    for t = 1:numel(noise_types)
        ntype  = noise_types{t};
        nlabel = noise_labels{t};

        noisy = imread(fullfile(result_dir, sprintf('%s_%s.png', ntype, lv.tag)));

        % Apply filters
        restored_med   = medfilt2(noisy, win_size);
        restored_alpha = alpha_trimmed_mean_filter(noisy, win_size, d);

        % Evaluate
        p_noisy = psnr_fn(noisy,          orig);
        p_med   = psnr_fn(restored_med,   orig);
        p_alpha = psnr_fn(restored_alpha, orig);

        fprintf('%-8s  %-13s  %7.2f dB  %7.2f dB  %7.2f dB\n', ...
            lv.label, nlabel, p_noisy, p_med, p_alpha);

        % Save individual results
        imwrite(restored_med,   fullfile(restore_root,'result', ...
            sprintf('median_%s_%s.png',    ntype, lv.tag)));
        imwrite(restored_alpha, fullfile(restore_root,'result', ...
            sprintf('alphatrim_%s_%s.png', ntype, lv.tag)));

        % Subplots: Noisy | Median | Alpha-Trimmed
        base = (t-1)*3;

        subplot(3,3,base+1);
        imshow(noisy);
        title(sprintf('[%s] %s\nPSNR = %.1f dB', lv.label, nlabel, p_noisy));

        subplot(3,3,base+3);
        imshow(restored_med);
        title(sprintf('Median %dx%d\nPSNR = %.1f dB', win_size(1), win_size(2), p_med));

        subplot(3,3,base+2);
        imshow(restored_alpha);
        title(sprintf('Alpha-Trim (d=%d)\nPSNR = %.1f dB', d, p_alpha));
    end

    sgtitle(sprintf('Restoration — %s Noise Level  (window=%dx%d, alpha-trim d=%d)', ...
        lv.label, win_size(1), win_size(2), d));

    exportgraphics(fig, ...
        fullfile(restore_root,'result',sprintf('Restore_%s.png',lv.tag)), ...
        'Resolution', 300);

    fprintf('\n');
end

fprintf('Done. Results saved to Restore/result/\n');


% ── Alpha-Trimmed Mean Filter ─────────────────────────────────────────────
% Uses im2col to vectorise the sliding-window operation.
%   d=0             → arithmetic mean filter
%   d=prod(win)-1   → median filter
function out = alpha_trimmed_mean_filter(img, win_size, d)
    mn      = prod(win_size);
    half    = floor(win_size / 2);
    img_pad = padarray(double(img), half, 'replicate');
    cols    = im2col(img_pad, win_size, 'sliding');  % mn × (M*N)
    sorted  = sort(cols, 1);
    kept    = sorted(d/2+1 : mn-d/2, :);            % trim d/2 from each end
    out_vec = mean(kept, 1);
    [M, N]  = size(img);
    out     = uint8(reshape(out_vec, M, N));
end
