#!/usr/bin/env python3
"""
Simple Sprite Extractor - Uses only PIL/Pillow to extract sprites
Detects sprite regions and saves them as separate PNG files
"""

from PIL import Image, ImageDraw
import os
import argparse
from collections import deque

def flood_fill_region(image, start_x, start_y, visited, background_threshold=240):
    """
    Use flood fill to find connected non-background pixels
    """
    if (start_x, start_y) in visited:
        return []
    
    width, height = image.size
    pixels = image.load()
    
    # Convert to grayscale value for threshold comparison
    def get_brightness(pixel):
        if isinstance(pixel, tuple):
            if len(pixel) >= 3:  # RGB or RGBA
                return sum(pixel[:3]) / 3
            else:
                return pixel[0]
        return pixel
    
    # Check if pixel is background (light/white)
    def is_background(x, y):
        if x < 0 or x >= width or y < 0 or y >= height:
            return True
        pixel = pixels[x, y]
        brightness = get_brightness(pixel)
        return brightness >= background_threshold
    
    # Flood fill to find connected sprite pixels
    queue = deque([(start_x, start_y)])
    region_pixels = []
    
    while queue:
        x, y = queue.popleft()
        
        if (x, y) in visited or is_background(x, y):
            continue
            
        visited.add((x, y))
        region_pixels.append((x, y))
        
        # Add 4-connected neighbors
        for dx, dy in [(0, 1), (0, -1), (1, 0), (-1, 0)]:
            nx, ny = x + dx, y + dy
            if (nx, ny) not in visited:
                queue.append((nx, ny))
    
    return region_pixels

def find_sprite_regions(image, min_area=100, background_threshold=240):
    """
    Find sprite regions by flood filling non-background areas
    """
    width, height = image.size
    visited = set()
    regions = []
    
    print(f"Scanning image {width}x{height} for sprites...")
    
    # Scan image for sprite pixels
    for y in range(height):
        for x in range(width):
            if (x, y) not in visited:
                pixels = image.load()
                pixel = pixels[x, y]
                
                # Convert to brightness
                if isinstance(pixel, tuple):
                    if len(pixel) >= 3:  # RGB or RGBA
                        brightness = sum(pixel[:3]) / 3
                    else:
                        brightness = pixel[0]
                else:
                    brightness = pixel
                
                # If this is a non-background pixel, flood fill the region
                if brightness < background_threshold:
                    region_pixels = flood_fill_region(image, x, y, visited, background_threshold)
                    
                    if len(region_pixels) >= min_area:
                        # Calculate bounding box
                        min_x = min(px for px, py in region_pixels)
                        max_x = max(px for px, py in region_pixels)
                        min_y = min(py for px, py in region_pixels)
                        max_y = max(py for px, py in region_pixels)
                        
                        regions.append((min_x, min_y, max_x - min_x + 1, max_y - min_y + 1))
    
    return regions

def extract_sprites(image_path, output_dir="extracted_sprites", min_area=100, padding=2, background_threshold=240):
    """
    Extract individual sprites from a sprite sheet
    """
    # Create output directory
    os.makedirs(output_dir, exist_ok=True)
    
    # Load image
    print(f"Loading {image_path}...")
    try:
        img = Image.open(image_path)
    except Exception as e:
        raise ValueError(f"Could not load image: {e}")
    
    # Convert to RGB if needed
    if img.mode not in ['RGB', 'RGBA', 'L']:
        img = img.convert('RGB')
    
    # Find sprite regions
    regions = find_sprite_regions(img, min_area, background_threshold)
    print(f"Found {len(regions)} sprite regions")
    
    # Extract each sprite
    base_name = os.path.splitext(os.path.basename(image_path))[0]
    
    for i, (x, y, w, h) in enumerate(regions):
        # Add padding
        pad_x = max(0, x - padding)
        pad_y = max(0, y - padding)
        pad_w = min(img.width - pad_x, w + 2 * padding)
        pad_h = min(img.height - pad_y, h + 2 * padding)
        
        # Extract sprite region
        sprite = img.crop((pad_x, pad_y, pad_x + pad_w, pad_y + pad_h))
        
        # Generate filename
        output_path = os.path.join(output_dir, f"{base_name}_sprite_{i+1:03d}.png")
        
        # Save sprite
        sprite.save(output_path, "PNG")
        print(f"Extracted sprite {i+1}: {pad_w}x{pad_h} at ({pad_x}, {pad_y}) -> {output_path}")
    
    print(f"\nExtracted {len(regions)} sprites to {output_dir}/")
    return len(regions)

def create_debug_image(image_path, output_path="debug_regions.png", min_area=100, background_threshold=240):
    """
    Create a debug image showing detected sprite regions
    """
    img = Image.open(image_path)
    regions = find_sprite_regions(img, min_area, background_threshold)
    
    # Create a copy for drawing
    debug_img = img.copy()
    if debug_img.mode != 'RGB':
        debug_img = debug_img.convert('RGB')
    
    draw = ImageDraw.Draw(debug_img)
    
    # Draw bounding boxes
    for i, (x, y, w, h) in enumerate(regions):
        # Draw rectangle
        draw.rectangle([x, y, x + w, y + h], outline=(255, 0, 0), width=2)
        # Add label
        draw.text((x, y - 15), str(i+1), fill=(255, 0, 0))
    
    # Save debug image
    debug_img.save(output_path)
    print(f"Debug image saved: {output_path}")

def main():
    parser = argparse.ArgumentParser(description="Extract sprites from PNG file using PIL only")
    parser.add_argument("input", help="Input PNG file path")
    parser.add_argument("-o", "--output", default="extracted_sprites", 
                       help="Output directory for sprites")
    parser.add_argument("-m", "--min-area", type=int, default=100,
                       help="Minimum area for sprite detection")
    parser.add_argument("-p", "--padding", type=int, default=2,
                       help="Padding around extracted sprites")
    parser.add_argument("-t", "--threshold", type=int, default=240,
                       help="Background brightness threshold (0-255)")
    parser.add_argument("-d", "--debug", action="store_true",
                       help="Create debug image showing detected regions")
    
    args = parser.parse_args()
    
    if not os.path.exists(args.input):
        print(f"Error: Input file '{args.input}' not found")
        return 1
    
    try:
        # Extract sprites
        count = extract_sprites(args.input, args.output, args.min_area, args.padding, args.threshold)
        
        # Create debug image if requested
        if args.debug:
            create_debug_image(args.input, "debug_regions.png", args.min_area, args.threshold)
        
        print(f"\nSuccess! Extracted {count} sprites from {args.input}")
        return 0
        
    except Exception as e:
        print(f"Error: {e}")
        return 1

if __name__ == "__main__":
    exit(main())