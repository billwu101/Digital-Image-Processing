# Introduction to Image Processing — Homework #1
### Image Enhancement in the Spatial Domain

| | |
|---|---|
| **Image A** | WashingtonDC-Band1-Blue-512 |
| **Image B** | Moon |

---

## AI Usage Disclosure

- **Tools used:** ChatGPT
- **Scope:** Code syntax optimization, debugging, report layout
- **Note:** Core algorithms were written independently. AI was used for syntax improvements, debugging, and report formatting. Detailed AI usage is noted under each problem.

---

## File Structure

```
HW1/
├── Gamma/
│   ├── WashingtonDC.m
│   └── Moon.m
├── BitPlane/
│   ├── Origin8bits_WashingtonDC.m
│   └── Origin8bits_Moon.m
├── Histogram/
│   ├── myHistogram.m
│   ├── WashingtonDCHistogram.m
│   └── MoonHistogram.m
├── HistogramEqualization/
│   ├── HistogramEqualization.m
│   ├── HistogramEqualizationfc.m
│   └── myHistogram.m
├── WashingtonDC-Band1-Blue-512.tif
├── Moon.jpeg
└── README.md
```

## Problem 1 — Gamma Correction

**Objective:** Apply power-law transformation `s = c · r^γ` to Image A and B using at least three different gamma values. Built-in function `imadjust` is NOT used.

**Method:**
- Normalize pixel values to `[0, 1]` using `im2double()`
- Apply `s = c · r^γ` with `c = 1`
- Gamma values tested: `0.04, 0.1, 0.2, 0.4, 0.67, 1, 1.5, 2.5, 5, 10, 25`

```matlab
c = 1;
r = [0.04 0.1 0.2 0.4 0.67 1 1.5 2.5 5 10 25];
imgArrayGammaS = zeros(size(imgArray,1), size(imgArray,2), size(r,2));

for index = 1:size(r,2)
    imgArrayGammaS(:,:,index) = c .* (imgArrayDouble .^ r(index));
end
```

**Source files:**
- [`Gamma/WashingtonDC.m`](Gamma/WashingtonDC.m)
- [`Gamma/Moon.m`](Gamma/Moon.m)

**AI assistance:** Converting values to float with `im2double()`; improving three-level loop structure; layout of output display.

---

## Problem 2 — Bit-Plane Slicing and Reconstruction

**Objective:** Extract all 8 bit planes for both images. Reconstruct a compressed version using only bit planes 8, 7, 6, and 5.

**Method:**
- Extract each pixel's binary representation using `dec2bin()`
- Store each bit plane as a 2D matrix
- Reconstruct by combining the top 4 significant bit planes

```matlab
bits = dec2bin(imgArray(indexI, indexJ), 8) - '0';  % by GPT
```

> Note: Reconstructed image must be cast to `uint8`; using `double` causes display errors.

**Source files:**
- [`BitPlane/Origin8bits_WashingtonDC.m`](BitPlane/Origin8bits_WashingtonDC.m)
- [`BitPlane/Origin8bits_Moon.m`](BitPlane/Origin8bits_Moon.m)

**AI assistance:** `dec2bin` row-vector conversion syntax.

---

## Problem 3 — Histogram Derivation

**Objective:** Compute the histogram of Image A and B from definition. Built-in functions `hist` and `imhist` are NOT used.

**Method:**
- Implement a custom `myHistogram()` function
- Count pixel occurrences for gray levels 0–255

```matlab
function [outputArg, totalPixels] = myHistogram(imgArray)
    outputArg = zeros(1, 256);
    totalPixels = 0;
    for indexI = 1:size(imgArray, 1)
        for indexJ = 1:size(imgArray, 2)
            outputArg(imgArray(indexI, indexJ) + 1) = ...
                outputArg(imgArray(indexI, indexJ) + 1) + 1;
            totalPixels = totalPixels + 1;
        end
    end
end
```

**Source files:**
- [`Histogram/myHistogram.m`](Histogram/myHistogram.m)
- [`Histogram/WashingtonDCHistogram.m`](Histogram/WashingtonDCHistogram.m)
- [`Histogram/MoonHistogram.m`](Histogram/MoonHistogram.m)

**AI assistance:** Using `bar()` to display histogram output.

---

## Problem 4 — Histogram Equalization

**Objective:** Apply histogram equalization to the three gamma-corrected images from Problem 1 (for both Image A and B). Built-in function `histeq` is NOT used.

**Method:**
- Reuse `myHistogram()` to get pixel counts
- Compute probability `Pk = histogram / total_pixels`
- Compute CDF and map to new pixel values `[0, 255]`

```matlab
imgPk = Histogram ./ Sum;
cdf = cumsum(imgPk);
imgArrayEqualization = round(cdf .* 255);

for indexI = 1:size(imgArray, 1)
    for indexJ = 1:size(imgArray, 2)
        imgEqualized(indexI, indexJ) = ...
            imgArrayEqualization(imgArray(indexI, indexJ) + 1);
    end
end
```

**Source files:**
- [`HistogramEqualization/HistogramEqualization.m`](HistogramEqualization/HistogramEqualization.m)
- [`HistogramEqualization/HistogramEqualizationfc.m`](HistogramEqualization/HistogramEqualizationfc.m)
- [`HistogramEqualization/myHistogram.m`](HistogramEqualization/myHistogram.m)

**AI assistance:** Demonstrating usage of the histogram function; providing the correct CDF-based equalization formula.

---

