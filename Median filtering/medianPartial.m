% 函式：Partial Kernel Padding — 邊緣縮小鄰域，不補值
function out = medianPartial(img, pad)
    [rows, cols] = size(img);
    out = zeros(rows, cols);
    for i = 1:rows                                       % 遍歷每一列
        for j = 1:cols                                   % 遍歷每一行
            r1 = max(i - pad, 1);                        % 鄰域上邊界
            r2 = min(i + pad, rows);                     % 鄰域下邊界
            c1 = max(j - pad, 1);                        % 鄰域左邊界
            c2 = min(j + pad, cols);                     % 鄰域右邊界
            neighborhood = img(r1:r2, c1:c2);            % 取出鄰域像素
            sorted = sort(neighborhood(:));              % 將鄰域像素展平並排序
            out(i, j) = sorted(ceil(numel(sorted) / 2)); % 取中位數作為輸出
        end
    end
end
