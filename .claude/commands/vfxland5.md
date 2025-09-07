# VFXLand5 System Context

## Key System Files

@engineer/build.vfx
@engineer/vfxcore2.vfx
@engineer/misc.vfx
@engineer/format.vfx
@doc/nibs/nib2-spec.txt
@doc/nibs/nib2-status.txt
@engineer/nib2.vfx
@engineer/nib2-tools.vfx
@engineer/array2.vfx
@doc/oversight/oversight.md
@engineer/fixed.vfx
@engineer/gamemath.vfx
@engineer/engineer.vfx
@engineer/ide3.vfx
@supershow/supershow.vfx
@supershow/stage.vfx
@supershow/tools.vfx
@spunk/spunk.vfx
@spunk/loader.vfx

## Coding Tips

### Obsolete Words
    Forgot the standard FORTH words `1+` `1-` `2+` `2-` `2*` `2/`. 2+ 2- 2* 2/  are redefined to operate on coordinate pairs.

### Non-existent Language Features
    `[: ... ;]` - Lambda functions don't exist. Instead, create private words at the top level.
    `value` and `:` in word definitions - Forth doesn't support them.  Put these at the top level in private blocks.
    
