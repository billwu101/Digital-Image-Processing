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

    % Build distance matrix D(u,v) from center
    u = 0:M-1;
    v = 0:N-1;
    u = ifftshift(u - floor(M/2));
    v = ifftshift(v - floor(N/2));
    [V, U] = meshgrid(v, u);
    D = sqrt(U.^2 + V.^2);

    % Cutoff frequencies to test
    D0_list = [100, 300, 600, 1600];

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

        % Gaussian lowpass filter mask: H = exp(-D^2 / (2*D0^2))
        H = exp(-(D .^ 2) / (2 * D0^2));

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
