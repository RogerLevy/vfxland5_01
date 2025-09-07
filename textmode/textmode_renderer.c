#include <windows.h>
#include <stdint.h>
#include <stdio.h>
#include "textmode_renderer.h"

// Allegro function pointers - will be loaded dynamically
static HMODULE allegro_dll = NULL;

// Font functions
static int ( *al_get_glyph_width )( void* font, int codepoint ) = NULL;
static int ( *al_get_font_line_height )( void* font ) = NULL;
static void ( *al_draw_glyph )( void* font, float r, float g, float b, float a, float x, float y, int codepoint ) = NULL;

// Bitmap functions
static void* ( *al_create_bitmap )( int w, int h ) = NULL;
static void ( *al_destroy_bitmap )( void* bitmap ) = NULL;
static void* ( *al_lock_bitmap )( void* bitmap, int format, int flags ) = NULL;
static void ( *al_unlock_bitmap )( void* bitmap ) = NULL;
static void ( *al_draw_scaled_bitmap )( void* bitmap, float sx, float sy, float sw, float sh, float dx, float dy, float dw, float dh, int flags ) = NULL;

// Utility functions
static void ( *al_hold_bitmap_drawing )( int hold ) = NULL;
static void ( *al_set_new_bitmap_flags )( int flags ) = NULL;
static void ( *al_set_new_bitmap_format )( int format ) = NULL;

// Allegro constants ( from headers )
#define ALLEGRO_PIXEL_FORMAT_ABGR_8888 17
#define ALLEGRO_PIXEL_FORMAT_RGBA_8888 10
#define ALLEGRO_LOCK_WRITEONLY 2
#define ALLEGRO_MEMORY_BITMAP 0x0001

// Structure for locked bitmap region
typedef struct ALLEGRO_LOCKED_REGION {
    void* data;
    int format;
    int pitch;
    int pixel_size;
} ALLEGRO_LOCKED_REGION;

// Initialize Allegro function pointers
static int init_allegro_functions() {
    if ( allegro_dll != NULL ) return 1; // Already initialized
    
    allegro_dll = LoadLibraryA( "allegro_monolith-5.2.dll" );
    if ( !allegro_dll ) {
        return 0; // Failed to load DLL
    }
    
    // Load font functions
    al_get_glyph_width = ( int(*)( void*, int ) )GetProcAddress( allegro_dll, "al_get_glyph_width" );
    al_get_font_line_height = ( int(*)( void* ) )GetProcAddress( allegro_dll, "al_get_font_line_height" );
    al_draw_glyph = ( void(*)( void*, float, float, float, float, float, float, int ) )GetProcAddress( allegro_dll, "al_draw_glyph" );
    
    // Load bitmap functions
    al_create_bitmap = ( void*(*)( int, int ) )GetProcAddress( allegro_dll, "al_create_bitmap" );
    al_destroy_bitmap = ( void(*)( void* ) )GetProcAddress( allegro_dll, "al_destroy_bitmap" );
    al_lock_bitmap = ( void*(*)( void*, int, int ) )GetProcAddress( allegro_dll, "al_lock_bitmap" );
    al_unlock_bitmap = ( void(*)( void* ) )GetProcAddress( allegro_dll, "al_unlock_bitmap" );
    al_draw_scaled_bitmap = ( void(*)( void*, float, float, float, float, float, float, float, float, int ) )GetProcAddress( allegro_dll, "al_draw_scaled_bitmap" );
    
    // Load utility functions
    al_hold_bitmap_drawing = ( void(*)( int ) )GetProcAddress( allegro_dll, "al_hold_bitmap_drawing" );
    al_set_new_bitmap_flags = ( void(*)( int ) )GetProcAddress( allegro_dll, "al_set_new_bitmap_flags" );
    al_set_new_bitmap_format = ( void(*)( int ) )GetProcAddress( allegro_dll, "al_set_new_bitmap_format" );
    
    // Check if all functions loaded successfully
    if ( !al_get_glyph_width || !al_get_font_line_height || !al_draw_glyph ||
        !al_create_bitmap || !al_destroy_bitmap || !al_lock_bitmap || !al_unlock_bitmap ||
        !al_draw_scaled_bitmap || !al_hold_bitmap_drawing || !al_set_new_bitmap_flags || !al_set_new_bitmap_format ) {
        FreeLibrary( allegro_dll );
        allegro_dll = NULL;
        return 0; // Failed to load all functions
    }
    
    return 1; // Success
}

// Extract RGBA components from 32-bit color
static void unpack_rgba( uint32_t color, float* r, float* g, float* b, float* a ) {
    *r = ( ( color >> 24 ) & 0xFF ) / 255.0f;
    *g = ( ( color >> 16 ) & 0xFF ) / 255.0f;
    *b = ( ( color >> 8 ) & 0xFF ) / 255.0f;
    *a = ( color & 0xFF ) / 255.0f;
}

