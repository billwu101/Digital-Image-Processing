# Introduction to Image Processing — Homework #5

**Color Image Processing**

- **Color Image:** 1D0A7675.jpeg
- **Grayscale Image:** skeleton.tif

---

## AI Usage Disclosure

| Item | Content |
|------|---------|
| AI Used | Yes |
| Tools | ChatGPT / Claude Code for VS Code |
| Scope | Structure organization, wording refinement, MATLAB workflow explanation, RGB / HSV component processing, HSV adjustment, histogram equalization, pseudocolor image processing, path correction, image-saving workflow, and README/report formatting |
| Note | AI was mainly used to help organize the workflow and write-up for `display_rgb_components.m`, `display_hsv_components.m`, `hsv_adjust.m`, `histogram_equalization.m`, `pseudocolor.m`, and `custom_colormap.m`. Actual image outputs and MATLAB results are based on the submitted `.m` files and generated `result/` folders. |

---

## Project Structure

```text
HW5/
├── FullColorImageProcess/
│   ├── Picture/
│   │   └── 1D0A7675.jpeg                         # 24-bit RGB color image
│   ├── ComponentImage/
│   │   ├── display_rgb_components.m              # Displays original image and R/G/B component images
│   │   └── result/
│   │       ├── 1D0A7675_rgb.png                  # 1×4 comparison figure
│   │       ├── 1D0A7675_R.png                    # Red component image
│   │       ├── 1D0A7675_G.png                    # Green component image
│   │       └── 1D0A7675_B.png                    # Blue component image
│   ├── RGB2HSV/
│   │   ├── display_hsv_components.m              # Converts RGB to HSV using rgb2hsv() and manual equations
│   │   └── result/
│   │       ├── 1D0A7675_hsv.png                  # 2×4 comparison figure
│   │       ├── 1D0A7675_H_builtin.png            # Hue component from rgb2hsv()
│   │       ├── 1D0A7675_S_builtin.png            # Saturation component from rgb2hsv()
│   │       ├── 1D0A7675_V_builtin.png            # Value component from rgb2hsv()
│   │       ├── 1D0A7675_H_eq.png                 # Hue component from manual equations
│   │       ├── 1D0A7675_S_eq.png                 # Saturation component from manual equations
│   │       └── 1D0A7675_V_eq.png                 # Value component from manual equations
│   ├── HSV_Adjust/
│   │   └── hsv_adjust.m                          # GUI slider for interactive H/S/V adjustment
│   └── HistogramEqualizaton/
│       ├── histogram_equalization.m              # RGB equalization and HSV V-channel equalization
│       └── result/
│           ├── 1D0A7675_histeq.png               # Comparison figure with histograms
│           ├── 1D0A7675_rgb_eq.png               # RGB channel equalization output
│           └── 1D0A7675_hsv_eq.png               # HSV V-channel equalization output
├── PseudocolorImageProcessing/
│   ├── Picture/
│   │   └── skeleton.tif                          # Grayscale image for pseudocolor processing
│   ├── pseudocolor.m                             # Applies gray, jet, hot, and parula colormaps
│   ├── custom_colormap.m                         # Designs and applies a custom colormap
│   └── result/
│       ├── skeleton_pseudocolor.png              # Standard colormap comparison figure
│       ├── skeleton_gray.png                     # Gray colormap output
│       ├── skeleton_jet.png                      # Jet colormap output
│       ├── skeleton_hot.png                      # Hot colormap output
│       ├── skeleton_parula.png                   # Parula colormap output
│       ├── skeleton_custom_cmap.png              # Custom colormap comparison figure
│       └── skeleton_custom_cmap_img.png          # Custom colormap output image
└── PDF/
    └── HW5.pdf                                   # Assignment description
```

---

## Execution Flow

Run the scripts in the following order:

```text
1. FullColorImageProcess/ComponentImage/display_rgb_components.m
2. FullColorImageProcess/RGB2HSV/display_hsv_components.m
3. FullColorImageProcess/HSV_Adjust/hsv_adjust.m
4. FullColorImageProcess/HistogramEqualizaton/histogram_equalization.m
5. PseudocolorImageProcessing/pseudocolor.m
6. PseudocolorImageProcessing/custom_colormap.m
```

