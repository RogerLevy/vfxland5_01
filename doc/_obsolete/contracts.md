# VFXLand5 Debug Contracts System

## Overview

The debug contracts system provides contract-oriented debugging for VFXLand5, enabling precondition and postcondition validation with zero runtime overhead when disabled. It supports advanced patterns including self-healing contracts and quantified collection validation.

## Core Architecture

### Contract Objects
Each contract is a `contract%` object containing:
- `pre-array` - Array of precondition validation functions
- `post-array` - Array of postcondition validation functions  
- `word-name` - Target word name (counted string)
- `level` - Required validation level (0-3)
- `flags` - Boolean behavior flags (bit field)
- `auto-corrector` - XT for self-healing function

### Condition Objects  
Each validation condition is a `condition%` object containing:
- `xt` - Execution token of validation function
- `desc` - Description string for logging
- `level` - Minimum validation level required (1-3)
- `enabled` - Flag controlling active/inactive state

### Injection Mechanism
- Overrides `;` (semicolon) to inject validation around word definitions
- Uses `find` to locate original word implementation
- Compiles wrapper: preconditions → original code → postconditions
- Controlled by global `validations` flag

## Basic Usage

### Creating Contracts
```forth
\ Create contract for a word
s" my-word" create-contract constant my-contract
my-contract register-contract

\ Add validation conditions
my-contract ['] bounds-check s" position in bounds" 1 add-precondition
my-contract ['] result-valid s" result non-null" 1 add-postcondition

\ Control individual conditions
my-contract ['] bounds-check disable-precondition
my-contract ['] bounds-check enable-precondition
```

### System Control
```forth
\ Enable/disable entire system
validations on    \ Enable contract validation
validations off   \ Disable contract validation

\ Set validation levels
basic      \ Level 1 - essential checks only
thorough   \ Level 2 - additional safety checks
paranoid   \ Level 3 - expensive comprehensive validation

\ Control by level
my-contract 2 disable-level  \ Disable all level-2 conditions
my-contract 1 enable-level   \ Enable all level-1 conditions
```

## Validation Levels

### Level Hierarchy
- **0 = Off** - No validation (system disabled)
- **1 = Basic** - Essential safety checks, minimal overhead
- **2 = Thorough** - Additional validation, moderate overhead  
- **3 = Paranoid** - Comprehensive checks, expensive operations

### Usage Contexts
- **Development**: Paranoid mode catches subtle bugs
- **Testing**: Thorough mode balances coverage vs performance
- **Production**: Basic mode provides essential safety only
- **Shipping**: Off mode eliminates all overhead

### Implementation Status
- ✅ **Condition Level Assignment**: Each condition has required level
- ✅ **Global Level Control**: `basic`, `thorough`, `paranoid` words
- ✅ **Level Filtering**: Injection system filters by strictness level

## Advanced Patterns

### Temporal Contracts (Deferred)

**Status**: Temporal contracts have been deferred to future development. The foundation code has been moved to `contracts-old-with-temporal.vfx` for reference.

**Intended Purpose**: Validate function call sequences and timing constraints.

**Deferred Features**:
- Call sequence validation and timing constraints
- Automatic call recording during execution  
- Sequence definition syntax
- Integration with contract injection system

**Example Use Cases** (for future implementation):
- File operations: `open → read → close`
- Object lifecycle: `create → init → activate`
- Resource management: `acquire → use → release`

**Note**: The core contract system provides robust precondition/postcondition validation, self-healing, and quantified contracts without temporal features.

### Self-Healing Contracts

**Purpose**: Automatically fix contract violations instead of just reporting them.

**Current Implementation**:
```forth
\ Register auto-corrector function
: fix-bounds ( -- )
    at@ clamp-to-screen at! ;

my-contract ['] fix-bounds self-healing:

\ Manually trigger correction
my-contract attempt-auto-correction drop
```

**Storage**: Corrector XT stored in contract's `auto-corrector` field, flag bit set in `flags` field

**Missing Features**:
- ❌ Automatic invocation during assertion failures
- ❌ Multiple correctors per contract
- ❌ Correction attempt logging with context
- ❌ Fallback correction strategies

