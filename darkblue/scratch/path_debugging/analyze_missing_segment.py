#!/usr/bin/env python3
"""
Analyze what points should exist in the final segment
"""
import math

def analyze_missing_segment():
    # Current data
    points = []
    with open('debug_alpdata.txt', 'r') as f:
        for line in f:
            parts = line.strip().split()
            if len(parts) == 2:
                x = float(parts[0])
                y = float(parts[1])
                points.append((x, y))
    
    first_point = points[0]
    last_point = points[-1]
    
    print(f"Current ALP data has {len(points)} points")
    print(f"First point: ({first_point[0]:.6f}, {first_point[1]:.6f})")
    print(f"Last point:  ({last_point[0]:.6f}, {last_point[1]:.6f})")
    print(f"Gap: {math.sqrt((last_point[0] - first_point[0])**2 + (last_point[1] - first_point[1])**2):.6f}")
    
    # Calculate average spacing
    distances = []
    for i in range(1, len(points)):
        x1, y1 = points[i-1]
        x2, y2 = points[i]
        dist = math.sqrt((x2-x1)**2 + (y2-y1)**2)
        distances.append(dist)
    
    avg_spacing = sum(distances) / len(distances)
    total_arc_length = sum(distances)
    gap_distance = math.sqrt((last_point[0] - first_point[0])**2 + (last_point[1] - first_point[1])**2)
    
    print(f"\nSpacing analysis:")
    print(f"Average spacing between points: {avg_spacing:.6f}")
    print(f"Total arc length of {len(points)-1} segments: {total_arc_length:.6f}")
    print(f"Gap from last to first: {gap_distance:.6f}")
    print(f"Gap / avg spacing: {gap_distance / avg_spacing:.2f}")
    
    # How many points should be in the gap?
    missing_points = round(gap_distance / avg_spacing)
    print(f"\nMissing points needed: ~{missing_points}")
    
    # If we include the gap, what should the total arc length be?
    complete_arc_length = total_arc_length + gap_distance
    print(f"Complete circular arc length: {complete_arc_length:.6f}")
    
    # What should the target samples be for a complete circle?
    ideal_samples = round(complete_arc_length / avg_spacing)
    print(f"Ideal total samples for complete circle: {ideal_samples}")
    
    # Current algorithm parameters
    print(f"\nCurrent algorithm:")
    print(f"  #target-samples = {len(points)} (from total-duration 60 1000 */)")
    print(f"  Generates {len(points)} points")
    print(f"  Missing final wraparound segment")
    
    print(f"\nFix options:")
    print(f"1. Generate {ideal_samples} points total (including wraparound)")
    print(f"2. Generate {len(points)} points + explicit closure")
    print(f"3. Adjust total-duration calculation to account for closure")

if __name__ == "__main__":
    analyze_missing_segment()