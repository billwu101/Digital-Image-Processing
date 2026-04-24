% ROI Noise Parameter Estimation
% For every image in Picture/, automatically finds the most uniform region
% (lowest variance) as ROI, then estimates noise distribution from noisy images.
% Compares estimated parameters with theoretical values.
%
% Prerequisite: run ApplyNoise.m first.
clear; close all; clc;

% ── Paths ─────────────────────────────────────────────────────────────────
roi_root  = fileparts(mfilename('fullpath'));
hw4_root  = fileparts(roi_root);
pic_dir   = fullfile(hw4_root, 'Picture');
noisy_root = fullfile(hw4_root, 'NoiseMatrix', 'ApplyNoise', 'result');

% ── Scan Picture folder ───────────────────────────────────────────────────
exts      = {'*.png','*.jpg','*.jpeg','*.bmp','*.tif','*.tiff'};
img_files = [];
for e = 1:numel(exts)
    img_files = [img_files; dir(fullfile(pic_dir, exts{e}))]; %#ok<AGROW>
end
if isempty(img_files), error('No images found in %s', pic_dir); end

% ── Noise level definitions (must match ApplyNoise.m) ────────────────────
gauss_mean = 0;
levels(1) = struct('label','Low',    'tag','low',    'gauss_std',10,  'Pa',0.01,'Pb',0.01,'uni_a',-20, 'uni_b',20 );
levels(2) = struct('label','Medium', 'tag','medium', 'gauss_std',25,  'Pa',0.05,'Pb',0.05,'uni_a',-50, 'uni_b',50 );
levels(3) = struct('label','High',   'tag','high',   'gauss_std',50,  'Pa',0.15,'Pb',0.15,'uni_a',-100,'uni_b',100);

roi_h = 50;   % ROI height (pixels)
roi_w = 50;   % ROI width  (pixels)

