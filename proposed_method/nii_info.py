import tensorflow as tf
import os
import nibabel as nib

def show_information(x):
  tf.print("Tensor Shape:", tf.shape(x))
  tf.print("Shape:", x.shape)
  tf.print("Mean:", tf.reduce_mean(x))
  tf.print("Min:", tf.reduce_min(x))
  tf.print("Max:", tf.reduce_max(x))
  
file="D:/BELEG/Dataset/training-cropped-masked/TCGA-76-4934_2000.10.08.nii"
volume=nib.load(file).get_data()
show_information(volume)