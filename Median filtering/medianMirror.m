% 函式：Mirror Padding — 邊界外鏡像反射內側像素
function out = medianMirror(img, pad)
    [rows, cols] = size(img);
    imgPad = [img(pad:-1:1, pad:-1:1),         img(pad:-1:1, :),         img(pad:-1:1, end:-1:end-pad+1);
              img(:, pad:-1:1),                img,                       img(:, end:-1:end-pad+1);
              img(end:-1:end-pad+1, pad:-1:1), img(end:-1:end-pad+1, :), img(end:-1:end-pad+1, end:-1:end-pad+1)];
    out = zeros(rows, cols);
    for i = 1:rows                                       % 遍歷每一列
        for j = 1:cols                                   % 遍歷每一行
            neighborhood = imgPad(i:i+2*pad, j:j+2*pad); % 取出 3x3 鄰域（含鏡像邊緣）
            sorted = sort(neighborhood(:));              % 將鄰域像素展平並排序
            out(i, j) = sorted(ceil(numel(sorted) / 2)); % 取中位數作為輸出
        end
    end
end
