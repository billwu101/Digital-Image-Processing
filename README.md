# Introduction to Image Processing — Homework #3

**Image Enhancement in the Frequency Domain**

- **Image A:** bright_with_rect.png
- **Image B:** Moon.jpeg

---

## AI Usage Disclosure

| Item | Content |
|------|---------|
| AI Used | Yes |
| Tools | ChatGPT / Claude Code for VS Code |
| Scope | Structure organization, wording refinement, code debugging, filter workflow confirmation, explanation of padding and display handling |
| Note | AI was mainly used to help organize the workflow and write-up for `CreateImage_0`, `GaussianFilterMask_2`, `LowpassFilters_3`, and `HighpassFilters_4`. Actual image outputs, filter generation, zero padding, GHPF reconstruction, sharpened image computation, and the corrected `imshow(g_hp, [])` display are based on the submitted MATLAB files and generated results. |

---

## Project Structure

```text
HW3/
├── CreateImage_0/
│   ├── CreateImage.m                      # Create Image A (bright image with a black rectangle)
│   ├── bright_with_rect.png              # Generated Image A
│   └── Moon.jpeg                         # Source image copy for later tasks
├── FrequencyDomain_1/
│   ├── Frequency.m                       # Main script for frequency-domain visualization
│   ├── processImage.m                    # Computes FFT, magnitude spectrum, and phase spectrum
│   ├── save_figure.m                     # Figure saving utility
│   ├── bright_with_rect.png              # Image A
│   ├── Moon.jpeg                         # Image B
│   └── result/
│       ├── bright_with_rect_result.png   # Frequency-domain result of Image A
│       └── Moon_result.png               # Frequency-domain result of Image B
├── GaussianFilterMask_2/
│   ├── GaussianLowpass.m                 # Main script for Gaussian lowpass masks
│   ├── save_figure.m                     # Figure saving utility
│   ├── GaussianFilter/
│   │   ├── GaussianFilter_D0_200.mat     # Saved mask matrix
│   │   ├── GaussianFilter_D0_500.mat     # Saved mask matrix
│   │   ├── GaussianFilter_D0_1000.mat    # Saved mask matrix
│   │   └── GaussianFilter_D0_1600.mat    # Saved mask matrix
│   └── result/
│       ├── GaussianMask_2D_result.png    # 2D Gaussian masks
│       └── GaussianMask_1D_result.png    # 1D center-row profiles
├── LowpassFilters_3/
│   ├── GaussianLowpass.m                 # Main script for lowpass filtering
│   ├── processImage.m                    # Applies GLPF to each image
│   ├── save_figure.m                     # Figure saving utility
│   ├── bright_with_rect.png              # Image A
│   ├── Moon.jpeg                         # Image B
│   └── result/
│       ├── bright_with_rect_result.png   # Lowpass results of Image A
│       └── Moon_result.png               # Lowpass results of Image B
├── HighpassFilters_4/
│   ├── HighpassFilterMask.m              # Main script for highpass filtering
│   ├── processImage.m                    # Applies GHPF and sharpening
│   ├── save_figure.m                     # Figure saving utility
│   ├── bright_with_rect.png              # Image A
│   ├── Moon.jpeg                         # Image B
│   └── result/
│       ├── bright_with_rect_result.png   # Highpass + sharpened results of Image A
│       └── Moon_result.png               # Highpass + sharpened results of Image B
├── bright_with_rect.png                  # Root-level Image A
└── Moon.jpeg                             # Root-level Image B
```

---

## 0. Image A Construction

**Goal:** Create a simple synthetic test image for observing frequency-domain behavior and filtering effects.

### Method & Formula

Create a 256×256 bright grayscale image with pixel value 200, then place a black rectangle at the specified location:

```matlab
img = ones(256, 256, 'uint8') * 200;
img(60:139, 80:179) = 0;
imwrite(img, 'bright_with_rect.png');
```

This produces a bright background with a sharp-edged black rectangle, which is useful for observing how edges appear in the frequency domain.

### AI Usage

1. Organized the test-image generation workflow and related report text
2. Confirmed the output image name and the rectangle construction process
3. Helped document the earlier temporary `save('img.mat', 'img')` step that was later removed

---

## 1. Frequency Domain Representation

**Goal:** Convert each image to the frequency domain and visualize the original image, log magnitude spectrum, and phase spectrum.

### Method & Formula

Convert the image to grayscale `double`, compute the 2D DFT using `fft2`, and shift the DC component to the center with `fftshift`:

```matlab
F = fftshift(fft2(f(x, y)));
magnitude = log(1 + abs(F));
phase = angle(F);
```

The log transform is used to compress the magnitude range for easier visualization.

### Frequency Summary

| Image | Size | Magnitude Min | Magnitude Max | Phase Range (rad) | |DC| |
|------|------|---------------:|---------------:|-------------------|------:|
| Image A | 256×256 | 0.00 | 11507200.00 | -3.1416 ~ 3.1416 | 11507200.00 |
| Image B | 1086×724 | 0.7168 | 36853289.00 | -3.1416 ~ 3.1416 | 36853289.00 |

### Observations

- **Image A:** The sharp horizontal and vertical rectangle boundaries produce a strong cross-like frequency pattern and periodic stripe structures. The center is brightest because low-frequency energy and the DC component are concentrated there.
- **Image B:** The center is also brightest, showing that most energy is in the low-frequency region. The moon boundary and cloud textures create radial and horizontal structures in the spectrum.

### AI Usage

