% PSNR Evaluation
% For every image in Picture/, computes PSNR of noisy and restored images
% against the clean original. Five methods: Noisy / Median / Alpha-Trim /
% Adaptive Local / Adaptive Median.
%
% Prerequisite: run ApplyNoise.m then Restore.m first.
clear; close all; clc;

% ── Paths ─────────────────────────────────────────────────────────────────
psnr_root    = fileparts(mfilename('fullpath'));
hw4_root     = fileparts(psnr_root);
pic_dir      = fullfile(hw4_root, 'Picture');
noisy_root   = fullfile(hw4_root, 'NoiseMatrix', 'ApplyNoise', 'result');
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

% method index: 1=Noisy 2=Median 3=AlphaTrim 4=AdaptLocal 5=AdaptMed
method_labels = {'Noisy', 'Median', 'Alpha-Trim', 'Adapt Local', 'Adapt Median'};
method_files  = {'', 'median_%s_%s.png', 'alphatrim_%s_%s.png', ...
                 'adaptlocal_%s_%s.png', 'adaptmed_%s_%s.png'};
n_methods = numel(method_labels);

colors = [0.60 0.60 0.60   % Noisy       (gray)
          0.20 0.50 0.90   % Median      (blue)
          0.90 0.40 0.30   % Alpha-Trim  (red-orange)
          0.30 0.75 0.40   % Adapt Local (green)
          0.85 0.65 0.10]; % Adapt Med   (yellow)

level_labels = {'Low', 'Medium', 'High'};

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

    % psnr_table(level, noise_type, method)
    psnr_table = zeros(3, 3, n_methods);

    fprintf('\n=== PSNR — %s ===\n', img_name);
    fprintf('%-8s  %-13s  %-9s  %-9s  %-9s  %-9s  %-9s\n', ...
        'Level','Noise','Noisy','Median','AlphaTrim','AdaptLoc','AdaptMed');
    fprintf('%s\n', repmat('-',1,76));

    for k = 1:3
        lv = levels(k);
        for t = 1:3
            ntype = noise_types{t};

            % Load all images (1=Noisy, 2–5=restored)
            imgs = cell(1, n_methods);
            imgs{1} = imread(fullfile(noisy_dir, sprintf('%s_%s.png', ntype, lv.tag)));
            for m = 2:n_methods
                imgs{m} = imread(fullfile(restore_dir, sprintf(method_files{m}, ntype, lv.tag)));
            end

            for m = 1:n_methods
                psnr_table(k,t,m) = psnr_fn(imgs{m}, orig);
            end

            fprintf('%-8s  %-13s  %6.1fdB  %6.1fdB  %6.1fdB  %6.1fdB  %6.1fdB\n', ...
                lv.label, noise_labels{t}, ...
                psnr_table(k,t,1), psnr_table(k,t,2), psnr_table(k,t,3), ...
                psnr_table(k,t,4), psnr_table(k,t,5));
        end
        fprintf('\n');
    end

    % ── Individual bar chart per noise type ──────────────────────────────
    for t = 1:3
        fig = figure('Name', sprintf('PSNR %s — %s', img_name, noise_labels{t}), ...
                     'Position', [50 50 900 480]);
        data = squeeze(psnr_table(:, t, :));   % 3 levels × 5 methods
        b = bar(data, 'grouped');
        for m = 1:n_methods, b(m).FaceColor = colors(m,:); end
        set(gca, 'XTickLabel', level_labels);
        xlabel('Noise Level'); ylabel('PSNR (dB)');
        legend(method_labels, 'Location','best');
        title(sprintf('[%s] PSNR — %s Noise', img_name, noise_labels{t}));
        grid on;
        exportgraphics(fig, fullfile(out_dir, sprintf('PSNR_%s.png', noise_types{t})), 'Resolution', 300);
    end

    % ── Summary figure: all noise types in one view ───────────────────────
    fig_sum = figure('Name', sprintf('PSNR Summary — %s', img_name), ...
                     'Position', [50 50 1200 900]);

    for t = 1:3
        subplot(3, 1, t);
        data = squeeze(psnr_table(:, t, :));   % 3 levels × 5 methods
        b = bar(data, 'grouped');
        for m = 1:n_methods, b(m).FaceColor = colors(m,:); end

        % Value labels above each bar
        for m = 1:n_methods
            for lv_idx = 1:3
                val = data(lv_idx, m);
                x   = b(m).XEndPoints(lv_idx);
                text(x, val + 0.3, sprintf('%.1f', val), ...
                    'HorizontalAlignment','center', 'FontSize', 6.5);
            end
        end

        set(gca, 'XTickLabel', level_labels);
        xlabel('Noise Level'); ylabel('PSNR (dB)');
        legend(method_labels, 'Location','best');
        title(sprintf('%s Noise', noise_labels{t}));
        grid on; ylim([0, max(data(:)) + 6]);
    end

    sgtitle(sprintf('[%s] PSNR Summary — All Noise Types & Levels', img_name));
    exportgraphics(fig_sum, fullfile(out_dir, 'PSNR_summary.png'), 'Resolution', 300);

    fprintf('  Saved to PSNR/result/%s/\n', img_name);
end

fprintf('\nDone.\n');