The scripts are designed to read images from their corresponding `Picture/` folders and save output results to their corresponding `result/` folders when static output is generated. `hsv_adjust.m` uses a GUI window with sliders for real-time adjustment.

---

## 0. Test Images and Assignment Scope

**Goal:** Prepare one full-color image for RGB / HSV color image processing and one grayscale image for pseudocolor image processing.

### Method & Settings

The full-color image is `1D0A7675.jpeg`. It is used for RGB component separation, RGB-to-HSV conversion, HSV adjustment, and color histogram equalization.

The grayscale image is `skeleton.tif`. It is used for standard pseudocolor processing and custom colormap design.

```matlab
% Full color image folder
FullColorImageProcess/Picture/1D0A7675.jpeg

% Grayscale image folder
PseudocolorImageProcessing/Picture/skeleton.tif
```

### AI Usage

1. Helped organize the HW5 assignment requirements into a README/report structure
2. Helped classify the assignment into full color image processing and pseudocolor image processing
3. Helped refine the explanation of why RGB/HSV operations use a color image while pseudocolor processing uses a grayscale image
4. Helped keep the README format consistent with the HW4 README style

---

## 1. RGB Component Images

**Goal:** Display the original RGB image and its R, G, and B component images side by side.

### Method & Formula

`display_rgb_components.m` reads all supported image formats from the `Picture/` folder, then creates three component images by preserving one channel and setting the other two channels to zero.

```matlab
R_component = cat(3, R, 0, 0)
G_component = cat(3, 0, G, 0)
B_component = cat(3, 0, 0, B)
```

In the implementation, the component images are generated by modifying the channel values directly:

```matlab
R = img;
R(:,:,2) = 0;
R(:,:,3) = 0;

G = img;
G(:,:,1) = 0;
G(:,:,3) = 0;

B = img;
B(:,:,1) = 0;
B(:,:,2) = 0;
```

The script uses a `1×4` subplot layout:

```text
Original | Red Component | Green Component | Blue Component
```

### Path and Output Design

The script automatically reads from:

```matlab
picDir = fullfile(scriptDir, '..', 'Picture');
```

It supports multiple image formats:

```matlab
*.jpg, *.jpeg, *.png, *.bmp, *.tif
```

The output figure and component images are saved to `ComponentImage/result/`:

```matlab
saveas(gcf, fullfile(out_dir, [img_name '_rgb.png']));
imwrite(R, fullfile(out_dir, [img_name '_R.png']));
imwrite(G, fullfile(out_dir, [img_name '_G.png']));
imwrite(B, fullfile(out_dir, [img_name '_B.png']));
```

### Observations

- A bright region in the red component means that the red channel intensity is high in that area.
- Green and blue component images can be interpreted in the same way.
- Displaying each component with its own color makes it easier to understand how each channel contributes to the final RGB image.

### AI Usage

1. Helped create `display_rgb_components.m` with a `subplot(1,4,...)` layout
2. Helped modify the `imread` path so the script reads images from the `Picture/` folder
3. Helped add multi-format image support, including `.jpg`, `.jpeg`, `.png`, `.bmp`, and `.tif`
4. Helped add `saveas` for saving the full comparison figure to the `result/` folder
5. Helped add `imwrite` for saving individual R/G/B component images
6. Helped remove the extra `imwrite` line that saved the original image, because the assignment output only required the component images and comparison figure

---

## 2. RGB to HSV Conversion

**Goal:** Convert the RGB image to HSV and display the Hue, Saturation, and Value component images.

### Method & Formula

`display_hsv_components.m` performs RGB-to-HSV conversion using two methods:

1. MATLAB built-in function `rgb2hsv()`
2. Manual transform equations between RGB and HSV

For manual conversion, the RGB image is first normalized to `[0,1]`:

```matlab
imgD = double(img) / 255;
R = imgD(:,:,1);
G = imgD(:,:,2);
B = imgD(:,:,3);
```

The Value component is the maximum of R, G, and B:

```matlab
V = max(R, G, B)
```

The chroma is calculated as:

```matlab
C = max(R, G, B) - min(R, G, B)
```

The Saturation component is:

```matlab
S = C / V,  if V > 0
S = 0,      if V = 0
```

Hue is calculated according to the channel with the maximum value, then normalized to `[0,1)`.

### Subplot Design

