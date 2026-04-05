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

    % Compute 2D DFT and shift
    F = fft2(img);
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

    % Log magnitude of original spectrum
    magnitude_orig = log(1 + abs(F_shifted));
    subplot(2, num_cols, num_cols + 1);
    imshow(magnitude_orig, []);
    title('Original Spectrum');
    colormap(gca, 'jet');

    for k = 1:length(D0_list)
        D0 = D0_list(k);

        % Load pre-computed filter from GaussianFilterMask_2
        data = load(fullfile(filter_dir, sprintf('GaussianFilter_D0_%d.mat', D0)));
        H = data.H;
        if ~isequal(size(H), [M, N])
            H = imresize(H, [M, N]);
        end

        % Apply filter in frequency domain
        G_shifted = H .* F_shifted;
        G = ifftshift(G_shifted);

        % Inverse DFT to get filtered image
        g = real(ifft2(G));
        g = uint8(g);

        % Display filtered image
        subplot(2, num_cols, k + 1);
        imshow(g);
        title(sprintf('D_0 = %d', D0));

        % Display filter mask spectrum
        subplot(2, num_cols, num_cols + k + 1);
        imshow(log(1 + abs(G_shifted)), []);
        title(sprintf('Filtered Spectrum (D_0=%d)', D0));
        colormap(gca, 'jet');

        fprintf('Image: %s | D0 = %3d | Output range: [%d, %d]\n', ...
            filename, D0, min(g(:)), max(g(:)));
    end

    sgtitle(['Gaussian Lowpass Filter - ', name], 'Interpreter', 'none');

    save_figure(filename);

end
