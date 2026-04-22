function n = GaussianNoise(M, N, mu, sigma)
% Returns an M×N Gaussian noise matrix with mean mu and std sigma.
% Called with no output (standalone): displays figure and saves result.
if nargin < 1, M     = 256; end
if nargin < 2, N     = 256; end
if nargin < 3, mu    = 0;   end
if nargin < 4, sigma = 25;  end

n = mu + sigma * randn(M, N);

if nargout == 0
    figure;
    imshow(n, []);
    title(sprintf('Gaussian Noise  \\mu=%g, \\sigma=%g,  Size=%d\\times%d', mu, sigma, M, N));
    save_figure('GaussianNoise');
    fprintf('Noise matrix n(x,y):\n');
    fprintf('  Size:  %d x %d\n', M, N);
    fprintf('  Mean:  %.4f\n', mean(n(:)));
    fprintf('  Std:   %.4f\n', std(n(:)));
    fprintf('  Min:   %.4f\n', min(n(:)));
    fprintf('  Max:   %.4f\n', max(n(:)));
end