Originally, the built-in result and manual-equation result were considered as separate figures. The final version combines them into one `2×4` subplot:

```text
Row 1: Original | H (rgb2hsv) | S (rgb2hsv) | V (rgb2hsv)
Row 2: Original | H (Equations) | S (Equations) | V (Equations)
```

The difference-checking section is kept as a commented block using `%`, so it can be enabled later if needed:

```matlab
% %% --- Figure 3: absolute difference ---
% subplot(1,3,1); imshow(diffH, []); colorbar;
% subplot(1,3,2); imshow(diffS, []); colorbar;
% subplot(1,3,3); imshow(diffV, []); colorbar;
```

### Path and Output Design

The script reads all supported images from:

```matlab
FullColorImageProcess/Picture/
```

The output figure and individual HSV components are saved to `RGB2HSV/result/`:

```matlab
saveas(gcf, fullfile(out_dir, [img_name '_hsv.png']));

imwrite(im2uint8(H1), fullfile(out_dir, [img_name '_H_builtin.png']));
imwrite(im2uint8(S1), fullfile(out_dir, [img_name '_S_builtin.png']));
imwrite(im2uint8(V1), fullfile(out_dir, [img_name '_V_builtin.png']));

imwrite(im2uint8(H2), fullfile(out_dir, [img_name '_H_eq.png']));
imwrite(im2uint8(S2), fullfile(out_dir, [img_name '_S_eq.png']));
imwrite(im2uint8(V2), fullfile(out_dir, [img_name '_V_eq.png']));
```

### Observations

- Hue represents the color category, such as red, green, blue, and yellow.
- Saturation represents color purity. Low saturation areas appear closer to white, gray, or black.
- Value represents brightness and is strongly related to the lightness of the image.
- The built-in `rgb2hsv()` result and the manual-equation result are almost the same. Small differences may appear near low-saturation or zero-chroma regions.

### AI Usage

1. Helped create `display_hsv_components.m` for RGB-to-HSV conversion
2. Helped implement both `rgb2hsv()` and manual HSV transform equations
3. Helped explain the meaning of Hue, Saturation, and Value components
4. Helped combine Figure 1 and Figure 2 into one `2×4` subplot figure
5. Helped comment out the Difference section using `%` so that it does not display by default
6. Helped add `saveas` for the complete HSV comparison figure
7. Helped add `imwrite` for saving individual H/S/V component images from both methods
8. Helped adjust paths so the script reads from the correct `Picture/` folder after the folder location changed

---

## 3. HSV Linear Adjustment

**Goal:** Adjust Hue, Saturation, and Value separately and observe how each HSV component affects the final color image.

### Method & Formula

`hsv_adjust.m` converts the RGB image into HSV, then adjusts H, S, and V independently.

Hue uses circular wrapping because hue is periodic:

```matlab
H' = mod(H + ΔH, 1)
```

Saturation and Value are clipped to the valid range `[0,1]`:

```matlab
S' = min(max(S + ΔS, 0), 1)
V' = min(max(V + ΔV, 0), 1)
```

The adjusted HSV image is then converted back to RGB:

```matlab
imgAdj = hsv2rgb(cat(3, Ha, Sa, Va));
```

### GUI Design

The script uses `uifigure`, `uiaxes`, `uilabel`, and `uislider` to create an interactive GUI.

| Slider | Range | Effect |
|--------|-------|--------|
| ΔHue | -0.5 to 0.5 | Changes the overall hue while wrapping around the HSV hue circle |
| ΔSaturation | -1 to 1 | Increases or decreases color purity |
| ΔValue | -1 to 1 | Increases or decreases brightness |

The GUI shows the original image on the left and the adjusted image on the right. The image updates while the slider is being dragged.

### Observations

- Increasing or decreasing Hue changes the overall color type.
- Increasing Saturation makes colors more vivid, while decreasing Saturation makes the image closer to grayscale.
- Increasing Value makes the image brighter, while decreasing Value makes it darker.
- Hue must use `mod()` because hue is circular.
- Saturation and Value must use clipping because their valid range is limited to `[0,1]`.

### AI Usage

