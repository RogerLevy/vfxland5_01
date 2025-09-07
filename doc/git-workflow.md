# Git Workflow and Repository Management

## Development Workflow

- **Main branch**: Stable milestones/snapshots/sprints only
- **Feature/development branches**: Active development work
- **Collapse strategy**: Squash/rebase feature branches into clean commits on main

## Game Project Separation Plan

### Current Strategy
- Games are developed separately from the engine repository
- `darkblue/` may be temporarily included as testing grounds for engine refinements
- Mixed commits on feature branches will contain both engine and game changes

### Separation Process
When engine is stable OR when darkblue is complete:

1. **Move game to separate repository** (before history cleanup)
2. **Remove game directory from engine repo history** using:
   ```bash
   git filter-repo --path darkblue --invert-paths
   ```
3. **Clean up and force push**:
   ```bash
   git push --force-with-lease
   ```

### Repository Characteristics
- **Size**: Small-to-medium (72MB .git, 513 commits, 145 VFX files)
- **Tool choice**: `git filter-repo` (modern standard, appropriate for repo size)
- **Preserves**: All timestamps (author and committer dates remain unchanged)
- **Changes**: Only commit SHAs change due to tree modifications

### Important Notes
- History rewriting affects all commit SHAs
- Collaborators need fresh clones after force push
- Make backups before running filter-repo
- BFG Repo-Cleaner speed advantage only matters for massive repositories (1GB+, 10k+ commits)

## Alternative Tools (for reference)

### git filter-branch (built-in but slower)
```bash
git filter-branch --force --index-filter \
  'git rm --cached --ignore-unmatch -r darkblue' \
  --prune-empty --tag-name-filter cat -- --all
```

### BFG Repo-Cleaner (overkill for this repo size)
```bash
java -jar bfg.jar --delete-folders darkblue
git reflog expire --expire=now --all && git gc --prune=now --aggressive
```