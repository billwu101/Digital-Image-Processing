function out = SaltPepperNoise(img, Pa, Pb)
% Applies salt-and-pepper noise to img and returns the corrupted image (uint8).
% img  : input image (uint8 or double). Default: 256×256 mid-gray (128).
% Pa   : pepper probability (pixel -> 0).   Default: 0.05
% Pb   : salt   probability (pixel -> 255). Default: 0.05
% Called with no output (standalone): displays figure and saves result.
if nargin < 1, img = uint8(128 * ones(256)); end
if nargin < 2, Pa  = 0.05; end
if nargin < 3, Pb  = 0.05; end

[M, N] = size(img);
out = double(img);

r = rand(M, N);
out(r < Pa)               = 0;    % pepper
out(r >= Pa & r < Pa+Pb)  = 255;  % salt
out = uint8(out);

if nargout == 0
    figure;
    imshow(out);
    title(sprintf('Salt-and-Pepper Noise  Pa=%.2f, Pb=%.2f,  Size=%d\\times%d', Pa, Pb, M, N));
    save_figure('SaltPepperNoise');
    total  = M * N;
    pepper = nnz(out(:) == 0);
    salt   = nnz(out(:) == 255);
    fprintf('Noise matrix n(x,y):\n');
    fprintf('  Size:         %d x %d\n', M, N);
    fprintf('  Pa (pepper):  %.4f  (%d pixels)\n', Pa, pepper);
    fprintf('  Pb (salt):    %.4f  (%d pixels)\n', Pb, salt);
    fprintf('  Total noise:  %.4f\n', (pepper + salt) / total);
end
