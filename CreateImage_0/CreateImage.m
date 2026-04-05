% Create a bright image with a black rectangle
img = ones(256, 256, 'uint8') * 200;  % 256x256 bright gray image

% Black rectangle: top-left (80, 60), width 100, height 80
img(60:139, 80:179) = 0;

imwrite(img, 'bright_with_rect.png');
%save('img.mat', 'img');

imshow(img);
title('Bright image with black rectangle');