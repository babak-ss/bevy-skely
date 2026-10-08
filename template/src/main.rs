mod app;
#[cfg(feature = "dev")]
mod dev;

use bevy::prelude::*;
use bevy::window::WindowResolution;

fn main() -> AppExit {
    let mut app = App::new();
    app.add_plugins(DefaultPlugins.set(WindowPlugin {
        primary_window: Some(Window {
            title: env!("CARGO_PKG_NAME").into(),
            // Fixed logical size + scale 1.0 => 1280x720 PNGs on any display.
            resolution: WindowResolution::new(1280, 720).with_scale_factor_override(1.0),
            ..default()
        }),
        ..default()
    }))
    .add_plugins(app::AppPlugin);

    #[cfg(feature = "dev")]
    app.add_plugins(dev::DevPlugin);

    app.run()
}
