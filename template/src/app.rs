//! Application root. Register gameplay/app plugins here; keep dev tooling in `dev/`.

use bevy::prelude::*;

pub struct AppPlugin;

impl Plugin for AppPlugin {
    fn build(&self, _app: &mut App) {}
}
