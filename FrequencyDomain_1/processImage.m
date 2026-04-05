function processImage(filename)
% 2D Discrete Fourier Transform using fft2
% HW3 - Frequency Domain Analysis

    [~, name, ~] = fileparts(filename);

    % Read image and convert to grayscale double
    img = imread(filename);
    if size(img, 3) == 3
        img = rgb2gray(img);
    end
    img = double(img);

    % Compute 2D DFT
    F = fft2(img);

    % Shift zero-frequency component to center
    F_shifted = fftshift(F);

    % Magnitude spectrum (log scale for visualization)
    magnitude = abs(F_shifted);
    log_magnitude = log(1 + magnitude);

    % Phase spectrum
    phase = angle(F_shifted);

    % Display results
    figure('Name', name, 'NumberTitle', 'off');

    subplot(1, 3, 1);
    imshow(uint8(img));
    title('Original Image');

    subplot(1, 3, 2);
    imshow(log_magnitude, []);
    title('Log Magnitude Spectrum');
    colormap(gca, 'jet');
    colorbar;

    subplot(1, 3, 3);
    imshow(phase, []);
    title('Phase Spectrum');
    colormap(gca, 'jet');
    colorbar;

    %sgtitle(['2D DFT - ', name], 'Interpreter', 'none');

    %save_figure(filename);

    % Print DFT info
    fprintf('Image: %s\n', filename);
    fprintf('  Size: %d x %d\n', size(img, 1), size(img, 2));
    fprintf('  DFT size: %d x %d\n', size(F, 1), size(F, 2));
    fprintf('  Magnitude - Min: %.2f, Max: %.2f\n', min(magnitude(:)), max(magnitude(:)));
    fprintf('  Phase     - Min: %.4f rad, Max: %.4f rad\n', min(phase(:)), max(phase(:)));
    fprintf('  DC component (F(0,0)): %.2f\n\n', abs(F(1,1)));

end
