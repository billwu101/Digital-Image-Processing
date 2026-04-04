% 函式：Zero Padding — 邊界外補 0
function out = medianZero(img, pad)
    [rows, cols] = size(img);
    imgPad = [zeros(pad, cols + 2*pad);                  % 上方補零列
              zeros(rows, pad), img, zeros(rows, pad);   % 左右補零行
              zeros(pad, cols + 2*pad)];                 % 下方補零列
    out = zeros(rows, cols);
    for i = 1:rows                                       % 遍歷每一列
        for j = 1:cols                                   % 遍歷每一行
            neighborhood = imgPad(i:i+2*pad, j:j+2*pad); % 取出 3x3 鄰域（含補零）
            sorted = sort(neighborhood(:));              % 將鄰域像素展平並排序
            out(i, j) = sorted(ceil(numel(sorted) / 2)); % 取中位數作為輸出
        end
    end
end
