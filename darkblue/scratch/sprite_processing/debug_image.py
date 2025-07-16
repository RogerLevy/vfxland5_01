#!/usr/bin/env python3
"""
Debug script to analyze the PNG structure and alpha channel
"""

import cv2
import numpy as np
from PIL import Image

def analyze_image(image_path):
    print(f"Analyzing {image_path}...")
    
    # Load with OpenCV
    img_cv = cv2.imread(image_path, cv2.IMREAD_UNCHANGED)
    print(f"OpenCV shape: {img_cv.shape}")
    print(f"OpenCV dtype: {img_cv.dtype}")
    
    # Load with PIL
    img_pil = Image.open(image_path)
    print(f"PIL mode: {img_pil.mode}")
    print(f"PIL size: {img_pil.size}")
    print(f"PIL format: {img_pil.format}")
    
    if len(img_cv.shape) == 3 and img_cv.shape[2] == 4:
        print("Has alpha channel")
        alpha = img_cv[:, :, 3]
        print(f"Alpha min: {alpha.min()}, max: {alpha.max()}")
        print(f"Alpha unique values: {np.unique(alpha)[:10]}...")  # First 10 unique values
        
        # Count transparent vs opaque pixels
        transparent_pixels = np.sum(alpha == 0)
        opaque_pixels = np.sum(alpha == 255)
        semi_transparent = np.sum((alpha > 0) & (alpha < 255))
        
        print(f"Transparent pixels: {transparent_pixels}")
        print(f"Opaque pixels: {opaque_pixels}")
        print(f"Semi-transparent pixels: {semi_transparent}")
        
    else:
        print("No alpha channel detected")
        
    # Check corner pixels to see background
    h, w = img_cv.shape[:2]
    corners = [
        (0, 0), (0, w-1), (h-1, 0), (h-1, w-1),  # Four corners
        (h//2, 0), (h//2, w-1), (0, w//2), (h-1, w//2)  # Mid edges
    ]
    
    print("\nCorner/edge pixel analysis:")
    for i, (y, x) in enumerate(corners):
        pixel = img_cv[y, x]
        print(f"Position ({x}, {y}): {pixel}")

if __name__ == "__main__":
    analyze_image("dark blue mockups 1.png")