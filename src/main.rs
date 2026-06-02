//! Template application for the eadkp HAL.
//! 
//! This file serves as a starting point for no_std embedded applications
//! targeting the NWA environment. It demonstrates:
//!   - Display rendering (rectangles, strings)
//!   - Keyboard input handling (edge detection via just-pressed state)
//!   - A basic main loop with VBlank synchronization

// Use no_std when compiling for embedded target (target_os = "none").
// When compiling for the host (e.g. for tests), std is available normally.
#![cfg_attr(target_os = "none", no_std)]
#![no_main]

// Pull in the alloc crate for heap-allocated types (String, format!, Vec, ...).
// The heap is made available by calling _eadk_init_heap() at startup.
// use alloc::format; // !If you have a error about missing `format!`, uncomment this line to import it from alloc.

// Pull in the eadkp macro utilities (eadk_setup!, etc.)
#[macro_use]
extern crate eadkp;

// Configure the NWA environment: sets the application name and registers
// required metadata. Also defines _eadk_init_heap(), which must be called
// first in main() to enable the allocator.
eadk_setup!(name = "Your App");

#[unsafe(no_mangle)]
pub fn main() -> isize {
    // Initialize the heap allocator. Must be the very first call in main().
    // Without this, any heap allocation (String, Vec, format!, ...) will panic
    // or produce undefined behavior.
    _eadk_init_heap();


    // === Initial screen setup

    // Fill the entire screen with white.
    eadkp::display::push_rect_uniform(eadkp::SCREEN_RECT, eadkp::COLOR_WHITE);

    
    // ------------------------------------------------------------------------- {

    // Draw a static title at the top-left corner.
    // Parameters: text, position, large_font, text_color, background_color
    eadkp::display::draw_string(
        "Hello world!",
        eadkp::Point { x: 10, y: 10 },
        true,            // use large font
        eadkp::COLOR_BLACK,
        eadkp::COLOR_WHITE,
    );


    // === Application state

    let mut number: i32 = 0;

    // Flag: when true, the number display is redrawn on the next frame.
    // Set to true initially so the number is drawn on the first iteration.
    let mut actualize = true;

    // ------------------------------------------------------------------------- }


    // === Main loop

    // Keyboard state from the previous frame, used to compute just-pressed keys.
    let mut prev = eadkp::input::KeyboardState::scan();

    let mut running = true; // Application main loop flag. Set to false to exit.

    while running {
        // Scan the current keyboard state.
        let now = eadkp::input::KeyboardState::scan();

        // Compute which keys transitioned from released to pressed this frame.
        let just = now.get_just_pressed(prev);

        // Back key: exit the application.
        if just.key_down(eadkp::input::Key::Back) {
            running = false;
        }


        // ------------------------------------------------------------------------- {

        // Plus / Minus keys: increment or decrement the counter.
        if just.key_down(eadkp::input::Key::Plus) {
            number += 1;
            actualize = true;
        } else if just.key_down(eadkp::input::Key::Minus) {
            number -= 1;
            actualize = true;
        }

        // Wait for the vertical blank before pushing pixels to the screen.
        // This prevents tearing and keeps rendering in sync with the display.
        eadkp::display::wait_for_vblank();

        // Redraw the counter only when its value has changed.
        if actualize {
            // Clear the line where the number is displayed by overwriting it
            // with a white rectangle. The width is clamped to a multiple of the
            // font glyph width to avoid partial-character artifacts.
            eadkp::display::push_rect_uniform(
                eadkp::Rect {
                    x: 10,
                    y: 30,
                    width: eadkp::LARGE_FONT.width
                        * ((eadkp::SCREEN_RECT.width - 10) / eadkp::LARGE_FONT.width),
                    height: eadkp::LARGE_FONT.height,
                },
                eadkp::COLOR_WHITE,
            );

            // Choose colors based on the sign of the number:
            //   positive → black text on green background
            //   negative → white text on red background
            //   zero     → white text on gray background
            let text_color = if number > 0 {
                eadkp::COLOR_BLACK
            } else {
                eadkp::COLOR_WHITE
            };
            let bg_color = if number > 0 {
                eadkp::COLOR_GREEN
            } else if number < 0 {
                eadkp::COLOR_RED
            } else {
                eadkp::COLOR_GRAY
            };

            eadkp::display::draw_string(
                &format!("Number: {}", number),
                eadkp::Point { x: 10, y: 30 },
                true, // use large font
                text_color,
                bg_color,
            );

            actualize = false;
        }

        // ------------------------------------------------------------------------- }


        // Save the current keyboard state for just-pressed detection next frame.
        prev = now;
    }

    0
}