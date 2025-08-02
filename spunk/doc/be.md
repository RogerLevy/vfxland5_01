# Bitmap Editor (BE)

The Spunk Bitmap Editor is an interactive graphics editor that runs within the game environment, allowing real-time sprite and bitmap editing with immediate visual feedback.

## Starting the Editor

```forth
be
```

Launches the bitmap editor interface overlaid on the running game.

## Interface Layout

The editor consists of five main components:

- **Toolbox** - Draggable interface panel (currently minimal)
- **Canvas** - Main editing area with zoom and pixel painting
- **Info** - Current bitmap number and filename display
- **Toolbar** - Reserved for action buttons (not yet implemented)
- **Palette** - Reserved for color selection (not yet implemented)

## Navigation Controls

### Bitmap Selection
- `,` - Previous bitmap
- `.` - Next bitmap  
- `<` - Jump back 10 bitmaps
- `>` - Jump forward 10 bitmaps

### Zoom Controls
- `-` - Zoom out
- `=` - Zoom in
- Auto-zoom adjusts based on bitmap dimensions

### Mouse Controls (Canvas Area)
- **Left Click** - Paint single pixels with current color
- **Right Click** - Eyedropper (sample color from pixel under cursor)
- **Ctrl+Click** - Pick sprite/bitmap under cursor from game world

## File Operations

### Saving
- **Ctrl+S** - Save current bitmap to `dat/gfx/` directory

The editor automatically determines the correct filename and saves to the appropriate graphics directory with proper lowercase conversion.

## Current Editing Capabilities

The editor currently supports:

- **Pixel-level painting** - Direct pixel manipulation with left-click
- **Color sampling** - Right-click eyedropper to pick colors
- **Single color painting** - Uses `c1` color array (white by default)

**Not yet implemented:**
- Multiple painting tools (paint, line, flood fill are defined but empty)
- Paint mode selection (normal, replace, fill-in constants exist but unused)
- Brush selection and sizing
- Color palette interface
- Toolbar functionality

## General Controls

- **P** - Toggle pause (stops game logic and animations)

When paused, the game world freezes while allowing continued editing.

## Usage Workflow

1. Launch the editor with `be`
2. Navigate to desired bitmap using `,` `.` `<` `>` keys
3. Left-click on canvas to paint individual pixels
4. Right-click to sample colors from existing pixels
5. Use **Ctrl+Click** to pick different sprites from the game world
6. Save changes with **Ctrl+S**
7. Test changes in live game context

## Live Editing

The editor runs as an overlay on the active game, providing immediate visual feedback. Sprites can be edited while seeing them in their actual game context, making it easy to adjust graphics for proper integration.

## Technical Notes

- Keyboard input is locked from the game while editor is active
- Mouse coordinates are tracked for pixel-precise editing
- Supports sub-bitmap editing for sprite sheets
- Automatic parent bitmap detection for saving
- Zoom levels automatically calculated based on bitmap size (1x to 8x)
- Uses Allegro bitmap targeting for direct pixel manipulation
- Color information stored in floating-point RGBA format