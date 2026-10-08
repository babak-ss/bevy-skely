//! DISPOSABLE validation scene for tooling tests only.

use bevy::prelude::*;

pub struct AppPlugin;

#[derive(Resource, Reflect, Default)]
#[reflect(Resource)]
pub struct InputProbe {
    pub keys_pressed: u32,
    pub last_key: String,
    pub mouse_clicks: u32,
    pub cursor: Vec2,
}

#[derive(Component, Reflect, Default)]
#[reflect(Component)]
pub struct Spin;

impl Plugin for AppPlugin {
    fn build(&self, app: &mut App) {
        app.init_resource::<InputProbe>()
            .add_systems(Startup, setup)
            .add_systems(Update, (probe_input, spin));
    }
}

fn setup(
    mut commands: Commands,
    mut meshes: ResMut<Assets<Mesh>>,
    mut materials: ResMut<Assets<StandardMaterial>>,
) {
    commands.spawn((
        Name::new("TestCube"),
        Spin,
        Mesh3d(meshes.add(Cuboid::new(1.0, 1.0, 1.0))),
        MeshMaterial3d(materials.add(StandardMaterial {
            base_color: Color::srgb(0.9, 0.3, 0.2),
            ..default()
        })),
    ));
    commands.spawn((
        Name::new("MainCamera"),
        Camera3d::default(),
        Transform::from_xyz(0.0, 2.0, 4.0).looking_at(Vec3::ZERO, Vec3::Y),
    ));
    commands.spawn((
        Name::new("Sun"),
        DirectionalLight::default(),
        Transform::from_xyz(2.0, 4.0, 2.0).looking_at(Vec3::ZERO, Vec3::Y),
    ));
}

fn probe_input(
    keys: Res<ButtonInput<KeyCode>>,
    mouse: Res<ButtonInput<MouseButton>>,
    windows: Query<&Window>,
    mut probe: ResMut<InputProbe>,
) {
    for key in keys.get_just_pressed() {
        probe.keys_pressed += 1;
        probe.last_key = format!("{key:?}");
    }
    probe.mouse_clicks += mouse.get_just_pressed().count() as u32;
    if let Some(pos) = windows.iter().next().and_then(Window::cursor_position) {
        probe.cursor = pos;
    }
}

fn spin(time: Res<Time>, mut q: Query<&mut Transform, With<Spin>>) {
    for mut t in &mut q {
        t.rotate_y(time.delta_secs());
    }
}
