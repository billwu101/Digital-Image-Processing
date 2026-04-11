# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Overview

MATLAB homework project for NTUST Introduction to Digital Image Processing (HW2). Implements three spatial-domain image enhancement techniques, each in its own folder with a self-contained set of `.m` files.

- **Images used:** `hurricane-Andrew.tiff` (Image A), `Moon.jpeg` (Image B)
- Both images are duplicated inside each task folder alongside the scripts that process them.

## Running the Code

All scripts are run in MATLAB. Each task folder is self-contained — set MATLAB's working directory to the task folder before running.

```matlab
% Averaging Filtering
cd 'averaging filtering'
AveragingFilter   % runs processImage on all images in the folder

% Median Filtering
cd 'Median filtering'
MedianFilter

% Laplacian Sharpening
cd 'Sharpen images'
SharpenFilter
```

Results are saved automatically to a `result/` subfolder inside each task folder at 1200 DPI.

## Architecture

Each task follows the same pattern:

```
<TaskFolder>/
├── <TaskName>.m       % Entry point: scans folder for images, calls processImage per file
├── processImage.m     % Core logic for that task (filter + display + save)
├── save_figure.m      % Shared utility: saves gcf to result/<basename>_result.png
└── result/            % Auto-created output folder
```

**Averaging Filtering** — `processImage` applies a 3×3 box filter via `conv2` with `'same'` padding.

**Median Filtering** — `processImage` calls four separate padding functions (`medianPartial`, `medianZero`, `medianReplicate`, `medianMirror`), each returning a filtered image. Results are verified against MATLAB's `medfilt2` and the max difference is printed to console.

**Laplacian Sharpening** — `processImage` computes an 8-neighbor Laplacian via `conv2`, subtracts it from the original, clips to [0, 255], and displays Original / Laplacian (normalized) / Sharpened side by side.

## Key Conventions

- All main scripts (`AveragingFilter.m`, `MedianFilter.m`, `SharpenFilter.m`) begin with `close all; clear; clc;` and scan the working directory for image files (`*.jpeg`, `*.jpg`, `*.png`, `*.tiff`, `*.tif`, `*.bmp`).
- Images are converted to grayscale (`rgb2gray`) if they have 3 channels before processing.
- `save_figure.m` is identical in all three folders — any change should be replicated to all three.
- The `SharpenFilter.m` entry point additionally filters out filenames containing `'result'` to avoid reprocessing saved outputs.
