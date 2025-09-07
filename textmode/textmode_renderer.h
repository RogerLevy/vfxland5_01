#ifndef TEXTMODE_RENDERER_H
#define TEXTMODE_RENDERER_H

#ifdef __cplusplus
extern "C" {
#endif

// Function to draw text with per-character foreground and background colors
// font: ALLEGRO_FONT pointer
// chars: Array of 8-bit character codes
// fg_colors: Array of 32-bit RGBA foreground colors
// bg_colors: Array of 32-bit RGBA background colors  
// num_cols: Number of columns in the text buffer
// num_rows: Number of rows in the text buffer
// x, y: Position to draw the text buffer
// Returns: 0 on success, 1 on error
__declspec(dllexport) int __cdecl draw_textmode_buffers(
    void* font,
    void* chars,
    void* fg_colors,
    void* bg_colors,
    int num_cols,
    int num_rows,
    float x,
    float y
);

#ifdef __cplusplus
}
#endif

#endif // TEXTMODE_RENDERER_H