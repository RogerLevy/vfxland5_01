Collapse a development branch into a single milestone commit on main.

**PROCESS**:
1. Verify the target branch exists: `git branch -a | grep $ARGUMENTS`
2. Import branch tree state: `git read-tree $ARGUMENTS`
3. Update working directory: `git checkout-index -a -f`
4. Create milestone commit with comprehensive message

**COMMIT MESSAGE FORMAT**:
```
<Branch name> development - <brief summary>

<Major additions and improvements>:
- <Key system 1>: <brief description>
- <Key system 2>: <brief description>
- <Key system 3>: <brief description>
- <Documentation, testing, and tooling improvements>
```

**USAGE**: `/collapse branch-name`

**PURPOSE**: 
Converts a feature branch's entire development history into a single milestone commit on main, capturing the complete state achieved during that development cycle. This supports sprint-style development where commits represent meaningful system states rather than incremental changes.

**IMPORTANT**: This operation adds the branch's final state as a new commit on main without altering existing history.