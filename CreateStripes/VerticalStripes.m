% Create a grayscale image with vertical stripes (dark to light)
width = 300;
height = 300;
num_stripes = 16;

% Create the image
img = zeros(height, width, 'uint8');

stripe_width = width / num_stripes;

% Define gray levels from dark tˊo light
gray_levels = linspace(64, 210, num_stripes);

for i = 1:num_stripes
    x_start = round((i-1) * stripe_width) + 1;
    x_end   = round(i * stripe_width);
    img(:, x_start:x_end) = uint8(gray_levels(i));
end

% Display and save
imshow(img);
title('Vertical Grayscale Stripes');
imwrite(img, 'grayscale_stripes.png');
