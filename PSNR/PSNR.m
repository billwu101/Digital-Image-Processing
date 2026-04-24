% PSNR Evaluation
% For every image in Picture/, computes PSNR of noisy and restored images
% against the clean original. Produces a console table and bar charts.
%
% Prerequisite: run ApplyNoise.m then Restore.m first.
clear; close all; clc;

% ── Paths ─────────────────────────────────────────────────────────────────
psnr_root   = fileparts(mfilename('fullpath'));
hw4_root    = fileparts(psnr_root);
pic_dir     = fullfile(hw4_root, 'Picture');
noisy_root  = fullfile(hw4_root, 'NoiseMatrix', 'ApplyNoise', 'result');
restore_root = fullfile(hw4_root, 'Restore', 'result');

% ── Scan Picture folder ───────────────────────────────────────────────────
exts      = {'*.png','*.jpg','*.jpeg','*.bmp','*.tif','*.tiff'};
img_files = [];
for e = 1:numel(exts)
    img_files = [img_files; dir(fullfile(pic_dir, exts{e}))]; %#ok<AGROW>
end
if isempty(img_files), error('No images found in %s', pic_dir); end

% ── Definitions ──────────────────────────────────────────────────────────
psnr_fn = @(img, ref) ...
    20 * log10(255 / sqrt(mean((double(img(:)) - double(ref(:))).^2)));

levels(1) = struct('label','Low',    'tag','low');
levels(2) = struct('label','Medium', 'tag','medium');
levels(3) = struct('label','High',   'tag','high');

noise_types  = {'gaussian', 'saltpepper', 'uniform'};
noise_labels = {'Gaussian', 'Salt & Pepper', 'Uniform'};

colors        = [0.6 0.6 0.6; 0.2 0.5 0.9; 0.9 0.4 0.3];
method_labels = {'Noisy', 'Median', 'Alpha-Trim'};
level_labels  = {'Low', 'Medium', 'High'};

% ── Process each image ───────────────────────────────────────────────────
for fi = 1:numel(img_files)
    fname = img_files(fi).name;
    [~, img_name] = fileparts(fname);

    orig = imread(fullfile(pic_dir, fname));
    if size(orig, 3) == 3, orig = rgb2gray(orig); end

    noisy_dir   = fullfile(noisy_root,   img_name);
    restore_dir = fullfile(restore_root, img_name);
    out_dir     = fullfile(psnr_root, 'result', img_name);
    if ~exist(out_dir, 'dir'), mkdir(out_dir); end

    % psnr_table(level, noise_type, method)  method: 1=Noisy 2=Median 3=AlphaTrim
    psnr_table = zeros(3, 3, 3);

    fprintf('\n=== PSNR — %s ===\n', img_name);
    fprintf('%-8s  %-13s  %-10s  %-10s  %-10s\n', ...
        'Level','Noise type','Noisy','Median','Alpha-Trim');
    fprintf('%s\n', repmat('-',1,58));

    for k = 1:3
        lv = levels(k);
        for t = 1:3
            ntype = noise_types{t};

            noisy          = imread(fullfile(noisy_dir,   sprintf('%s_%s.png',          ntype, lv.tag)));
            restored_med   = imread(fullfile(restore_dir, sprintf('median_%s_%s.png',   ntype, lv.tag)));
            restored_alpha = imread(fullfile(restore_dir, sprintf('alphatrim_%s_%s.png',ntype, lv.tag)));

            psnr_table(k,t,1) = psnr_fn(noisy,          orig);
            psnr_table(k,t,2) = psnr_fn(restored_med,   orig);
            psnr_table(k,t,3) = psnr_fn(restored_alpha, orig);

            fprintf('%-8s  %-13s  %7.2f dB  %7.2f dB  %7.2f dB\n', ...
                lv.label, noise_labels{t}, ...
                psnr_table(k,t,1), psnr_table(k,t,2), psnr_table(k,t,3));
        end
        fprintf('\n');
    end

    % ── Individual bar chart per noise type ──────────────────────────────
    for t = 1:3
        fig = figure('Name', sprintf('PSNR %s — %s', img_name, noise_labels{t}), ...
                     'Position', [50 50 700 450]);
        data = squeeze(psnr_table(:, t, :));   % 3×3
        b = bar(data, 'grouped');
        for m = 1:3, b(m).FaceColor = colors(m,:); end
        set(gca, 'XTickLabel', level_labels);
        xlabel('Noise Level'); ylabel('PSNR (dB)');
        legend(method_labels, 'Location','best');
        title(sprintf('[%s] PSNR — %s Noise', img_name, noise_labels{t}));
        grid on;
        exportgraphics(fig, fullfile(out_dir, sprintf('PSNR_%s.png', noise_types{t})), 'Resolution', 300);
    end

    % ── Summary figure: all noise types in one view ───────────────────────
    fig_sum = figure('Name', sprintf('PSNR Summary — %s', img_name), ...
                     'Position', [50 50 1100 900]);

    for t = 1:3
        subplot(3, 1, t);
        data = squeeze(psnr_table(:, t, :));   % 3 levels × 3 methods
        b = bar(data, 'grouped');
        for m = 1:3, b(m).FaceColor = colors(m,:); end

        % Annotate each bar with its PSNR value
        for m = 1:3
            for lv_idx = 1:3
                val = data(lv_idx, m);
                x   = b(m).XEndPoints(lv_idx);
                text(x, val + 0.3, sprintf('%.1f', val), ...
                    'HorizontalAlignment','center', 'FontSize', 7);
            end
        end

        set(gca, 'XTickLabel', level_labels);
        xlabel('Noise Level'); ylabel('PSNR (dB)');
        legend(method_labels, 'Location','best');
        title(sprintf('%s Noise', noise_labels{t}));
        grid on; ylim([0 max(data(:)) + 5]);
    end

    sgtitle(sprintf('[%s] PSNR Summary — All Noise Types & Levels', img_name));
    exportgraphics(fig_sum, fullfile(out_dir, 'PSNR_summary.png'), 'Resolution', 300);

    fprintf('  Saved to PSNR/result/%s/\n', img_name);
end

fprintf('\nDone.\n');
