# Oversight Performance Optimization Plans

**Current Performance Issue:**
- 22x slowdown (67ms → 1456ms) when contracts enabled
- Makes real-time gameplay impossible (need <16ms per frame at 60fps)

## Plan 1: Micro-optimization Plan

**Target: Reduce 22x overhead to 15-20x (15% improvement) while preserving error reporting**

### Optimization 1: Eliminate Stack Locals  
- Replace `{: ... :}` syntax with direct stack manipulation
- Remove `to variable` patterns in favor of stack operations
- **Expected savings: 20-30% per validation**

### Optimization 2: Streamline Error Reporting
- Replace `s" text" log-error` with numeric error codes
- Pre-allocate common error messages 
- **Expected savings: 10-15% per validation**

### Optimization 3: Consolidate Validator Calls
- Combine multiple `validate` calls into single operations
- Inline simple validators like null checks
- **Expected savings: 5-10% per validation**

### Optimization 4: Simplify Range Checking  
- Replace `within` with direct comparisons for common cases
- Cache validation results for repeated checks
- **Expected savings: 5% overall**

### Optimization 5: Remove Redundant Work
- Eliminate duplicate address validations in multi-parameter checks
- Streamline boolean logic combinations
- **Expected savings: 3-5% overall**

**Combined expected improvement: 22x → 17x performance hit**

## Plan 2: Oversight Runtime Optimization Plan

**Target: Reduce 22x overhead to 15-17x by eliminating expensive runtime operations**

### Priority 1: Remove Stack Locals (Biggest Impact)
- **Lines 182, 217, 263, 275, 404, 451**: Replace `{: ... :}` with direct stack manipulation
- **Expected savings: 25-30%** - Stack locals are very expensive in VFX Forth

### Priority 2: Simplify Error Reporting  
- **Lines 205, 210**: Replace `f" %s : %s"` formatting with simpler concatenation or pre-built messages
- **Lines 206, 211**: Make `.s` conditional or remove entirely
- **Expected savings: 15-20%** - String formatting is expensive

### Priority 3: Cache Name Lookups
- **Lines 183, 333**: Cache validation names instead of repeated `>name count` 
- Store name in validation object during creation
- **Expected savings: 5-10%** - Name conversion happens frequently

### Priority 4: Optimize Array Processing
- **Lines 219-226**: Inline `should-execute?` test, reduce object property access
- **Line 224**: Minimize indirection in validation execution  
- **Expected savings: 10-15%** - Hot path optimization

### Priority 5: Remove Debug Overhead
- **Line 203**: Make `ip>nfa` lookup conditional
- **Lines 333**: Make self-fix logging conditional  
- **Expected savings: 5%** - Debug operations in production

**Combined expected improvement: 22x → 15-17x performance hit**

## Performance Bottlenecks Identified in contract-system.vfx

### Major Hotspots:

1. **Stack Locals Overhead** (Lines 182, 217, 263, 275, 404, 451)
   ```forth
   {: res c val | name-a name-len :}    # Line 182
   {: c arr | val :}                    # Line 217  
   {: validator name-a name-len | c val :}  # Lines 263, 275
   ```

2. **String Formatting in Hot Path** (Lines 205, 210)
   ```forth
   name-a name-len callername @ count f" %s : %s failed (THROW)" log-error
   name-a name-len callername @ count f" %s : %s failed (OK)" log-warning
   ```

3. **Redundant Name Lookups** (Lines 183, 333)
   ```forth
   val 's xt @ >name count to name-len to name-a    # Line 183
   current-validation @ 's xt @ >name count f" %s performing self-fix..." log-info  # Line 333
   ```

4. **Stack Inspection** (Lines 206, 211)
   ```forth
   .s    # Called on every validation failure
   ```

5. **Complex Array Iteration** (Lines 219-226)
   ```forth
   arr #items for
       i arr [] @ to val
       val should-execute? if
           val current-validation !
           should-recheck? off
           val 's xt @ execute c val check
       then
   loop
   ```

6. **IP to Name Conversion** (Line 203)
   ```forth
   caller @ ip>nfa callername !
   ```

7. **Object Property Access Overhead** (Throughout)
   ```forth
   val 's xt @
   c 's pre-array @
   val should-execute?
   ```

## Notes

- Primary purpose is error reporting, not crash prevention
- `safety off` already provides zero-overhead disable
- High performance hit (15-20x) is acceptable for development benefits
- Focus on micro-optimizations rather than architectural changes