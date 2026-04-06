function processImage(filename)
% Gaussian Highpass Filter in Frequency Domain
% HW3 - Gaussian Highpass Filter Mask

    [~, name, ~] = fileparts(filename);

    % Read image and convert to grayscale double
    img = imread(filename);
    if size(img, 3) == 3
        img = rgb2gray(img);
    end
    img = double(img);

    [M, N] = size(img);
    P = 2 * M;
    Q = 2 * N;

    % Zero padding and compute 2D DFT
    img_padded = padarray(img, [M, N], 0, 'post');
    F = fft2(img_padded);   % P×Q DFT
    F_shifted = fftshift(F);

    % Derive D0_list from saved filter filenames in GaussianFilterMask_2
    filter_dir = '../GaussianFilterMask_2/GaussianFilter';
    mat_files = dir(fullfile(filter_dir, 'GaussianFilter_D0_*.mat'));
    D0_list = sort(cellfun(@(s) sscanf(s, 'GaussianFilter_D0_%d.mat'), {mat_files.name}));

    figure('Name', name, 'NumberTitle', 'off');
    num_cols = length(D0_list) + 1;

    % Original image
    subplot(2, num_cols, 1);
    imshow(uint8(img));
    title('Original');

    % Placeholder to keep layout aligned
    subplot(2, num_cols, num_cols + 1);
    imshow(uint8(img));
    title('Original');

    for k = 1:length(D0_list)
        D0 = D0_list(k);

        % Build GHPF at P×Q: H_high = 1 - H_low
        u = ifftshift((0:P-1) - floor(P/2));
        v = ifftshift((0:Q-1) - floor(Q/2));
        [V, U] = meshgrid(v, u);
        D_pad = sqrt(U.^2 + V.^2);
        H = 1 - exp(-(D_pad.^2) / (2 * D0^2));

        % Apply filter in frequency domain
        G_shifted = H .* F_shifted;
        G = ifftshift(G_shifted);

        % Inverse DFT and crop back to original size
        g_hp = real(ifft2(G));
        g_hp = g_hp(1:M, 1:N);

        % Sharpened image: original + high-pass result
        g_sharp = img + g_hp;
        g_sharp = uint8(min(max(g_sharp, 0), 255));

        % Display high-pass filtered image (row 1)
        subplot(2, num_cols, k + 1);
        imshow(uint8(min(max(g_hp, 0), 255)));
        title(sprintf('GHPF D_0 = %d', D0));

        % Display sharpened image (row 2)
        subplot(2, num_cols, num_cols + k + 1);
        imshow(g_sharp);
        title(sprintf('Sharpened D_0 = %d', D0));

        fprintf('Image: %s | D0 = %3d | Sharpened range: [%d, %d]\n', ...
            filename, D0, min(g_sharp(:)), max(g_sharp(:)));
    end

    sgtitle(['Gaussian Highpass Filter & Sharpening - ', name], 'Interpreter', 'none');

    save_figure(filename);

end
