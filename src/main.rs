#![cfg_attr(target_os = "none", no_std)]
#![no_main]

/*!
Simple base code including only the strict necessary using the eadkp library
and displaying "Hello, world!" on the screen.
*/

// Import the eadkp crate with macros
#[macro_use]
extern crate eadkp;

// Setup the NWA environment.
eadk_setup!(name = "Eadkp template");

#[unsafe(no_mangle)]
pub fn main() -> isize {

    // Initialize the heap allocator
    _eadk_init_heap();

    // Load image
    let main_image = eadkp::Image::from_raw(eadkp::include_image!("bread.png")).expect("Failed to load main image");

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

        // Draw the loaded image at position (50, 50)
        eadkp::display::push_image(&main_image, eadkp::Point { x: 50, y: 50 });
        
        // Update previous keyboard state
        prev = now;
    }
}