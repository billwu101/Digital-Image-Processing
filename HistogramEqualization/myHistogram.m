function [outputArg, totalPixels] = myHistogram(imgArray)

outputArg = zeros(1,256);
totalPixels = 0;

for indexI = 1:size(imgArray,1)
    for indexJ = 1:size(imgArray,2)
        outputArg(imgArray(indexI,indexJ) + 1) = outputArg(imgArray(indexI,indexJ) + 1) + 1;
        totalPixels = totalPixels + 1;
    end
end

end