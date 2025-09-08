#!/usr/bin/env python3
"""
Animation Analysis Script
Analyzes debug_positions.txt for frame-to-frame inconsistencies in circular path animation.
"""
import math
import re

def parse_positions_file(filename):
    """Parse the debug positions file and extract frame data."""
    positions = []
    
    with open(filename, 'r') as f:
        for line_num, line in enumerate(f, 1):
            line = line.strip()
            if not line:
                continue
            
            # Skip progress lines and debug info
            if line.startswith('progress=') or 'frame-index=' in line:
                continue
                
            # Parse format: "x y" (frame number is implicit)
            parts = line.split()
            if len(parts) == 2:
                try:
                    x = float(parts[0])
                    y = float(parts[1])
                    positions.append((len(positions) + 1, x, y))  # Use sequential frame numbering
                except ValueError:
                    print(f"Warning: Could not parse line {line_num}: '{line}'")
            else:
                print(f"Warning: Unexpected format on line {line_num}: '{line}'")
    
    return positions

def calculate_distance(p1, p2):
    """Calculate Euclidean distance between two points."""
    return math.sqrt((p2[0] - p1[0])**2 + (p2[1] - p1[1])**2)

def analyze_animation_consistency(positions):
    """Analyze the animation for various inconsistencies."""
    if len(positions) < 2:
        return
    
    distances = []
    issues = {
        'jumps': [],      # Large sudden movements
        'stutters': [],   # Very small or backwards movements
        'pauses': [],     # Zero or near-zero movement
        'speed_variations': []  # Inconsistent speeds
    }
    
    print("Frame-by-Frame Analysis:")
    print("=" * 80)
    print(f"{'Frame':<6} {'X':<10} {'Y':<10} {'Distance':<10} {'Speed Ratio':<12} {'Issues':<20}")
    print("-" * 80)
    
    # Calculate distances between consecutive frames
    for i in range(1, len(positions)):
        prev_frame, prev_x, prev_y = positions[i-1]
        curr_frame, curr_x, curr_y = positions[i]
        
        distance = calculate_distance((prev_x, prev_y), (curr_x, curr_y))
        distances.append(distance)
        
        # Calculate speed ratio (current distance / previous distance)
        speed_ratio = 0
        if i > 1 and distances[i-2] > 0:
            speed_ratio = distance / distances[i-2]
        
        # Detect issues
        frame_issues = []
        
        # 1. Jumps - sudden large movements (> 3x average so far)
        if i > 5:  # Wait for some baseline
            avg_distance = sum(distances[:i-1]) / len(distances[:i-1])
            if distance > 3 * avg_distance and distance > 5:
                issues['jumps'].append((curr_frame, distance, avg_distance))
                frame_issues.append("JUMP")
        
        # 2. Stutters - very small movements (< 0.1) or backwards in expected direction
        if distance < 0.1:
            issues['stutters'].append((curr_frame, distance))
            frame_issues.append("STUTTER")
        
        # 3. Pauses - zero or near-zero movement
        if distance < 0.01:
            issues['pauses'].append((curr_frame, distance))
            frame_issues.append("PAUSE")
        
        # 4. Speed variations - significant speed changes
        if speed_ratio > 0 and (speed_ratio > 2.0 or speed_ratio < 0.5):
            issues['speed_variations'].append((curr_frame, speed_ratio, distance))
            if speed_ratio > 2.0:
                frame_issues.append("SPEED_UP")
            else:
                frame_issues.append("SLOW_DOWN")
        
        # Print frame analysis
        issues_str = ", ".join(frame_issues) if frame_issues else ""
        print(f"{curr_frame:<6} {curr_x:<10.3f} {curr_y:<10.3f} {distance:<10.3f} {speed_ratio:<12.3f} {issues_str:<20}")
    
    return distances, issues