1. Organized the write-up for `fft2`, `fftshift`, log magnitude, and phase spectrum
2. Helped refactor the single-image analysis flow into `processImage.m`
3. Assisted with batch-processing logic for reading all images in a folder

---

## 2. Gaussian Lowpass Filter Masks

**Goal:** Generate Gaussian lowpass filter masks under different cutoff frequencies and visualize both the 2D masks and 1D center-row profiles.

### Method & Formula

Using cutoff frequencies `D0 = 200, 500, 1000, 1600`, construct Gaussian lowpass filters on a 1000×1000 frequency grid:

```matlab
H_LP(u, v) = exp(-(D(u, v)^2) / (2 * D0^2))
```

where `D(u, v)` is the distance from the frequency origin.

The script also saves each filter matrix as a `.mat` file for later reuse:

```matlab
save(fullfile('GaussianFilter', sprintf('GaussianFilter_D0_%d.mat', D0)), 'H', 'D0');
```

### Observations

- As `D0` becomes larger, the passband widens and the filter curve becomes flatter.
- As `D0` becomes smaller, the mask becomes more concentrated near the frequency center, meaning only a narrower low-frequency band is preserved.

### AI Usage

1. Organized the mathematical description of the Gaussian lowpass filter and the role of `D0`
2. Helped document the generation of both 2D masks and 1D profiles
3. Added the explanation that filter matrices are also saved in `GaussianFilter/` as `.mat` files for later lowpass and highpass processing

---

## 3. Gaussian Lowpass Filtering

**Goal:** Apply Gaussian lowpass filters to Image A and Image B in the frequency domain and compare the outputs under different cutoff frequencies.

### Method & Formula

The image is first zero-padded from `M × N` to `P × Q`, where:

```matlab
P = 2 * M;
Q = 2 * N;
```

Then the padded Fourier transform is multiplied by the Gaussian lowpass mask:

```matlab
G(u, v) = H_LP(u, v) .* F(u, v);
g(x, y) = real(ifft2(ifftshift(G)));
```

Finally, the result is cropped back to the original image size.

### Padding Note

This task uses **zero padding** in the lowpass stage:

```matlab
img_padded = padarray(img, [M, N], 0, 'post');
```

Zero padding is used to reduce wrap-around artifacts caused by circular convolution in the frequency domain.

### Observations

- **Image A:** With smaller `D0`, the rectangle boundary is strongly smoothed. As `D0` increases, the result becomes closer to the original image and the edges look sharper.
- **Image B:** Small `D0` values strongly suppress fine textures and preserve only coarse brightness distribution. At `D0 = 1000` and `1600`, more lunar surface texture and cloud structure are retained.

### AI Usage

1. Organized the frequency-domain lowpass filtering workflow and report text
2. Explained why zero padding is used and why the image is expanded to `P = 2M`, `Q = 2N`
3. Helped document that the filter must be rebuilt at padded size instead of original size
4. Added the note that `D0_list` can be derived automatically from saved `.mat` filenames rather than hardcoded
5. Clarified that lowpass outputs stay close to the range `[0, 255]`, so `uint8(g)` display is acceptable without extra handling

---

## 4. Gaussian Highpass Filtering and Sharpening

**Goal:** Derive Gaussian highpass filters from the lowpass masks, isolate high-frequency components, and create sharpened images by adding the highpass result back to the original image.

### Method & Formula

The Gaussian highpass filter is derived from the lowpass filter:

```matlab
H_HP(u, v) = 1 - H_LP(u, v)
```

Then apply the filter and reconstruct the high-frequency component:

```matlab
G_HP(u, v) = H_HP(u, v) .* F(u, v);
g_hp(x, y) = real(ifft2(ifftshift(G_HP)));
```

Finally, create the sharpened image:

```matlab
g_sharp = img + g_hp;
g_sharp = uint8(min(max(g_sharp, 0), 255));
```

### Display Note

The highpass output `g_hp` is a `double` image and contains both positive and negative values. Therefore, it should be displayed with auto-scaling instead of directly converting to `uint8`:

```matlab
imshow(g_hp, []);
```

This avoids clipping negative edge information.

### Observations

- **Image A:** The highpass result is concentrated near the rectangle boundary. After adding it back to the original image, the edge contrast becomes stronger, especially for smaller `D0`.
- **Image B:** Highpass filtering highlights lunar surface texture, edge transitions, and cloud contrast. After sharpening, the moon contour and texture become clearer, although overly small `D0` may cause over-enhancement.

### AI Usage

1. Organized the workflow for deriving GHPF from GLPF and reconstructing high-frequency components
2. Helped document the padded-size filter reconstruction and sharpened-image formula `g_sharp = img + g_hp`
3. Added the clamp-to-`[0, 255]` explanation for display safety
4. Corrected the display method for the highpass result to `imshow(g_hp, [])` so negative values are preserved visually
5. Helped organize the final comparison layout into three rows: original / high-pass filtered edges / sharpened image

---

## Output Summary

The project demonstrates four main parts of frequency-domain image enhancement:

1. **Synthetic image construction** for controlled edge analysis
2. **Frequency-domain visualization** using Fourier magnitude and phase spectra
3. **Gaussian lowpass filtering** for smoothing and frequency selection
4. **Gaussian highpass filtering and sharpening** for edge extraction and detail enhancement

Overall, the results show that cutoff frequency `D0` directly controls the amount of low- or high-frequency content preserved in the reconstructed image. Smaller `D0` produces stronger smoothing in lowpass filtering and stronger enhancement in highpass-based sharpening, while larger `D0` yields outputs closer to the original image.
