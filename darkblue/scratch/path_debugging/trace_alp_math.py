#!/usr/bin/env python3
"""
Trace the math error in alp, generation
"""

def trace_alp_math():
    # Using circle-path data from our analysis
    total_length = 310.715483  # From spacing analysis
    target_samples = 119       # From debug output
    
    target_step = total_length / target_samples
    print(f"Total length: {total_length}")
    print(f"Target samples: {target_samples}")  
    print(f"Target step: {target_step}")
    print()
    
    print("Forth loop analysis:")
    print("Loop: #target-samples 1 do")
    print(f"Runs from i=1 to i={target_samples-1}")
    print()
    
    print("Target positions generated:")
    for i in range(1, min(6, target_samples)):  # First few
        current_target = i * target_step
        progress = current_target / total_length
        print(f"i={i}: current_target={current_target:.3f}, progress={progress:.3f}")
    
    print("...")
    
    for i in range(max(1, target_samples-5), target_samples):  # Last few
        current_target = i * target_step
        progress = current_target / total_length
        print(f"i={i}: current_target={current_target:.3f}, progress={progress:.3f}")
    
    print()
    print("*** THE PROBLEM ***")
    last_i = target_samples - 1
    last_current_target = last_i * target_step
    max_progress = last_current_target / total_length
    
    print(f"Last iteration: i={last_i}")
    print(f"Last current_target: {last_current_target:.6f}")
    print(f"Maximum progress reached: {max_progress:.6f}")
    print(f"Missing progress: {1.0 - max_progress:.6f}")
    print(f"Missing arc length: {total_length * (1.0 - max_progress):.6f}")
    
    # What SHOULD happen
    print()
    print("What should happen for complete coverage:")
    print("Loop should run from i=1 to i=#target-samples")
    print("OR")  
    print("Loop should run from i=0 to i=#target-samples-1")
    print("OR")
    print("Add explicit final point at full arc length")

if __name__ == "__main__":
    trace_alp_math()