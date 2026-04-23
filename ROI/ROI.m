% ROI Noise Parameter Estimation
%
% Selects a fixed ROI from a uniform stripe of the vertical-stripes image,
% then estimates the noise distribution from each corrupted image.
% Compares estimated parameters against the theoretical values used in ApplyNoise.m.
%
% ROI location: columns 132-150 (stripe 8, original gray ≈ 132), rows 10-290.
% Noise estimate: noise_ROI = double(noisy_pixel) - baseline_gray
%   For Gaussian/Uniform → additive, so estimated noise ≈ actual noise (slight
%   deviation possible at image boundaries due to uint8 clipping).
%   For Salt & Pepper   → count fraction of 0s (pepper) and 255s (salt) in ROI.

clear;close all;clc;

% ── Paths ────────────────────────────────────────────────────────────────
roi_root   = fileparts(mfilename('fullpath'));
hw4_root   = fileparts(roi_root);
result_dir = fullfile(hw4_root, 'NoiseMatrix', 'ApplyNoise', 'result');

% ── ROI coordinates ───────────────────────────────────────────────────────
% Stripe 8 of the 300×300 / 16-stripe image:
%   x_start = round(7 * 300/16) + 1 = 132,  x_end = round(8 * 300/16) = 150
roi_rows = 10:290;   % avoid image border effects
roi_cols = 132:150;  % within stripe 8

% ── Load original image and get baseline gray level ───────────────────────
orig = imread(fullfile(hw4_root, 'Picture', 'grayscale_stripes.png'));
if size(orig, 3) == 3, orig = rgb2gray(orig); end
orig_roi = double(orig(roi_rows, roi_cols));
baseline = mean(orig_roi(:));   % ≈ 132 (uniform within stripe)

% ── Noise level definitions (must match ApplyNoise.m) ────────────────────
gauss_mean = 0;
levels(1) = struct('label','Low',    'tag','low',    'gauss_std',10,  'Pa',0.01,'Pb',0.01,'uni_a',-20, 'uni_b',20 );
levels(2) = struct('label','Medium', 'tag','medium', 'gauss_std',25,  'Pa',0.05,'Pb',0.05,'uni_a',-50, 'uni_b',50 );
levels(3) = struct('label','High',   'tag','high',   'gauss_std',50,  'Pa',0.15,'Pb',0.15,'uni_a',-100,'uni_b',100);

if ~exist(fullfile(roi_root,'result'),'dir'), mkdir(fullfile(roi_root,'result')); end

% ── Print header ─────────────────────────────────────────────────────────
n_roi = numel(roi_rows) * numel(roi_cols);
fprintf('\n=== ROI Noise Estimation ===\n');
fprintf('Baseline gray = %.1f   |   ROI size = %d×%d = %d pixels\n\n', ...
    baseline, numel(roi_rows), numel(roi_cols), n_roi);
fprintf('%-8s  %-10s  %-24s  %-24s\n', 'Level','Noise','Theory','Estimated');
fprintf('%s\n', repmat('-',1,72));