def print_summary(distances, issues, positions):
    """Print a summary of the analysis."""
    print("\n\nSUMMARY ANALYSIS:")
    print("=" * 80)
    
    # Basic statistics
    if distances:
        avg_distance = sum(distances) / len(distances)
        max_distance = max(distances)
        min_distance = min(distances)
        
        print(f"Total frames analyzed: {len(positions)}")
        print(f"Average distance per frame: {avg_distance:.3f}")
        print(f"Maximum distance: {max_distance:.3f}")
        print(f"Minimum distance: {min_distance:.3f}")
        print(f"Distance standard deviation: {math.sqrt(sum((d - avg_distance)**2 for d in distances) / len(distances)):.3f}")
    
    print(f"\nISSUES DETECTED:")
    print("-" * 40)
    
    # Jumps
    if issues['jumps']:
        print(f"\n🔴 JUMPS ({len(issues['jumps'])} detected):")
        print("Large sudden movements between frames:")
        for frame, distance, avg in issues['jumps']:
            print(f"  Frame {frame}: Distance {distance:.3f} (avg: {avg:.3f}, ratio: {distance/avg:.1f}x)")
    
    # Stutters
    if issues['stutters']:
        print(f"\n🟡 STUTTERS ({len(issues['stutters'])} detected):")
        print("Very small movements between frames:")
        for frame, distance in issues['stutters']:
            print(f"  Frame {frame}: Distance {distance:.6f}")
    
    # Pauses
    if issues['pauses']:
        print(f"\n🟠 PAUSES ({len(issues['pauses'])} detected):")
        print("Zero or near-zero movement between frames:")
        for frame, distance in issues['pauses']:
            print(f"  Frame {frame}: Distance {distance:.6f}")
    
    # Speed variations
    if issues['speed_variations']:
        print(f"\n🔵 SPEED VARIATIONS ({len(issues['speed_variations'])} detected):")
        print("Significant speed changes between frames:")
        for frame, ratio, distance in issues['speed_variations']:
            if ratio > 2.0:
                print(f"  Frame {frame}: Speed increased {ratio:.1f}x (distance: {distance:.3f})")
            else:
                print(f"  Frame {frame}: Speed decreased {ratio:.1f}x (distance: {distance:.3f})")
    
    # Pattern analysis
    print(f"\nPATTERN ANALYSIS:")
    print("-" * 40)
    
    # Check for repetitive patterns
    if len(positions) >= 120:  # Look for cycles
        print("Checking for repetitive cycles...")
        
        # Check if positions repeat (indicating animation loops)
        cycle_detected = False
        for cycle_length in [120, 60, 180, 240]:  # Common cycle lengths
            if len(positions) >= cycle_length * 2:
                matches = 0
                for i in range(cycle_length):
                    if i < len(positions) - cycle_length:
                        p1 = positions[i]
                        p2 = positions[i + cycle_length]
                        if abs(p1[1] - p2[1]) < 0.1 and abs(p1[2] - p2[2]) < 0.1:
                            matches += 1
                
                if matches > cycle_length * 0.8:  # 80% match threshold
                    print(f"  Detected likely cycle length: {cycle_length} frames ({matches}/{cycle_length} matches)")
                    cycle_detected = True
                    break
        
        if not cycle_detected:
            print("  No clear repetitive cycle detected")
    
    # Identify problematic frame ranges
    print(f"\nPROBLEMATIC FRAME RANGES:")
    print("-" * 40)
    
    all_problem_frames = []
    for issue_type, issue_list in issues.items():
        for issue_data in issue_list:
            frame = issue_data[0]
            all_problem_frames.append((frame, issue_type))
    
    if all_problem_frames:
        all_problem_frames.sort()
        print("Frames with issues:")
        for frame, issue_type in all_problem_frames:
            print(f"  Frame {frame}: {issue_type.upper()}")
        
        # Look for clusters of problems
        problem_clusters = []
        current_cluster = [all_problem_frames[0][0]]
        
        for i in range(1, len(all_problem_frames)):
            if all_problem_frames[i][0] - all_problem_frames[i-1][0] <= 3:  # Within 3 frames
                current_cluster.append(all_problem_frames[i][0])
            else:
                if len(current_cluster) >= 3:  # 3 or more consecutive problems
                    problem_clusters.append(current_cluster)
                current_cluster = [all_problem_frames[i][0]]
        
        if len(current_cluster) >= 3:
            problem_clusters.append(current_cluster)
        
        if problem_clusters:
            print(f"\nProblem clusters (3+ issues within close frames):")
            for i, cluster in enumerate(problem_clusters):
                print(f"  Cluster {i+1}: Frames {min(cluster)}-{max(cluster)} ({len(cluster)} issues)")
    else:
        print("  No significant issues detected!")

def main():
    import sys
    if len(sys.argv) < 2:
        print("Usage: python3 analyze_animation.py <debug_positions_file>")
        return
    filename = sys.argv[1]
    
    print("Circular Path Animation Analysis")
    print("=" * 80)
    
    try:
        positions = parse_positions_file(filename)
        print(f"Loaded {len(positions)} position records")
        
        if len(positions) < 2:
            print("Error: Need at least 2 frames to analyze")
            return
        
        distances, issues = analyze_animation_consistency(positions)
        print_summary(distances, issues, positions)
        
    except FileNotFoundError:
        print(f"Error: Could not find file {filename}")
    except Exception as e:
        print(f"Error: {e}")

if __name__ == "__main__":
    main()