% ── Process each image ───────────────────────────────────────────────────
for fi = 1:numel(img_files)
    fname = img_files(fi).name;
    [~, img_name] = fileparts(fname);

    orig = imread(fullfile(pic_dir, fname));
    if size(orig, 3) == 3, orig = rgb2gray(orig); end

    % Auto-detect most uniform ROI in original image
    [roi_r, roi_c] = find_uniform_roi(orig, roi_h, roi_w);
    roi_rows = roi_r : roi_r + roi_h - 1;
    roi_cols = roi_c : roi_c + roi_w - 1;
    orig_roi = double(orig(roi_rows, roi_cols));
    baseline = mean(orig_roi(:));
    n_roi    = numel(orig_roi);

    noisy_dir = fullfile(noisy_root, img_name);
    out_dir   = fullfile(roi_root, 'result', img_name);
    if ~exist(out_dir, 'dir'), mkdir(out_dir); end

    fprintf('\n=== ROI — %s ===\n', img_name);
    fprintf('Auto ROI: rows %d-%d, cols %d-%d  (baseline=%.1f, %d pixels)\n', ...
        roi_rows(1), roi_rows(end), roi_cols(1), roi_cols(end), baseline, n_roi);
    fprintf('%-8s  %-10s  %-28s  %-28s\n','Level','Noise','Theory','Estimated');
    fprintf('%s\n', repmat('-',1,78));

    for k = 1:3
        lv = levels(k);

        img_g  = double(imread(fullfile(noisy_dir, sprintf('gaussian_%s.png',   lv.tag))));
        img_u  = double(imread(fullfile(noisy_dir, sprintf('uniform_%s.png',    lv.tag))));
        img_sp =  uint8(imread(fullfile(noisy_dir, sprintf('saltpepper_%s.png', lv.tag))));

        noise_g = img_g(roi_rows, roi_cols) - orig_roi;
        noise_u = img_u(roi_rows, roi_cols) - orig_roi;
        roi_sp  = img_sp(roi_rows, roi_cols);

        est_mu_g  = mean(noise_g(:));
        est_std_g = std(noise_g(:));

        theory_mu_u  = (lv.uni_a + lv.uni_b) / 2;
        theory_std_u = (lv.uni_b - lv.uni_a) / sqrt(12);
        est_mu_u  = mean(noise_u(:));
        est_std_u = std(noise_u(:));

        est_Pa = nnz(roi_sp == 0)   / n_roi;
        est_Pb = nnz(roi_sp == 255) / n_roi;

        fprintf('%-8s  %-10s  mu=%-4g  sigma=%-6g      mu=%6.2f  sigma=%.2f\n', ...
            lv.label,'Gaussian', gauss_mean, lv.gauss_std, est_mu_g, est_std_g);
        fprintf('%-8s  %-10s  mu=%-4g  sigma=%-6.2f    mu=%6.2f  sigma=%.2f\n', ...
            lv.label,'Uniform', theory_mu_u, theory_std_u, est_mu_u, est_std_u);
        fprintf('%-8s  %-10s  Pa=%.3f  Pb=%.3f              Pa=%.4f  Pb=%.4f\n\n', ...
            lv.label,'S&P', lv.Pa, lv.Pb, est_Pa, est_Pb);

        % Figure
        fig = figure('Name', sprintf('ROI %s — %s', img_name, lv.label), ...
                     'Position', [50 50 1100 900]);

        % Row 1: Gaussian
        subplot(3,2,1);
        imshow(uint8(img_g)); hold on;
        rectangle('Position',[roi_cols(1), roi_rows(1), roi_w-1, roi_h-1], ...
            'EdgeColor','r','LineWidth',2);
        title(sprintf('[%s] Gaussian (sigma=%g)', lv.label, lv.gauss_std));

        subplot(3,2,2);
        histogram(noise_g(:), 50, 'Normalization','pdf', ...
            'FaceColor',[0.2 0.5 0.9],'EdgeColor','none'); hold on;
        x_g = linspace(min(noise_g(:))-5, max(noise_g(:))+5, 300);
        plot(x_g, normpdf(x_g, gauss_mean, lv.gauss_std), 'r-', 'LineWidth', 2);
        xline(est_mu_g,'b--','LineWidth',1.5);
        title(sprintf('Gaussian noise PDF\n\\mu_{est}=%.2f (theory %g)  \\sigma_{est}=%.2f (theory %g)', ...
            est_mu_g, gauss_mean, est_std_g, lv.gauss_std));
        xlabel('Noise value'); ylabel('PDF');
        legend('ROI histogram','Theoretical',sprintf('Est \\mu=%.2f',est_mu_g),'Location','best');

        % Row 2: Uniform
        subplot(3,2,3);
        imshow(uint8(img_u)); hold on;
        rectangle('Position',[roi_cols(1), roi_rows(1), roi_w-1, roi_h-1], ...
            'EdgeColor','y','LineWidth',2);
        title(sprintf('[%s] Uniform [%g,%g]', lv.label, lv.uni_a, lv.uni_b));

        subplot(3,2,4);
        histogram(noise_u(:), 50, 'Normalization','pdf', ...
            'FaceColor',[0.9 0.7 0.2],'EdgeColor','none'); hold on;
        uni_h = 1 / (lv.uni_b - lv.uni_a);
        fill([lv.uni_a lv.uni_b lv.uni_b lv.uni_a],[0 0 uni_h uni_h],'r', ...
            'FaceAlpha',0.2,'EdgeColor','r','LineWidth',2);
        title(sprintf('Uniform noise PDF\n\\mu_{est}=%.2f (theory %g)  \\sigma_{est}=%.2f (theory %.2f)', ...
            est_mu_u, theory_mu_u, est_std_u, theory_std_u));
        xlabel('Noise value'); ylabel('PDF');
        legend('ROI histogram','Theoretical','Location','best');

        % Row 3: S&P
        subplot(3,2,5);
        imshow(img_sp); hold on;
        rectangle('Position',[roi_cols(1), roi_rows(1), roi_w-1, roi_h-1], ...
            'EdgeColor','g','LineWidth',2);
        title(sprintf('[%s] Salt & Pepper (Pa=%.3f,Pb=%.3f)', lv.label, lv.Pa, lv.Pb));

        subplot(3,2,6);
        bar_data = [lv.Pa, est_Pa; lv.Pb, est_Pb];
        b = bar(bar_data);
        b(1).FaceColor = [0.3 0.3 0.3]; b(2).FaceColor = [0.8 0.8 0.8];
        set(gca,'XTickLabel',{'Pepper (Pa)','Salt (Pb)'});
        legend('Theoretical','Estimated','Location','best');
        title(sprintf('S&P probability\nPa: %.3f→%.4f   Pb: %.3f→%.4f', ...
            lv.Pa, est_Pa, lv.Pb, est_Pb));
        ylabel('Probability');

        sgtitle(sprintf('[%s] ROI Analysis — %s  (baseline=%.0f)', ...
            img_name, lv.label, baseline));
        exportgraphics(fig, fullfile(out_dir, sprintf('ROI_%s.png', lv.tag)), 'Resolution', 300);
    end

    fprintf('  Saved to ROI/result/%s/\n', img_name);
end

fprintf('\nDone.\n');


% ── Find most uniform (lowest-variance) block in image ───────────────────
function [r_best, c_best] = find_uniform_roi(img, roi_h, roi_w)
    [M, N] = size(img);
    best_var = inf;
    r_best = 1; c_best = 1;
    step = 5;
    for r = 1:step:M-roi_h+1
        for c = 1:step:N-roi_w+1
            block = double(img(r:r+roi_h-1, c:c+roi_w-1));
            v = var(block(:));
            if v < best_var
                best_var = v; r_best = r; c_best = c;
            end
        end
    end
end
