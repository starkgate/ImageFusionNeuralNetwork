## Image Fusion Neural Network



## Requirements

This software was tested using the following packages and versions:

| Software     | Version |
| ------------ | ------- |
| Python       | 3.7.3   |
| PyTorch      | 1.3.1   |
| numpy        | 1.16.4  |
| scikit-image | 0.16.2  |
| Pillow       | 5.3.0   |
| nibabel      | 2.5.1   |
| jupyterlab   | 1.2.2   |

## Usage

1. Generate n samples of random metadata (viewpoints, opacity and color transfer functions):
   `python render_random_meta.py volume.nii output_path n`
2. From the metadata, generate volume renderings:
   `python render_volume_images.py volume.nii output_path/view.npy output_path/opacity.npy output_path/color.npy`
3. Train the network for x epochs:
   `python stage2_gan.py --dataroot output_path --outf checkpoint_path --checkpoint_dir checkpoint_path --niter x`