1. Helped create `hsv_adjust.m` for linear adjustment of H, S, and V
2. Helped revise the original static adjustment script into a GUI version using `uifigure` and `uislider`
3. Helped explain why Hue needs circular wrapping with `mod()`
4. Helped explain why Saturation and Value need to be clamped to `[0,1]`
5. Helped design the live-update callback so the adjusted image changes immediately when the sliders move
6. Helped modify the image path so the GUI reads the first available image from the `Picture/` folder

---

## 4. Color Histogram Equalization

**Goal:** Compare RGB channel histogram equalization with HSV Value-channel histogram equalization.

### Method & Formula

`histogram_equalization.m` uses two methods.

### Method 1: RGB Channel Equalization

Each channel is equalized independently:

```matlab
R_eq = histeq(img(:,:,1));
G_eq = histeq(img(:,:,2));
B_eq = histeq(img(:,:,3));
img_rgb_eq = cat(3, R_eq, G_eq, B_eq);
```

### Method 2: HSV Value Equalization

The RGB image is converted to HSV. Only the Value channel is equalized, then the image is converted back to RGB:

```matlab
hsvImg = rgb2hsv(img);
V_eq = histeq(im2uint8(hsvImg(:,:,3)));
hsvImg(:,:,3) = im2double(V_eq);
img_hsv_eq = hsv2rgb(hsvImg);
```

### Display Design

The result is displayed using a `2×3` subplot:

```text
Row 1: Original | RGB Equalized | HSV Equalized (V only)
Row 2: Histogram Original | Histogram RGB Equalized | Histogram HSV Equalized
```

### Path and Output Design

The script saves both the complete comparison figure and individual equalized images:

```matlab
saveas(gcf, fullfile(out_dir, [img_name '_histeq.png']));
imwrite(img_rgb_eq, fullfile(out_dir, [img_name '_rgb_eq.png']));
imwrite(im2uint8(img_hsv_eq), fullfile(out_dir, [img_name '_hsv_eq.png']));
```

### Observations

- RGB equalization can increase contrast, but it may also change the color balance because R, G, and B are modified independently.
- HSV equalization modifies only the brightness-related Value channel, so it usually preserves hue and saturation better.
- HSV Value equalization often gives a more natural-looking result when the goal is contrast enhancement without strong color shift.

### AI Usage

1. Helped create `histogram_equalization.m`
2. Helped separate the two methods: RGB channel equalization and HSV Value-channel equalization
3. Helped add histogram comparison to the subplot layout
4. Helped explain why RGB equalization may cause color shift
5. Helped explain why HSV Value equalization can preserve color appearance better
6. Helped add `saveas` for the complete comparison figure
7. Helped add `imwrite` for saving RGB-equalized and HSV-equalized images
8. Helped fix image-reading paths after the `Picture/` folder location changed

---

## 5. Pseudocolor Image Processing

**Goal:** Apply standard colormaps to a grayscale image and compare how different color mappings affect visual interpretation.

### Method & Formula

`pseudocolor.m` reads the grayscale image from the `Picture/` folder. If the image is already grayscale, it does not apply `rgb2gray()` again. This prevents errors when the input image has only one channel.

```matlab
if size(img, 3) == 3
    grayImg = rgb2gray(img);
else
    grayImg = img(:,:,1);
end
```

The script applies four standard colormaps:

```matlab
maps = {'gray', 'jet', 'hot', 'parula'};
```

Each grayscale intensity value is mapped to a color in the selected colormap:

```matlab
idx = double(im2uint8(grayImg)) + 1;
cdata = feval(maps{m}, 256);
colored = reshape(cdata(idx(:), :), [size(grayImg,1), size(grayImg,2), 3]);
```

### Standard Colormaps

| Colormap | Visual Meaning |
|----------|----------------|
| gray | Keeps the original grayscale appearance and brightness relationship |
| jet | Uses rainbow colors and emphasizes differences between intensity ranges |
| hot | Uses black-red-yellow-white colors, similar to heat-map visualization |
| parula | Uses smoother color changes and is often more visually continuous than jet |

### Path and Output Design

The script saves the complete pseudocolor comparison figure and individual colormap images:

```matlab
saveas(gcf, fullfile(out_dir, [img_name '_pseudocolor.png']));
imwrite(colored, fullfile(out_dir, [img_name '_' maps{m} '.png']));
```

### Observations

