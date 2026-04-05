# Introduction to Image Processing — Homework #2

**Image Enhancement in the Spatial Domain**

- **Image A:** hurricane-Andrew.tif
- **Image B:** Moon.jpeg

---

## AI Usage Disclosure

| Item | Content |
|------|---------|
| AI Used | Yes |
| Tools | ChatGPT / Claude Code for VS Code |
| Scope | Code structure, debugging, result analysis |
| Note | Most code was written with AI assistance. Human involvement focused on final result verification, architecture decisions, and feature expansion. Details are described under each section. |

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

## 1. Averaging Filtering

**Goal:** Apply a 3×3 Box Filter to Image A (hurricane-Andrew.tif) and Image B (Moon.jpeg) to perform mean smoothing and output the results.

### Method & Formula

Convolve the grayscale image with the following 3×3 mean kernel:

```matlab
BoxKernal = [1, 1, 1;
             1, 1, 1;
             1, 1, 1];
BoxKernal = BoxKernal .* (1 / 9);

out = conv2(double(imgArray), BoxKernal, 'same');
out = uint8(out);
```

`conv2` uses zero padding by default. The `'same'` parameter ensures the output size matches the input.

### AI Usage

1. Refactored image loading to match the style used in the other two tasks
2. Extracted the image processing logic into a separate `processImage` function
3. Added automatic figure saving functionality

---

## 2. Median Filtering

**Goal:** Implement a 3×3 Median Filter from scratch with four boundary handling methods, without using MATLAB's built-in `medfilt2`. Use `medfilt2` only for result verification.

### Method & Formula

For each pixel, extract the 3×3 neighborhood, sort all values, and take the median:

```matlab
sorted = sort(neighborhood(:));
out(i, j) = sorted(ceil(numel(sorted) / 2));
```

Four boundary handling methods:

- **Partial Kernel** — Shrinks the neighborhood at borders; no padding applied
- **Zero Padding** — Pads borders with zeros
- **Replicate Padding** — Pads borders by replicating the nearest edge pixel
- **Mirror Padding** — Pads borders by mirroring pixels from inside

Verification: Use `medfilt2` to compute `diff_max` and confirm the manual implementation matches the built-in result.

### AI Usage

1. Converted Box Filter to Median Filter (removed box kernel and `conv2`, replaced with manual median logic)
2. Implemented Median Filter manually (nested loops for neighborhood extraction, sort, and median selection)
3. Added `medfilt2`-based verification (computes `diff_max` to confirm correctness)
4. Implemented all four padding methods:
   - Zero Padding: fill border with 0
   - Replicate Padding: copy nearest edge pixel
   - Mirror Padding: reflect pixels from inside
   - (Extra) Partial Kernel: shrink neighborhood without padding
5. Added aligned comments
6. Extended to read all images in a folder (scans `.jpeg / .jpg / .png / .tiff / .tif / .bmp`, opens a separate figure per image)
7. Refactored into functions: `processImage`, `medianPartial`, `medianZero`, `medianReplicate`, `medianMirror`
8. Moved each function into its own `.m` file

---

## 3. Laplacian Sharpening

**Goal:** Apply the Laplacian operator to enhance image sharpness.

### Method & Formula

Use an 8-neighbor Laplacian kernel. Convolve with the original image and subtract to achieve sharpening:

```matlab
% Laplacian kernel
kernel = [1  1  1;
          1 -8  1;
          1  1  1];

% Apply Laplacian convolution (zero-padding)
laplacian = conv2(img, kernel, 'same');

% Sharpened image = Original - Laplacian
sharpened = img - laplacian;

% Clip to [0, 255]
sharpened = max(0, min(255, sharpened));
```

Normalize the Laplacian image to [0, 255] before display:

```matlab
lap_display = laplacian - min(laplacian(:));
lap_display = lap_display / max(lap_display(:)) * 255;
```

### AI Usage

1. Wrote the `processImage` function based on assignment requirements (Laplacian convolution, sharpening, and displaying three images)
2. Moved the function from `SharpenFilter.m` into a separate `processImage.m` file