**Example Correctors**:
- **Position bounds**: Clamp to valid screen coordinates
- **Resource recovery**: Fallback to default/safe resources
- **State repair**: Reset invalid object states
- **Memory cleanup**: Free leaked resources

### Quantified Contracts

**Purpose**: Validate collections and arrays with predicates.

**Current Implementation**:
```forth
\ Collection validation predicates
actors-array ['] actor-valid-state? all-satisfy assert-precondition
sprite-pool ['] sprite-in-bounds? any-satisfy assert-postcondition

\ Available predicates
all-satisfy    \ All elements must satisfy predicate
any-satisfy    \ At least one element must satisfy predicate  
none-satisfy   \ No elements may satisfy predicate
count-satisfying \ Count elements satisfying predicate
```

**Example Validations**:
```forth
\ All objects must be in valid state
: all-objects-valid ( -- f )
    objects-array ['] object-state-valid? all-satisfy ;

\ No objects may be at invalid positions  
: no-objects-out-of-bounds ( -- f )
    objects-array ['] object-out-of-bounds? none-satisfy ;

\ Count how many objects need updating
: count-dirty-objects ( -- n )
    objects-array ['] object-needs-update? count-satisfying ;
```

**Missing Features**:
- ❌ Game-specific helper predicates
- ❌ Nested collection validation
- ❌ Performance-optimized shortcuts for large collections

## System Integration

### Logging Integration
```forth
\ Console logging shims (for testing)
log-warning  \ [WARN] message
log-error    \ [ERROR] message  
log-debug    \ [DEBUG] message
log-info     \ [INFO] message

\ Automatic logging on violations
\ Assertion failures log context before halting/throwing
```

### Object Context Integration
```forth
\ Object-aware error handling
\ If `me` is set (any object context):
\   - Contract violations halt the current object
\   - Logs include object information
\ Otherwise:
\   - Contract violations throw exceptions
\   - Standard error propagation
```

### Debug System Integration
```forth
\ System management
init-contracts      \ Initialize on startup
shutdown-contracts  \ Clean shutdown with violation summary
contracts-stats     \ Display system statistics
list-contracts      \ List all registered contracts
debug-contract      \ Show detailed contract information

\ Statistics tracked
#contracts    \ Total contracts registered
#violations   \ Total violations detected
```

## File Structure

### Main Implementation
- `etc/contracts.vfx` - Complete contract system implementation

### Supporting Files  
- `doc/contracts.md` - This documentation
- `doc/claude/forth-conventions.txt` - Forth-specific development notes

### Backup Files
- `etc/contracts_phase0_backup.vfx` - Structure & declarations
- `etc/contracts_phase1_complete.vfx` - Basic object system
- `etc/contracts_phase2_complete.vfx` - Injection system  
- `etc/contracts_phase3_complete.vfx` - Logging integration

## Implementation Status

### ✅ Completed Features
- Core contract object system with flag-based conditions
- Semicolon override with automatic injection
- Precondition and postcondition validation
- Enable/disable individual conditions and levels
- Console logging integration
- Contract registry with dictionary lookup
- Advanced contract patterns (basic implementation)
- Quantified collection validation
- Self-healing contract registration  
- Comprehensive test suite

### ❌ Missing Features
- Automatic auto-correction integration in assertions
- Game-specific quantified contract helpers
- Multiple auto-correctors per contract
- Comprehensive error context logging
- Integration with full logging system (vs console shims)

## Testing

### Basic Tests
```forth
test-reporting  \ Test all reporting and management functions
```

### Advanced Tests  
```forth
test-advanced-patterns  \ Test temporal, self-healing, quantified patterns
```

### Test Data
- `c1`, `c2` - Test contract objects
- `always-true`, `always-false`, `bounds-check` - Test condition functions
- `test-corrector` - Test auto-correction function

## Performance Characteristics

### Zero Overhead When Disabled
- `validations off` completely disables injection
- No runtime cost for disabled contracts
- Clean separation between debug and production code

### Minimal Overhead When Enabled  
- Direct function calls (no string processing)
- Flag-based condition filtering
- Immediate assertion failure handling

### Configurable Validation Intensity
- Level-based filtering allows performance tuning
- Essential checks vs comprehensive validation
- Context-appropriate validation depth