% ── Analysis loop (one figure per level) ─────────────────────────────────
for k = 1:3
    lv = levels(k);

    % Load noisy images
    img_g  = double(imread(fullfile(result_dir, sprintf('gaussian_%s.png',   lv.tag))));
    img_u  = double(imread(fullfile(result_dir, sprintf('uniform_%s.png',    lv.tag))));
    img_sp =  uint8(imread(fullfile(result_dir, sprintf('saltpepper_%s.png', lv.tag))));

    % Estimate additive noise from ROI
    noise_g = img_g(roi_rows, roi_cols) - orig_roi;
    noise_u = img_u(roi_rows, roi_cols) - orig_roi;
    roi_sp  = img_sp(roi_rows, roi_cols);

    % Gaussian estimates
    est_mu_g  = mean(noise_g(:));
    est_std_g = std(noise_g(:));

    % Uniform estimates
    theory_mu_u  = (lv.uni_a + lv.uni_b) / 2;
    theory_std_u = (lv.uni_b - lv.uni_a) / sqrt(12);
    est_mu_u  = mean(noise_u(:));
    est_std_u = std(noise_u(:));

    % S&P estimates (baseline ≈132 → all 0s=pepper, all 255s=salt)
    est_Pa = nnz(roi_sp == 0)   / n_roi;
    est_Pb = nnz(roi_sp == 255) / n_roi;

    % Print results
    fprintf('%-8s  %-10s  mu=%4g   sigma=%-6g    mu=%6.2f   sigma=%.2f\n', ...
        lv.label, 'Gaussian', gauss_mean, lv.gauss_std, est_mu_g, est_std_g);
    fprintf('%-8s  %-10s  mu=%4g   sigma=%-6.2f  mu=%6.2f   sigma=%.2f\n', ...
        lv.label, 'Uniform', theory_mu_u, theory_std_u, est_mu_u, est_std_u);
    fprintf('%-8s  %-10s  Pa=%.3f  Pb=%.3f            Pa=%.4f  Pb=%.4f\n\n', ...
        lv.label, 'S&P', lv.Pa, lv.Pb, est_Pa, est_Pb);

    % ── Figure: 3 rows × 2 cols ──────────────────────────────────────────
    fig = figure('Name', sprintf('ROI Analysis — %s', lv.label), ...
                 'Position', [50 50 1100 900]);

    % --- Row 1: Gaussian ---
    subplot(3,2,1);
    imshow(uint8(img_g)); hold on;
    rectangle('Position', [roi_cols(1), roi_rows(1), numel(roi_cols)-1, numel(roi_rows)-1], ...
        'EdgeColor','r', 'LineWidth', 2);
    title(sprintf('[%s] Gaussian  (\sigma=%g)', lv.label, lv.gauss_std));

    subplot(3,2,2);
    histogram(noise_g(:), 50, 'Normalization','pdf', ...
        'FaceColor',[0.2 0.5 0.9], 'EdgeColor','none'); hold on;
    x_g = linspace(min(noise_g(:))-5, max(noise_g(:))+5, 300);
    plot(x_g, normpdf(x_g, gauss_mean, lv.gauss_std), 'r-', 'LineWidth', 2);
    xline(est_mu_g, 'b--', 'LineWidth', 1.5);
    title(sprintf('Gaussian ROI noise PDF\n\\mu_{est}=%.2f (theory %g)   \\sigma_{est}=%.2f (theory %g)', ...
        est_mu_g, gauss_mean, est_std_g, lv.gauss_std));
    xlabel('Noise value'); ylabel('PDF');
    legend('ROI histogram','Theoretical PDF',sprintf('Est \\mu=%.2f',est_mu_g),'Location','best');

    % --- Row 2: Uniform ---
    subplot(3,2,3);
    imshow(uint8(img_u)); hold on;
    rectangle('Position', [roi_cols(1), roi_rows(1), numel(roi_cols)-1, numel(roi_rows)-1], ...
        'EdgeColor','y', 'LineWidth', 2);
    title(sprintf('[%s] Uniform  [%g, %g]', lv.label, lv.uni_a, lv.uni_b));

    subplot(3,2,4);
    histogram(noise_u(:), 50, 'Normalization','pdf', ...
        'FaceColor',[0.9 0.7 0.2], 'EdgeColor','none'); hold on;
    uni_h = 1 / (lv.uni_b - lv.uni_a);
    fill([lv.uni_a lv.uni_b lv.uni_b lv.uni_a], [0 0 uni_h uni_h], 'r', ...
        'FaceAlpha', 0.2, 'EdgeColor','r', 'LineWidth', 2);
    title(sprintf('Uniform ROI noise PDF\n\\mu_{est}=%.2f (theory %g)   \\sigma_{est}=%.2f (theory %.2f)', ...
        est_mu_u, theory_mu_u, est_std_u, theory_std_u));
    xlabel('Noise value'); ylabel('PDF');
    legend('ROI histogram','Theoretical PDF','Location','best');

    % --- Row 3: Salt & Pepper ---
    subplot(3,2,5);
    imshow(img_sp); hold on;
    rectangle('Position', [roi_cols(1), roi_rows(1), numel(roi_cols)-1, numel(roi_rows)-1], ...
        'EdgeColor','g', 'LineWidth', 2);
    title(sprintf('[%s] Salt & Pepper  (Pa=%.3f, Pb=%.3f)', lv.label, lv.Pa, lv.Pb));

    subplot(3,2,6);
    bar_data = [lv.Pa, est_Pa; lv.Pb, est_Pb];
    b = bar(bar_data);
    b(1).FaceColor = [0.3 0.3 0.3];
    b(2).FaceColor = [0.8 0.8 0.8];
    set(gca, 'XTickLabel', {'Pepper (Pa)', 'Salt (Pb)'});
    legend('Theoretical','Estimated','Location','best');
    title(sprintf('S&P probability\nPa: theory=%.3f  est=%.4f\nPb: theory=%.3f  est=%.4f', ...
        lv.Pa, est_Pa, lv.Pb, est_Pb));
    ylabel('Probability');

    sgtitle(sprintf('ROI Analysis — %s Noise Level  (baseline gray = %.0f)', lv.label, baseline));

    exportgraphics(fig, fullfile(roi_root,'result',sprintf('ROI_%s.png',lv.tag)), 'Resolution',300);
end

fprintf('Done. Figures saved to ROI/result/\n');
