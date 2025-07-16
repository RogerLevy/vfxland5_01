#!/usr/bin/env python3
"""
Analyze ALP point spacing for fixed-point error accumulation
"""
import math

def analyze_alp_spacing(filename):
    """Analyze the spacing between consecutive ALP points."""
    points = []
    
    with open(filename, 'r') as f:
        for line in f:
            parts = line.strip().split()
            if len(parts) == 2:
                x = float(parts[0])
                y = float(parts[1])
                points.append((x, y))
    
    print(f"Loaded {len(points)} ALP points")
    print("=" * 80)
    
    # Calculate distances between consecutive points
    distances = []
    for i in range(1, len(points)):
        x1, y1 = points[i-1]
        x2, y2 = points[i]
        dist = math.sqrt((x2-x1)**2 + (y2-y1)**2)
        distances.append(dist)
    
    # Statistics
    avg_dist = sum(distances) / len(distances)
    max_dist = max(distances)
    min_dist = min(distances)
    std_dev = math.sqrt(sum((d - avg_dist)**2 for d in distances) / len(distances))
    
    print(f"Distance Statistics:")
    print(f"  Average: {avg_dist:.6f}")
    print(f"  Min:     {min_dist:.6f}")
    print(f"  Max:     {max_dist:.6f}")
    print(f"  Std Dev: {std_dev:.6f}")
    print(f"  Range:   {max_dist - min_dist:.6f}")
    
    # Check for problematic spacing
    tolerance = avg_dist * 0.1  # 10% tolerance
    outliers = []
    
    print(f"\nSpacing Analysis (tolerance: ±{tolerance:.6f}):")
    print("-" * 60)
    print(f"{'Index':<6} {'Distance':<12} {'Deviation':<12} {'Status'}")
    print("-" * 60)
    
    for i, dist in enumerate(distances):
        deviation = abs(dist - avg_dist)
        status = "OUTLIER" if deviation > tolerance else "OK"
        if deviation > tolerance:
            outliers.append((i+1, dist, deviation))
        print(f"{i+1:<6} {dist:<12.6f} {deviation:<12.6f} {status}")
    
    # Check closure gap
    first_point = points[0]
    last_point = points[-1]
    closure_gap = math.sqrt((last_point[0] - first_point[0])**2 + (last_point[1] - first_point[1])**2)
    
    print(f"\nClosure Analysis:")
    print(f"  First point: ({first_point[0]:.6f}, {first_point[1]:.6f})")
    print(f"  Last point:  ({last_point[0]:.6f}, {last_point[1]:.6f})")
    print(f"  Gap:         {closure_gap:.6f}")
    print(f"  Gap/Avg:     {closure_gap/avg_dist:.2f}x average spacing")
    
    # Fixed-point error analysis
    print(f"\nFixed-Point Error Analysis:")
    print("-" * 40)
    
    # Simulate 16.16 fixed-point accumulation
    # In VFX Forth, the target-step calculation is: total-length / #target-samples
    total_arc_length = sum(distances)
    num_samples = len(points)
    target_step_exact = total_arc_length / num_samples
    
    # Convert to 16.16 fixed point (multiply by 65536)
    target_step_fp = int(target_step_exact * 65536)
    target_step_recovered = target_step_fp / 65536
    
    print(f"  Total arc length: {total_arc_length:.6f}")
    print(f"  Target samples:   {num_samples}")
    print(f"  Exact step:       {target_step_exact:.9f}")
    print(f"  Fixed-point step: {target_step_recovered:.9f}")
    print(f"  Quantization err: {abs(target_step_exact - target_step_recovered):.9f}")
    
    # Accumulated error over the path
    accumulated_error = (target_step_exact - target_step_recovered) * num_samples
    print(f"  Accumulated err:  {accumulated_error:.6f}")
    print(f"  vs Closure gap:   {closure_gap:.6f}")
    
    if abs(accumulated_error - closure_gap) < 0.1:
        print("  *** LIKELY CAUSE: Fixed-point quantization error! ***")
    
    return outliers, closure_gap, accumulated_error

if __name__ == "__main__":
    import sys
    if len(sys.argv) < 2:
        print("Usage: python3 analyze_spacing.py debug_alpdata.txt")
        sys.exit(1)
    
    analyze_alp_spacing(sys.argv[1])