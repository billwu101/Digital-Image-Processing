function n = UniformNoise(M, N, a, b)
% Returns an M×N Uniform noise matrix distributed in [a, b].
% Called with no output (standalone): displays figure and saves result.
if nargin < 1, M = 256; end
if nargin < 2, N = 256; end
if nargin < 3, a = -50; end
if nargin < 4, b =  50; end

n = a + (b - a) * rand(M, N);

if nargout == 0
    figure;
    imshow(n, []);
    title(sprintf('Uniform Noise  a=%g, b=%g,  Size=%d\\times%d', a, b, M, N));
    save_figure('UniformNoise');
    fprintf('Noise matrix n(x,y):\n');
    fprintf('  Size:  %d x %d\n', M, N);
    fprintf('  Mean:  %.4f\n', mean(n(:)));
    fprintf('  Std:   %.4f\n', std(n(:)));
    fprintf('  Min:   %.4f\n', min(n(:)));
    fprintf('  Max:   %.4f\n', max(n(:)));
end
