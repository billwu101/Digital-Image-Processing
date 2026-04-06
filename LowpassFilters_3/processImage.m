function processImage(filename)
% Gaussian Lowpass Filter in Frequency Domain
% HW3 - Gaussian Lowpass Filters

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
    subplot(1, num_cols, 1);
    imshow(uint8(img));
    title('Original');

    for k = 1:length(D0_list)
        D0 = D0_list(k);

        % Build Gaussian lowpass filter at P×Q (padded size)
        u = ifftshift((0:P-1) - floor(P/2));
        v = ifftshift((0:Q-1) - floor(Q/2));
        [V, U] = meshgrid(v, u);
        D_pad = sqrt(U.^2 + V.^2);
        H_low = exp(-(D_pad.^2) / (2 * D0^2));

        % Apply lowpass filter
        G_shifted = H_low .* F_shifted;
        G = ifftshift(G_shifted);

        % Inverse DFT and crop back to original size
        g = real(ifft2(G));
        g = g(1:M, 1:N);
        g = uint8(g);

        % Display lowpass filtered image
        subplot(1, num_cols, k + 1);
        imshow(g);
        title(sprintf('LP D_0 = %d', D0));

        fprintf('Image: %s | D0 = %3d | Output range: [%d, %d]\n', ...
            filename, D0, min(g(:)), max(g(:)));
    end

    sgtitle(['Gaussian Lowpass Filter - ', name], 'Interpreter', 'none');

    save_figure(filename);

end
