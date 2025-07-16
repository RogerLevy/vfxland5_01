# Documentation Insights - VFXLand5 Evolution

## Key Discussion Points

### Two-Tier Documentation Strategy
- **Ultra-condensed versions** = Quick reference/cheatsheet
  - Fast lookup during coding
  - Learning API surface area
  - "What exists and what does it do?"
  - Scannable for experienced users

- **Detailed versions** = Deep dive reference  
  - Complete parameter understanding
  - Cross-references and relationships
  - Usage context and examples
  - "How exactly does this work and how do I use it?"

### API Character Assessment
**Organic Growth Patterns:**
- Rich utility ecosystem grown from real needs (`-path`, `-ext`, `ending`)
- Multiple abstraction levels for similar tasks (`>object`, `one`, `*[[`)
- Domain-specific clusters that work well together (tilemap metadata, fixed-point math)

**Areas of Concern:**
- Multiple ways to do the same thing (main pain point)
- Inconsistent naming patterns (`bmpw`/`bmph` vs `bmpwh`)
- Mix of very specific (`instakill?`) and very generic (`2?`) utilities

**Surprising Strengths:**
- Continuation patterns (`tmcol>`, `walk>`, `act>`) are elegant
- Property access system (`'s`) is clean
- Domain-specific solutions like `cut-corners` for collision sliding
- Auto-class system provides useful automation

### Forth as "Topic-Oriented" Programming
- Forth's natural grain is functional domains and data flow, not inheritance hierarchies
- Different instantiation paths serve different "topics":
  - `>object` = memory management level
  - `one` = actor lifecycle level  
  - `*[[` = scripting convenience level
- Need explicit domain boundaries since everything is addresses on stack
- Each .vfx file is essentially a topic with its own vocabulary

### Making Domain Boundaries Clearer
**Through Organization & Documentation (not renaming):**
- Stack comment discipline: `( actor1 actor2 - f )` not `( a a - f )`
- Consistent parameter naming in documentation
- File/section organization that groups domain operations
- Cross-references showing when jumping between domains

### The Minimalism vs. Expressiveness Tension
**Historical Context:**
- Minimalist approach (`a` for everything, terse comments) optimized for:
  - Immediate coding velocity
  - Cognitive compression
  - Rapid iteration and experimentation
  - Systems that fit in one person's head

**Evolution Point:**
- VFXLand5 has outgrown the minimalist approach
- Cognitive load shifted from "what does this do?" to "what domain am I in?"
- System complexity requires more expressive documentation

**Phase-Appropriate Approaches:**
- **Terse style**: Great for exploration, prototyping, small systems
- **Expressive style**: Essential when system outgrows working memory
- Need to recognize the threshold crossing

### Looking Forward to "02"
- Challenge: Right level of unification without losing safety boundaries
- Goal: Clearer patterns rather than fewer words
- Approach: Make existing structure more visible rather than restructuring
- Focus: Presentation and organization improvements over semantic changes

## Practical Outcomes
1. Ultra-condensed glossaries serve as excellent cheat sheets
2. Detailed glossaries can lean more into "deep dive" role with examples and cross-links
3. Stack comments should be more expressive about domains and types
4. File organization should make domain boundaries explicit
5. The organic growth reflects real usage - don't over-consolidate in "02"