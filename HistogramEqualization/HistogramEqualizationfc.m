function  HistogramEqualizationfc(inputArg1)

imgArray = imread(inputArg1);

if(size(imgArray,3) == 3)
    imgArray = rgb2gray(imgArray);
end

level = 0:255;

%Histogram = zeros(1,256);

imgEqualized = zeros(size(imgArray,1),size(imgArray,2),'uint8');

[Histogram, Sum] = myHistogram(imgArray);

% if Sum == (size(imgArray,1) * size(imgArray,2))
%     fprintf("Sum is correct :" + string(Sum) + '\n');
% end

% imgPk = Histogram ./ Sum ;
% imgArrayEqualization = round(imgPk .* 255);

imgPk = Histogram ./ Sum;
cdf = cumsum(imgPk);
imgArrayEqualization = round(cdf .* 255);


%像素置換

for indexI = 1:size(imgArray,1)
    for indexJ = 1:size(imgArray,2)
        imgEqualized(indexI,indexJ) = imgArrayEqualization(imgArray(indexI,indexJ) + 1);
    end
end


figure('Name', string(inputArg1));
subplot(2,2,1);
imshow(imgArray);
subplot(2,2,2);
imshow(imgEqualized);
subplot(2,2,3);

bar(level, myHistogram(imgArray),'c');
xlabel('Gray level');
ylabel('# of pixels');
title('Histogram (' + inputArg1 + ')');
subplot(2,2,4);
bar(level, myHistogram(imgEqualized),'c');
xlabel('Gray level');
ylabel('# of pixels');
title('Equalized Histogram (' + inputArg1 + ')');


% drawnow;
% 
% folder = 'output';
% if ~exist(folder, 'dir')
%     mkdir(folder);
% end
% 
% filename = fullfile(folder, ['HistogramCompare_' inputArg1 '.png']);
% 
% ax = gca;
% 
% exportgraphics(ax, "test.jpg");

end
