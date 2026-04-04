% 函式：Replicate Padding — 邊界外複製最近的邊緣像素
function out = medianReplicate(img, pad)
    [rows, cols] = size(img);
    imgPad = [img(1,1)*ones(pad, pad),   img(1,:),   img(1,end)*ones(pad, pad);
              img(:,1)*ones(1, pad),     img,         img(:,end)*ones(1, pad);
              img(end,1)*ones(pad, pad), img(end,:),  img(end,end)*ones(pad, pad)];
    out = zeros(rows, cols);
    for i = 1:rows                                       % 遍歷每一列
        for j = 1:cols                                   % 遍歷每一行
            neighborhood = imgPad(i:i+2*pad, j:j+2*pad); % 取出 3x3 鄰域（含複製邊緣）
            sorted = sort(neighborhood(:));              % 將鄰域像素展平並排序
            out(i, j) = sorted(ceil(numel(sorted) / 2)); % 取中位數作為輸出
        end
    end
end
