# Accelerated MRI Reconstruction via PNCS and Downstream Tumor Segmentation Evaluation

This repository provides an open-source MATLAB implementation of **Pixel-Level Non-Local Compressed Sensing (PNCS)** for under-sampled magnetic resonance imaging (MRI) reconstruction, coupled with an interactive **MATLAB App Designer GUI** and downstream clinical validation via **morphological brain tumor segmentation**.

---

## Scientific Attribution and Replication Note

The core reconstruction methodology reproduces the algorithm introduced by:
> **Hong Hou et al.**, *"PNCS: Pixel-Level Non-Local Method Based Compressed Sensing Undersampled MRI Image Reconstruction,"* **IEEE Access**, vol. 11, pp. 42389-42402, 2023. DOI: [10.1109/ACCESS.2023.3270900](https://doi.org/10.1109/ACCESS.2023.3270900)

### Novel Contributions of this Repository
1. **Clinical Downstream Validation:** Rather than evaluating image quality solely through mathematical proxies (PSNR, SSIM), we demonstrate that under-sampling directly affects clinical boundary delineation. An automated morphological tumor segmentation pipeline is provided to compute **Dice Similarity Coefficient**, **Jaccard Index (IoU)**, **Sensitivity**, **Specificity**, and **Accuracy** between reconstructed MRI tumors and original fully sampled ground truth.
2. **Interactive MATLAB GUI App:** A standalone MATLAB App Designer interface (`PNCS_MRI_APP`) allowing real-time k-space radial sampling adjustment (custom radial spokes), live iteration tracking with progress gauges, and visual inspection of zero-filled versus PNCS reconstructions.
3. **Modular Platform-Independent Code:** Refactored into clean, relative-path functions suitable for automated headless batch experiments across varying acceleration factors.

---

## Repository Structure

```text
CS-MRI-Reconstruction-PNCS-GUI/
|-- app/
|   `-- PNCS_MRI_APP.m                 # Interactive MATLAB App Designer interface
|-- src/
|   |-- reconstruction/                # Core PNCS algorithmic modules
|   |   |-- generateRadialMask.m       # Radial trajectory k-space sampler
|   |   |-- runPNCS.m                  # Iterative PNCS reconstruction engine
|   |   |-- PNR.m                      # Patch-based non-local regularization
|   |   |-- match_patches.m            # Block matching similarity grouping
|   |   |-- bi_hard_threshold.m        # 2D Haar wavelet hard thresholding
|   |   |-- wiener_filtering.m         # 3D collaborative Wiener filter
|   |   `-- haar2d_utils.m             # Forward and inverse 2D Haar DWT
|   `-- segmentation/                  # Clinical validation modules
|       |-- segment_tumor.m            # Morphological brain tumor extractor
|       `-- compute_segmentation_metrics.m # Boundary overlap evaluator
|-- scripts/
|   `-- run_demo.m                     # Headless end-to-end execution script
|-- data/
|   |-- sample_mri/                    # Target brain MRI slices
|   `-- sample_masks/                  # Matching ground-truth masks
|-- .gitignore
|-- LICENSE
`-- README.md
```

---

## Getting Started

### Prerequisites
- MATLAB (R2021a or newer recommended)
- Image Processing Toolbox
- Wavelet Toolbox

### Quickstart Demo (Headless Execution)
To run the end-to-end reconstruction and segmentation pipeline without opening the GUI:
```matlab
% In MATLAB terminal:
run('scripts/run_demo.m')
```

### Launching the Interactive GUI App
To launch the interactive application:
```matlab
% In MATLAB terminal:
app = PNCS_MRI_APP;
```
1. Click **LOAD IMAGE** to select an MRI slice.
2. Enter the desired **Radial Spokes** (e.g., 20, 30, 45).
3. Click **SHOW MASK** to view the sampling trajectory and zero-filled aliased image.
4. Click **RUN PNCS** to execute iterative collaborative reconstruction.

---

## Downstream Clinical Metrics

The segmentation pipeline evaluates tumor boundary preservation using:
- **Dice Similarity Coefficient (DSC):** `2 * |GT & SEG| / (|GT| + |SEG|)`
- **Jaccard Index (IoU):** `|GT & SEG| / |GT | SEG|`
- **Sensitivity (True Positive Rate):** `TP / (TP + FN)`
- **Specificity (True Negative Rate):** `TN / (TN + FP)`
- **Pixel Accuracy:** `(TP + TN) / Total Pixels`

---

## Citation and Attribution

If you utilize this implementation in your research, please cite the original PNCS paper:

```bibtex
@article{hou2023pncs,
  author={Hou, Hong and others},
  journal={IEEE Access},
  title={PNCS: Pixel-Level Non-Local Method Based Compressed Sensing Undersampled MRI Image Reconstruction},
  year={2023},
  volume={11},
  pages={42389-42402},
  doi={10.1109/ACCESS.2023.3270900}
}
```

---

## License
This project is licensed under the MIT License.
