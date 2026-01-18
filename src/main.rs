#![cfg_attr(target_os = "none", no_std)]
#![no_main]

/*!
Simple base code including only the strict necessary using the eadkp library
and displaying "Hello, world!" on the screen.
*/

// Import the eadkp crate with macros
#[macro_use]
extern crate eadkp;

extern "C" {
    fn calculer_somme(a: i32, b: i32) -> i32;
}

// Setup the NWA environment.
eadk_setup!(name = "Eadkp template");

#[unsafe(no_mangle)]
pub fn main() -> isize {

    // Initialize the heap allocator
    _eadk_init_heap();

    // Initial keyboard state
    let mut prev = eadkp::input::KeyboardState::scan();

    loop {
        let now = eadkp::input::KeyboardState::scan(); // Scan the current keyboard state
        let just = now.get_just_pressed(prev); // Get keys that were just pressed
        if just.key_down(eadkp::input::Key::Back) { break 0; }; // Exit if Back key is pressed

        // Clear the screen to white
        eadkp::display::wait_for_vblank(); // Wait for VBlank before updating the display
        eadkp::display::push_rect_uniform(eadkp::SCREEN_RECT, eadkp::COLOR_WHITE); // Fill the entire screen with white

        // Draw "Hello, world!" at position (10, 10) with black text on white background
        eadkp::display::draw_string(
            "Hello, world!",
            eadkp::Point { x: 10, y: 10 },
            true,
            eadkp::COLOR_BLACK,
            eadkp::COLOR_WHITE
        );

        eadkp::display::draw_string(
            &format!("2 + 3 = {}", unsafe { calculer_somme(2, 3) }),
            eadkp::Point { x: 10, y: 30 },
            true,
            eadkp::COLOR_BLACK,
            eadkp::COLOR_WHITE
        )

        // Update previous keyboard state
        prev = now;
    }
}