- Pseudocolor does not change the original grayscale data; it only changes the way intensity values are displayed.
- `gray` is the most neutral representation.
- `jet` can make intensity differences visually obvious, but it may introduce artificial-looking boundaries.
- `hot` emphasizes bright areas strongly.
- `parula` gives smoother color transitions and is easier to interpret in many cases.

### AI Usage

1. Helped create `pseudocolor.m`
2. Helped apply `gray`, `jet`, `hot`, and `parula` colormaps to the grayscale image
3. Helped explain the visual differences among the four colormaps
4. Helped fix the `rgb2gray` error by checking whether the image is already grayscale
5. Helped avoid naming a variable `gray`, because `gray` is also a MATLAB colormap function
6. Helped add `saveas` for saving the full colormap comparison figure
7. Helped add `imwrite` for saving individual pseudocolor output images
8. Helped correct the `Picture/` and `result/` paths for the pseudocolor folder

---

## 6. Custom Colormap

**Goal:** Design a custom colormap to emphasize a selected grayscale intensity range.

### Method & Formula

`custom_colormap.m` creates a 256-level custom colormap. The goal is to emphasize the mid-gray range `[80,160]`.

The colormap is divided into three regions:

| Gray Level Range | Color Mapping Strategy |
|------------------|------------------------|
| 0-79 | Dark navy to steel blue |
| 80-160 | Vivid green to yellow |
| 161-255 | Orange to white |

The custom colormap is built as a `256×3` RGB table:

```matlab
N = 256;
cmap = zeros(N, 3);

shadow = 1:80;
mid    = 81:161;
bright = 162:256;
```

Each region is generated using linear interpolation:

```matlab
t_s = linspace(0, 1, numel(shadow))';
t_m = linspace(0, 1, numel(mid))';
t_b = linspace(0, 1, numel(bright))';
```

The final colored image is generated by using the grayscale value as the colormap index:

```matlab
idx = double(im2uint8(grayImg)) + 1;
colored = reshape(cmap(idx(:), :), [size(grayImg,1), size(grayImg,2), 3]);
```

### Path and Output Design

The script saves both the comparison figure and the custom-colored image:

```matlab
saveas(gcf, fullfile(out_dir, [img_name '_custom_cmap.png']));
imwrite(colored, fullfile(out_dir, [img_name '_custom_cmap_img.png']));
```

### Observations

- Dark regions are shown in blue, so they visually recede.
- Mid-gray regions are shown in green to yellow, making them easier to identify.
- Bright regions are shown in orange to white, creating strong highlight contrast.
- Custom colormaps are useful when a specific intensity range needs to be emphasized.
- The colors are artificial mappings, so the README/report should clearly explain that they do not represent the object’s real physical color.

### AI Usage

1. Helped separate the custom colormap code into an independent `custom_colormap.m` file
2. Helped design the custom colormap strategy: dark blue for shadows, green-to-yellow for midtones, and orange-to-white for highlights
3. Helped explain why the mid-gray range `[80,160]` can be emphasized using a custom colormap
4. Helped fix the `rgb2gray` issue for grayscale input images
5. Helped prevent conflict between variable names and MATLAB built-in colormap functions
6. Helped add `saveas` for the custom colormap comparison figure
7. Helped add `imwrite` for the final custom-colored image
8. Helped write the README/report explanation for how custom colormap values are mapped from grayscale intensity values

---

## Output Summary

This project demonstrates six main parts of color image processing:

1. **RGB component image display** using separated R, G, and B channels
2. **RGB-to-HSV conversion** using both MATLAB `rgb2hsv()` and manual transform equations
3. **HSV linear adjustment** using an interactive GUI with Hue, Saturation, and Value sliders
4. **Color histogram equalization** using RGB channel equalization and HSV Value-channel equalization
5. **Standard pseudocolor processing** using `gray`, `jet`, `hot`, and `parula` colormaps
6. **Custom colormap design** for emphasizing a selected grayscale intensity range

Overall, RGB components are useful for understanding how each color channel contributes to the final image. HSV is more intuitive for color adjustment because Hue, Saturation, and Value correspond to color type, color purity, and brightness. Histogram equalization can improve contrast, but RGB equalization may cause color shift, while HSV Value equalization tends to preserve hue better. Pseudocolor image processing does not change the original grayscale data; instead, it maps intensity values to colors so that important intensity ranges can be visually emphasized.
