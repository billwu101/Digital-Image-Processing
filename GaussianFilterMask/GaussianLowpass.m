close all; clear; clc;

% Read all images in current folder
 D0_list = [10, 30, 60, 160];

M = 1000;
N = M;

u = 0:M-1;
v = 0:N-1;
u = ifftshift(u - floor(M/2));
v = ifftshift(v - floor(N/2));
[V, U] = meshgrid(v, u);
D = sqrt(U.^2 + V.^2);

% --- 2D image display ---
figure('Name', '2D Gaussian Masks');
for f = 1:length(D0_list)
    D0 = D0_list(f);
    H = exp(-(D .^ 2) / (2 * D0^2));

    subplot(2, 2, f);
    imshow(fftshift(H), []);
    title(sprintf('D_0 = %d', D0));
    colorbar;
end
sgtitle('Gaussian Lowpass Filter Masks (2D)');

% --- 1D profile (center row) ---
figure('Name', '1D Gaussian Profiles');
center = floor(M/2) + 1;
freq_axis = -floor(M/2) : floor(M/2)-1;

for f = 1:length(D0_list)
    D0 = D0_list(f);
    H = exp(-(D .^ 2) / (2 * D0^2));
    H_shifted = fftshift(H);
    profile = H_shifted(center, :);

    subplot(2, 2, f);
    plot(freq_axis, profile, 'LineWidth', 1.5);
    xlabel('Frequency u');
    ylabel('H(u, v=0)');
    title(sprintf('D_0 = %d', D0));
    xlim([freq_axis(1) freq_axis(end)]);
    ylim([0 1.05]);
    grid on;
end
sgtitle('Gaussian Lowpass Filter Profiles (center row)');
