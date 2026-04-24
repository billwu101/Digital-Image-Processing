% Restore noisy images using four filters:
%   1. Median Filter              (medfilt2, 3×3)
%   2. Alpha-Trimmed Mean Filter  (3×3 window, d=2)
%   3. Adaptive Local Noise Reduction Filter
%   4. Adaptive Median Filter     (S_max = 7)
%
% Processes every image in Picture/. Reads from ApplyNoise/result/{name}/.
clear; close all; clc;

% ── Paths ─────────────────────────────────────────────────────────────────
restore_root = fileparts(mfilename('fullpath'));
hw4_root     = fileparts(restore_root);
pic_dir      = fullfile(hw4_root, 'Picture');
noisy_root   = fullfile(hw4_root, 'NoiseMatrix', 'ApplyNoise', 'result');

% ── Scan Picture folder ───────────────────────────────────────────────────
exts      = {'*.png','*.jpg','*.jpeg','*.bmp','*.tif','*.tiff'};
img_files = [];
for e = 1:numel(exts)
    img_files = [img_files; dir(fullfile(pic_dir, exts{e}))]; %#ok<AGROW>
end
if isempty(img_files), error('No images found in %s', pic_dir); end
fprintf('Found %d image(s) in Picture/\n\n', numel(img_files));

% ── Filter parameters ─────────────────────────────────────────────────────
win_size = [3 3];   % window for Median, Alpha-Trim, Adaptive-Local
d        = 2;       % alpha-trim: remove d/2 from each end
s_max    = 7;       % adaptive median: maximum window size

% ── Noise definitions ─────────────────────────────────────────────────────
levels(1) = struct('label','Low',    'tag','low');
levels(2) = struct('label','Medium', 'tag','medium');
levels(3) = struct('label','High',   'tag','high');

noise_types  = {'gaussian', 'saltpepper', 'uniform'};
noise_labels = {'Gaussian', 'Salt & Pepper', 'Uniform'};

psnr_fn = @(img, ref) ...
    20 * log10(255 / sqrt(mean((double(img(:)) - double(ref(:))).^2)));

% ── Process each image ───────────────────────────────────────────────────
for fi = 1:numel(img_files)
    fname = img_files(fi).name;
    [~, img_name] = fileparts(fname);

    orig = imread(fullfile(pic_dir, fname));
    if size(orig, 3) == 3, orig = rgb2gray(orig); end

    noisy_dir = fullfile(noisy_root, img_name);
    out_dir   = fullfile(restore_root, 'result', img_name);
    if ~exist(out_dir, 'dir'), mkdir(out_dir); end

    fprintf('=== %s ===\n', img_name);
    fprintf('%-8s  %-13s  %-9s  %-9s  %-9s  %-9s  %-9s\n', ...
        'Level','Noise','Noisy','Median','AlphaTrim','AdaptLoc','AdaptMed');
    fprintf('%s\n', repmat('-',1,76));

    for k = 1:3
        lv = levels(k);

        fig = figure('Name', sprintf('Restore %s — %s', img_name, lv.label), ...
                     'Position', [50 50 1800 700]);

        for t = 1:numel(noise_types)
            ntype  = noise_types{t};
            nlabel = noise_labels{t};

            noisy = imread(fullfile(noisy_dir, sprintf('%s_%s.png', ntype, lv.tag)));

            % Apply four filters
            restored_med        = medfilt2(noisy, win_size);
            restored_alpha      = alpha_trimmed_mean_filter(noisy, win_size, d);
            restored_adapt_loc  = adaptive_local_filter(noisy, win_size);
            restored_adapt_med  = adaptive_median_filter(noisy, s_max);

            % PSNR
            p_noisy      = psnr_fn(noisy,             orig);
            p_med        = psnr_fn(restored_med,      orig);
            p_alpha      = psnr_fn(restored_alpha,    orig);
            p_adapt_loc  = psnr_fn(restored_adapt_loc,orig);
            p_adapt_med  = psnr_fn(restored_adapt_med, orig);

            fprintf('%-8s  %-13s  %6.1fdB  %6.1fdB  %6.1fdB  %6.1fdB  %6.1fdB\n', ...
                lv.label, nlabel, p_noisy, p_med, p_alpha, p_adapt_loc, p_adapt_med);

            % Save
            imwrite(restored_med,       fullfile(out_dir, sprintf('median_%s_%s.png',     ntype, lv.tag)));
            imwrite(restored_alpha,     fullfile(out_dir, sprintf('alphatrim_%s_%s.png',  ntype, lv.tag)));
            imwrite(restored_adapt_loc, fullfile(out_dir, sprintf('adaptlocal_%s_%s.png', ntype, lv.tag)));
            imwrite(restored_adapt_med, fullfile(out_dir, sprintf('adaptmed_%s_%s.png',   ntype, lv.tag)));

            % Subplots: 3 rows × 5 cols
            base = (t-1)*5;
            subplot(3,5,base+1); imshow(noisy);
                title(sprintf('[%s] %s\n%.1fdB', lv.label, nlabel, p_noisy));
            subplot(3,5,base+2); imshow(restored_med);
                title(sprintf('Median %dx%d\n%.1fdB', win_size(1), win_size(2), p_med));
            subplot(3,5,base+3); imshow(restored_alpha);
                title(sprintf('Alpha-Trim d=%d\n%.1fdB', d, p_alpha));
            subplot(3,5,base+4); imshow(restored_adapt_loc);
                title(sprintf('Adapt Local\n%.1fdB', p_adapt_loc));
            subplot(3,5,base+5); imshow(restored_adapt_med);
                title(sprintf('Adapt Median S_{max}=%d\n%.1fdB', s_max, p_adapt_med));
        end

        sgtitle(sprintf('[%s] Restoration — %s Noise Level', img_name, lv.label));
        exportgraphics(fig, fullfile(out_dir, sprintf('Restore_%s.png', lv.tag)), 'Resolution', 300);
        fprintf('\n');
    end

    fprintf('  Saved to Restore/result/%s/\n\n', img_name);
