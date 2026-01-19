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
    // IMPORTANT: When you add an image, use `just clean` before recompiling so that the Rust compiler takes the new image into account.
    let eadkp_logo = eadkp::Image::from_raw(eadkp::include_image!("eadkp_logo_64_max.png")).expect("Failed to load eadkp logo image");

    // Initial keyboard state
    let mut prev = eadkp::input::KeyboardState::scan();

    loop {
        let now = eadkp::input::KeyboardState::scan(); // Scan the current keyboard state
        let just = now.get_just_pressed(prev); // Get keys that were just pressed
        if just.key_down(eadkp::input::Key::Back) { break 0; }; // Exit if Back key is pressed

        // Clear the screen to white
        eadkp::display::wait_for_vblank(); // Wait for VBlank before updating the display
        eadkp::display::push_rect_uniform(eadkp::SCREEN_RECT, eadkp::COLOR_WHITE); // Fill the entire screen with white


        // DISPLAY EADKP LOGO

        let height_center = (eadkp::SCREEN_RECT.height as f32 / 2.5) as u16;

        let image_position = eadkp::Point {
            x: eadkp::SCREEN_RECT.width / 2 - eadkp_logo.width / 2,
            y: height_center - eadkp_logo.height / 2,
        };

        // Draw the loaded image at position (50, 50)
        eadkp::display::push_image(&eadkp_logo, image_position);


        // DISPLAY TITLE TEXT
        
        let title_text = "Eadkp Template";
        let title_text_len = (title_text.len() * (eadkp::LARGE_FONT.width as usize)) as u16;

        let title_position = eadkp::Point {
            x: eadkp::SCREEN_RECT.width / 2 - (title_text_len / 2),
            y: height_center + (eadkp_logo.height / 2) + 20 - (eadkp::LARGE_FONT.height / 2),
        };

        eadkp::display::draw_string(
            title_text,
            title_position,
            true,
            eadkp::COLOR_BLACK,
            eadkp::COLOR_WHITE
        );
        

        // Update previous keyboard state
        prev = now;
    }
}