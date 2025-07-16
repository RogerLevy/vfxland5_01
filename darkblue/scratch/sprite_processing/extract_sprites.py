#!/usr/bin/env python3
"""
Sprite Extractor - Analyzes a PNG file and extracts individual sprites
Automatically detects sprite regions and saves them as separate PNG files
"""

import cv2
import numpy as np
from PIL import Image
import os
import argparse

def find_sprite_regions(image_path, min_area=100, padding=2):
    """
    Find sprite regions in an image by detecting non-background areas
    
    Args:
        image_path: Path to the input PNG file
        min_area: Minimum area in pixels for a region to be considered a sprite
        padding: Pixels to add around detected sprites
    
    Returns:
        List of (x, y, width, height) bounding boxes
    """
    # Load image
    img = cv2.imread(image_path, cv2.IMREAD_UNCHANGED)
    if img is None:
        raise ValueError(f"Could not load image: {image_path}")
    
    # Convert to grayscale for processing
    if len(img.shape) == 4:  # RGBA
        gray = cv2.cvtColor(img, cv2.COLOR_BGRA2GRAY)
        # Use alpha channel if available
        alpha = img[:, :, 3]
        # Combine grayscale and alpha for better edge detection
        gray = cv2.bitwise_and(gray, alpha)
    elif len(img.shape) == 3:  # RGB
        gray = cv2.cvtColor(img, cv2.COLOR_BGR2GRAY)
    else:  # Already grayscale
        gray = img
    
    # Create binary mask based on alpha channel if available
    if len(img.shape) == 3 and img.shape[2] == 4:  # RGBA - use alpha channel
        alpha = img[:, :, 3]
        # Threshold alpha channel - anything with alpha > 10 is considered a sprite
        _, binary = cv2.threshold(alpha, 10, 255, cv2.THRESH_BINARY)
        print(f"Using alpha channel detection. Opaque pixels: {np.sum(binary > 0)}")
    else:
        # Fallback to brightness detection for non-alpha images
        _, binary = cv2.threshold(gray, 240, 255, cv2.THRESH_BINARY_INV)
        print(f"Using brightness detection. Non-background pixels: {np.sum(binary > 0)}")
    
    # Skip noise removal for pixel art - preserve every pixel
    
    # Dilate to connect nearby pixels (within 2 pixels) to prevent splitting sprites
    kernel = np.ones((3, 3), np.uint8)  # 3x3 kernel gives 1-pixel radius
    binary_connected = cv2.dilate(binary, kernel, iterations=1)
    
    # Find contours on the dilated image
    contours, _ = cv2.findContours(binary_connected, cv2.RETR_EXTERNAL, cv2.CHAIN_APPROX_SIMPLE)
    
    # Extract bounding rectangles
    sprite_regions = []
    for contour in contours:
        x, y, w, h = cv2.boundingRect(contour)
        area = w * h
        
        if area >= min_area:
            # Add padding
            x = max(0, x - padding)
            y = max(0, y - padding)
            w = min(img.shape[1] - x, w + 2 * padding)
            h = min(img.shape[0] - y, h + 2 * padding)
            
            sprite_regions.append((x, y, w, h))
    
    return sprite_regions

def extract_sprites(image_path, output_dir="extracted_sprites", min_area=100, padding=2):
    """
    Extract individual sprites from a sprite sheet
    
    Args:
        image_path: Path to input PNG file
        output_dir: Directory to save extracted sprites
        min_area: Minimum area for sprite detection
        padding: Padding around sprites
    """
    # Create output directory
    os.makedirs(output_dir, exist_ok=True)
    
    # Find sprite regions
    print(f"Analyzing {image_path}...")
    regions = find_sprite_regions(image_path, min_area, padding)
    print(f"Found {len(regions)} sprite regions")
    
    # Load original image with PIL for better PNG handling
    img = Image.open(image_path)
    
    # Extract each sprite
    base_name = os.path.splitext(os.path.basename(image_path))[0]
    
    for i, (x, y, w, h) in enumerate(regions):
        # Extract sprite region
        sprite = img.crop((x, y, x + w, y + h))
        
        # Generate filename
        output_path = os.path.join(output_dir, f"{base_name}_sprite_{i+1:03d}.png")
        
        # Save sprite
        sprite.save(output_path, "PNG")
        print(f"Extracted sprite {i+1}: {w}x{h} -> {output_path}")
    
    print(f"\nExtracted {len(regions)} sprites to {output_dir}/")
    return len(regions)

def create_debug_image(image_path, output_path="debug_regions.png", min_area=100, padding=2):
    """
    Create a debug image showing detected sprite regions
    """
    # Load image
    img = cv2.imread(image_path, cv2.IMREAD_UNCHANGED)
    regions = find_sprite_regions(image_path, min_area, padding)
    
    # Convert to RGB for display
    if len(img.shape) == 4:
        debug_img = cv2.cvtColor(img, cv2.COLOR_BGRA2RGB)
    else:
        debug_img = cv2.cvtColor(img, cv2.COLOR_BGR2RGB)
    
    # Draw bounding boxes
    for i, (x, y, w, h) in enumerate(regions):
        # Draw rectangle
        cv2.rectangle(debug_img, (x, y), (x + w, y + h), (255, 0, 0), 2)
        # Add label
        cv2.putText(debug_img, str(i+1), (x, y-5), cv2.FONT_HERSHEY_SIMPLEX, 0.5, (255, 0, 0), 1)
    
    # Save debug image
    debug_pil = Image.fromarray(debug_img)
    debug_pil.save(output_path)
    print(f"Debug image saved: {output_path}")

def main():
    parser = argparse.ArgumentParser(description="Extract sprites from PNG file")
    parser.add_argument("input", help="Input PNG file path")
    parser.add_argument("-o", "--output", default="extracted_sprites", 
                       help="Output directory for sprites")
    parser.add_argument("-m", "--min-area", type=int, default=100,
                       help="Minimum area for sprite detection")
    parser.add_argument("-p", "--padding", type=int, default=2,
                       help="Padding around extracted sprites")
    parser.add_argument("-d", "--debug", action="store_true",
                       help="Create debug image showing detected regions")
    
    args = parser.parse_args()
    
    if not os.path.exists(args.input):
        print(f"Error: Input file '{args.input}' not found")
        return 1
    
    try:
        # Extract sprites
        count = extract_sprites(args.input, args.output, args.min_area, args.padding)
        
        # Create debug image if requested
        if args.debug:
            create_debug_image(args.input, "debug_regions.png", args.min_area, args.padding)
        
        print(f"\nSuccess! Extracted {count} sprites from {args.input}")
        return 0
        
    except Exception as e:
        print(f"Error: {e}")
        return 1

if __name__ == "__main__":
    exit(main())