end

fprintf('Done.\n');


% ── Alpha-Trimmed Mean Filter ─────────────────────────────────────────────
function out = alpha_trimmed_mean_filter(img, win_size, d)
    mn      = prod(win_size);
    half    = floor(win_size / 2);
    img_pad = padarray(double(img), half, 'replicate');
    cols    = im2col(img_pad, win_size, 'sliding');
    sorted  = sort(cols, 1);
    kept    = sorted(d/2+1 : mn-d/2, :);
    out_vec = mean(kept, 1);
    [M, N]  = size(img);
    out     = uint8(reshape(out_vec, M, N));
end


% ── Adaptive Local Noise Reduction Filter ────────────────────────────────
% f_hat = g - (sigma_n^2 / sigma_L^2) * (g - mu_L)
% sigma_n^2 is estimated as the mean of the lowest 10% local variances.
% When sigma_n^2 >= sigma_L^2, ratio is capped at 1 → output = mu_L.
function out = adaptive_local_filter(img, win_size)
    [M, N]  = size(img);
    half    = floor(win_size / 2);
    img_d   = double(img);
    img_pad = padarray(img_d, half, 'replicate');
    cols    = im2col(img_pad, win_size, 'sliding');   % mn × (M*N)

    mu_L     = mean(cols, 1);      % local mean   1 × (M*N)
    sig_L_sq = var(cols, 0, 1);    % local var    1 × (M*N)

    % Estimate global noise variance from the most uniform windows
    sorted_vars = sort(sig_L_sq);
    n10 = max(1, floor(0.1 * numel(sorted_vars)));
    sigma_n_sq = mean(sorted_vars(1:n10));

    g   = img_d(:)';               % 1 × (M*N)
    ratio   = min(1, sigma_n_sq ./ max(sig_L_sq, 1e-10));
    out_vec = g - ratio .* (g - mu_L);

    out = uint8(min(255, max(0, reshape(out_vec, M, N))));
end


% ── Adaptive Median Filter ────────────────────────────────────────────────
% Increases window size (up to s_max) until the median is not an impulse.
% Stage A: check if median is between min and max → go to Stage B.
%          else: enlarge window.
% Stage B: if current pixel is between min and max → keep it; else → median.
function out = adaptive_median_filter(img, s_max)
    [M, N] = size(img);
    img_d  = double(img);
    out    = img_d;

    for i = 1:M
        for j = 1:N
            z_xy = img_d(i, j);
            s    = 3;
            done = false;

            while ~done
                half = floor(s / 2);
                r1 = max(1, i-half); r2 = min(M, i+half);
                c1 = max(1, j-half); c2 = min(N, j+half);
                patch = img_d(r1:r2, c1:c2);

                z_min = min(patch(:));
                z_max = max(patch(:));
                z_med = median(patch(:));

                if z_med > z_min && z_med < z_max
                    % Stage B: check if current pixel is impulse
                    if z_xy > z_min && z_xy < z_max
                        out(i,j) = z_xy;
                    else
                        out(i,j) = z_med;
                    end
                    done = true;
                else
                    s = s + 2;
                    if s > s_max
                        out(i,j) = z_med;
                        done = true;
                    end
                end
            end
        end
    end

    out = uint8(out);
end
