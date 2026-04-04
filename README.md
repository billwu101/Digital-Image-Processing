# Introduction to Image Processing — Homework #2

**Image Enhancement in the Spatial Domain**

- **Image A:** hurricane-Andrew.tif
- **Image B:** Moon.jpeg

---

## AI Usage Disclosure

| 項目 | 內容 |
|------|------|
| 是否使用 AI | Yes |
| 使用工具 | ChatGPT / Claude Code for VS Code |
| 使用範圍 | 架構整理、程式除錯、結果分析 |
| 補充 | 程式碼大部分內容為 AI 撰寫，人工參與部分為最後結果驗證與架構及程式碼功能擴充，詳細內容每題下有敘述。 |

---

## Project Structure

```
HW2/
├── averaging filtering/
│   ├── AveragingFilter.m      # Main script for averaging filter
│   ├── processImage.m         # Image processing function
│   └── save_figure.m          # Figure saving utility
├── Median filtering/
│   ├── MedianFilter.m         # Main script for median filter
│   ├── processImage.m         # Image processing function
│   ├── medianPartial.m        # Partial kernel implementation
│   ├── medianZero.m           # Zero padding implementation
│   ├── medianReplicate.m      # Replicate padding implementation
│   ├── medianMirror.m         # Mirror padding implementation
│   └── save_figure.m          # Figure saving utility
├── Sharpen images/
│   ├── SharpenFilter.m        # Main script for Laplacian sharpening
│   ├── processImage.m         # Image processing function
│   └── save_figure.m          # Figure saving utility
├── hurricane-Andrew.tiff      # Image A
└── Moon.jpeg                  # Image B
```

---

## 1. Averaging Filtering（平均濾波）

**目標：** 對 Image A (hurricane-Andrew.tif) 與 Image B (Moon.jpeg) 套用 3×3 Box Filter，實作均值平滑處理並輸出結果。

### 方法與公式

將灰階影像與以下 3×3 均值核做二維卷積：

```matlab
BoxKernal = [1, 1, 1;
             1, 1, 1;
             1, 1, 1];
BoxKernal = BoxKernal .* (1 / 9);

out = conv2(double(imgArray), BoxKernal, 'same');
out = uint8(out);
```

`conv2` 預設使用 zero padding，`'same'` 參數使輸出尺寸與輸入相同。

### 使用 AI 的部分

1. 將程式改成像其他兩種讀取的方式
2. 將 Process image 這段程式從主程式裡獨立出來
3. 加上自動儲存圖片的功能

---

## 2. Median Filtering（中值濾波）

**目標：** 自行實作四種邊界處理方式的 3×3 Median Filter，不可使用 MATLAB 內建函式 `medfilt2`，並以 `medfilt2` 驗證結果正確性。

### 方法與公式

對每個像素取 3×3 鄰域，將所有像素排序後取中位數作為輸出：

```matlab
sorted = sort(neighborhood(:));
out(i, j) = sorted(ceil(numel(sorted) / 2));
```

四種邊界處理方式：

- **Partial Kernel** — 邊緣縮小鄰域，不補值
- **Zero Padding** — 邊界外補 0
- **Replicate Padding** — 邊界外複製最近的邊緣像素
- **Mirror Padding** — 邊界外鏡像反射內側像素

驗證方式：使用 `medfilt2` 計算 `diff_max`，確認手動實作與內建函數結果一致。

### 使用 AI 的部分

1. 將 Box Filter 改為 Median Filter（移除 box kernel 與 conv2，改用 medfilt2）
2. 禁用內建函數，手動實作 Median Filter（用雙層迴圈取鄰域、sort 排序、取中位數）
3. 加入 medfilt2 作為驗證（計算 diff_max 確認手動實作與內建函數結果一致）
4. 補齊三種 Padding 方式
   - Zero Padding：邊界外補 0
   - Replicate Padding：複製最近邊緣像素
   - Mirror Padding：鏡像反射內側像素
   - （額外）Partial Kernel：縮小鄰域不補值
5. 加上中文注解並對齊
6. 讀取整個資料夾的所有圖片（用 `dir` 掃描 `.jpeg / .jpg / .png / .tiff / .tif / .bmp`，每張圖各自開一個 figure）
7. 將程式改用函式呈現（把 for 迴圈內的邏輯拆成 `processImage`、`medianPartial`、`medianZero`、`medianReplicate`、`medianMirror`）
8. 將每個函式放到獨立的 `.m` 檔案

---

## 3. Laplacian Sharpening（銳化）

**目標：** 使用 Laplacian 運算元對影像進行銳化增強。

### 方法與公式

採用 8-鄰域 Laplacian 核，對原圖做卷積後相減以達到銳化效果：

```matlab
% Laplacian kernel
kernel = [1  1  1;
          1 -8  1;
          1  1  1];

% 對圖片做 Laplacian 卷積 (使用 zero-padding)
laplacian = conv2(img, kernel, 'same');

% 銳化影像 = 原始影像 - Laplacian 影像
sharpened = img - laplacian;

% 截斷至 [0, 255]
sharpened = max(0, min(255, sharpened));
```

Laplacian 影像顯示前先正規化至 [0, 255]：

```matlab
lap_display = laplacian - min(laplacian(:));
lap_display = lap_display / max(lap_display(:)) * 255;
```

### 使用 AI 的部分

1. 根據作業需求撰寫 `processImage` 函式（含 Laplacian 卷積、銳化、顯示三張圖）
2. 將函式從 `SharpenFilter.m` 移到獨立的 `processImage.m` 檔案
