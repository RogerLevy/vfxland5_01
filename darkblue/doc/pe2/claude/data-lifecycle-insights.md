# PE2 Data Lifecycle Design Insights

## Interactive Forth Context Considerations

### Dictionary vs Registry Approach

**Recommendation: Use Forth Dictionary Directly**

Instead of a separate path registry, store paths as regular Forth words that return path objects. This aligns with Forth philosophy and interactive development patterns.

**Advantages:**
- Simpler - leverages existing dictionary mechanisms
- Natural Forth idiom - paths become callable words
- No separate lookup layer to maintain  
- Tab completion and dictionary browsing work automatically
- Immediate word redefinition for live testing

**Potential Issues:**
- Namespace pollution if paths mix with regular words
- Name conflicts (e.g., path named "ship" shadowing existing words)
- Dictionary modifications at runtime (VFX Forth should handle fine)
- Accumulating old definitions during frequent redefinition

**Mitigation:**
- Use consistent naming convention: `enemy1.path`, `boss-entry.path`
- Editor checks for conflicts before creating names
- Periodic cleanup if needed

### Recommended Workflow

**Compile Time:**
- `load-paths` creates dictionary words for all path files
- Scripts reliably reference `enemy1.path`, `boss-entry.path`
- Stable names enable predictable actor scripting

**Runtime (Path Editor):**
- Modify existing path objects in-place for live testing
- Clone and redefine words: `enemy1.path clone-path "enemy1-variant.path" define-word`
- Changes affect gameplay immediately - actors pull from same dictionary
- Live path updates enable fluid iteration

**Development Cycle:**
1. Edit paths in pe2 tool while game runs
2. Test enemy behavior with live path updates
3. Save promising variants to files when satisfied  
4. Restart/recompile to make changes permanent

This approach provides predictable compile-time names for reliable scripting plus fluid runtime editing for rapid iteration, using the Forth dictionary as the natural bridge between contexts.