# PCRD: Perceptually Constrained Rate-Distortion Optimization for HDR Tone Mapping

MATLAB implementation of the **PCRD-UH** tone-mapping pipeline (Uniform compensation, ω = 1, with Hardclip fusion) presented in:

> Xiongyong Zhu, Junfeng Peng, Feifei Zhang, Guoming Chen, Jun Xu, Rongjun Chen, and Ruqi Zhou,
> *Perceptually Constrained Rate-Distortion Optimization Framework for HDR Tone Mapping*,
> submitted to IEEE Transactions on Multimedia.

## Contents

| File | Description |
|---|---|
| `ng_detail_alloc.m` | Rate-distortion gray-level allocation (Stage 2); each side keeps at least two gray levels. |
| `ng_estimate_sigma.m` | Proxy model: output standard deviation of the hybrid PDF, by direct summation over histogram bins. |
| `ng_steffensen.m` | Segmentation solver: solves σY = g(σY) with Steffensen acceleration; returns boundaries v1, v2. |
| `ng_fusion.m` | Fusion (Stage 4): hard-clips the compensated detail by min(Bp, Bn) and adds it to the base layer. |
| `color_restore.m` | Auxiliary color restoration (γc = 1/2.2). |
| `demo.m` | Minimal example: HDR input → PCRD-UH pipeline → LDR output. |

> In the code, the variable `lambda` is the mixture weight ω of the paper.

## Default parameters

| Parameter | Value |
|---|---|
| κeff (noise-threshold coefficient) | 0.02 |
| Bbase (detail budget cap) | 32 |
| Kurtosis-mapping slope | 0.5 |
| Naturalness weight wnat | 0.60 |

The full list is given in Table S5 of the supplementary material. The sensitivity study (Table S4) is reproduced by perturbing these constants by ±20%.

## Requirements

MATLAB R2023a.

## License

This project is released under the MIT License.

## Citation

If you use this code in your research, please cite the paper above.