__declspec( dllexport ) int __cdecl draw_textmode_buffers( 
    void* font,
    void* chars,
    void* fg_colors,
    void* bg_colors,
    int num_cols,
    int num_rows,
    float x,
    float y,
    float line_spacing
 ) {
    OutputDebugStringA("draw_textmode_buffers: Starting...\n");
    
    // Initialize Allegro functions if not already done
    if ( !init_allegro_functions() ) {
        OutputDebugStringA("draw_textmode_buffers: ERROR - Failed to initialize Allegro functions\n");
        return 1; // Failed to initialize
    }
    
    // Validate input parameters
    if ( !font ) {
        OutputDebugStringA("draw_textmode_buffers: ERROR - Font parameter is NULL\n");
        return 1;
    }
    if ( !chars ) {
        OutputDebugStringA("draw_textmode_buffers: ERROR - chars parameter is NULL\n");
        return 1;
    }
    if ( !fg_colors ) {
        OutputDebugStringA("draw_textmode_buffers: ERROR - fg_colors parameter is NULL\n");
        return 1;
    }
    if ( !bg_colors ) {
        OutputDebugStringA("draw_textmode_buffers: ERROR - bg_colors parameter is NULL\n");
        return 1;
    }
    if ( num_cols <= 0 || num_rows <= 0 ) {
        char debug_msg[256];
        sprintf_s(debug_msg, 256, "draw_textmode_buffers: ERROR - Invalid dimensions: %d x %d\n", num_cols, num_rows);
        OutputDebugStringA(debug_msg);
        return 1;
    }
    
    char debug_msg[256];
    sprintf_s(debug_msg, 256, "draw_textmode_buffers: Parameters OK - font=%p, dims=%dx%d, pos=(%.1f,%.1f)\n", 
              font, num_cols, num_rows, x, y);
    OutputDebugStringA(debug_msg);
    
    uint8_t* char_array = ( uint8_t* )chars;
    uint32_t* fg_array = ( uint32_t* )fg_colors;
    uint32_t* bg_array = ( uint32_t* )bg_colors;
    
    // Get font dimensions ( assume monospace )
    int char_width = 0;
    int char_height = 0;
    
    if ( al_get_glyph_width && al_get_font_line_height ) {
        OutputDebugStringA("draw_textmode_buffers: Calling font dimension functions...\n");
        char_width = al_get_glyph_width( font, 'A' );
        char_height = al_get_font_line_height( font );
        sprintf_s(debug_msg, 256, "draw_textmode_buffers: Font dimensions: %dx%d\n", char_width, char_height);
        OutputDebugStringA(debug_msg);
    } else {
        OutputDebugStringA("draw_textmode_buffers: ERROR - Font function pointers are NULL\n");
        return 1;
    }
    
    if ( char_width <= 0 || char_height <= 0 ) {
        sprintf_s(debug_msg, 256, "draw_textmode_buffers: ERROR - Invalid font dimensions: %dx%d\n", char_width, char_height);
        OutputDebugStringA(debug_msg);
        return 1; // Invalid font dimensions
    }
    
    // Create background bitmap - just num_cols x num_rows, let Allegro scale it
    // al_set_new_bitmap_flags( ALLEGRO_MEMORY_BITMAP );
    al_set_new_bitmap_format( ALLEGRO_PIXEL_FORMAT_RGBA_8888 );
    void* bg_bitmap = al_create_bitmap( num_cols, num_rows );
    if ( !bg_bitmap ) {
        OutputDebugStringA("draw_textmode_buffers: ERROR - Failed to create bitmap\n");
        return 1; // Failed to create bitmap
    }
    
    // Lock bitmap for direct pixel access
    ALLEGRO_LOCKED_REGION* lock = ( ALLEGRO_LOCKED_REGION* )al_lock_bitmap( bg_bitmap, ALLEGRO_PIXEL_FORMAT_RGBA_8888, ALLEGRO_LOCK_WRITEONLY );
    if ( lock ) {
        uint8_t* bitmap_pixels = ( uint8_t* )lock->data;
        int pitch_bytes = lock->pitch;
        
        // Fill background bitmap - one pixel per character cell
        for ( int row = 0; row < num_rows; row++ ) {
            uint8_t* bitmap_row_ptr = bitmap_pixels + row * pitch_bytes;
            for ( int col = 0; col < num_cols; col++ ) {
                uint32_t bg_color = bg_array[row * num_cols + col];
                uint32_t* pixel_ptr = ( uint32_t* )( bitmap_row_ptr + col * 4 );
                *pixel_ptr = bg_color; // Direct copy
            }
        }
        
        al_unlock_bitmap( bg_bitmap );
    }
    
    // Draw background bitmap scaled up to full size
    int bitmap_width = num_cols * char_width;
    int bitmap_height = num_rows * (char_height + line_spacing);
    al_draw_scaled_bitmap( bg_bitmap, 0, 0, num_cols, num_rows, x, y, bitmap_width, bitmap_height, 0 );
    
    // Clean up background bitmap
    al_destroy_bitmap( bg_bitmap );
    
    // Draw foreground text
    al_hold_bitmap_drawing( 1 );
    for ( int row = 0; row < num_rows; row++ ) {
        for ( int col = 0; col < num_cols; col++ ) {
            int index = row * num_cols + col;
            uint8_t character = char_array[index];
            uint32_t fg_color = fg_array[index];
            
            if ( character != 0 ) { // Don't draw null characters
                float r, g, b, a;
                unpack_rgba( fg_color, &r, &g, &b, &a );
                
                float glyph_x = x + col * char_width;
                float glyph_y = y + row * (char_height + line_spacing) + (line_spacing / 2);
                
                al_draw_glyph( font, r, g, b, a, glyph_x, glyph_y, character );
            }
        }
    }
    al_hold_bitmap_drawing( 0 );
    
    OutputDebugStringA("draw_textmode_buffers: SUCCESS - Rendering completed\n");
    return 0; // Success
}

// DLL entry point
BOOL WINAPI DllMain( HINSTANCE hinstDLL, DWORD fdwReason, LPVOID lpvReserved ) {
    switch ( fdwReason ) {
        case DLL_PROCESS_DETACH:
            if ( allegro_dll ) {
                FreeLibrary( allegro_dll );
                allegro_dll = NULL;
            }
            break;
    }
    return TRUE;
}