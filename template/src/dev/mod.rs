//! Development-only tooling. Compiled only with the `dev` feature (on by default).
//! Disable for shipping: `cargo build --release --no-default-features`.

use bevy::prelude::*;

pub struct DevPlugin;

impl Plugin for DevPlugin {
    fn build(&self, app: &mut App) {
        // Adds RemotePlugin + HTTP transport on 127.0.0.1:15702 (override: BRP_EXTRAS_PORT)
        // plus brp_extras/* methods: screenshot, send_keys, mouse, diagnostics, shutdown.
        app.add_plugins(bevy_brp_extras::BrpExtrasPlugin);

        #[cfg(feature = "agent-feedback")]
        app.add_plugins(feedback::plugin);
    }
}

#[cfg(feature = "agent-feedback")]
mod feedback {
    use bevy::prelude::*;
    use bevy_agent_feedback_plugin::{
        AgentFeedbackConfig, AgentFeedbackDiagnosticsPlugin, AgentFeedbackPlugin,
    };

    pub fn plugin(app: &mut App) {
        let env_path = |var: &str, default: &str| {
            std::env::var_os(var).map_or_else(|| default.into(), Into::into)
        };
        app.add_plugins(AgentFeedbackPlugin::new(AgentFeedbackConfig {
            bind_addr: std::net::SocketAddr::from(([127, 0, 0, 1], 0)),
            protocol_file: env_path(
                "BEVY_FEEDBACK_PROTOCOL",
                "target/agent-feedback/agent-feedback.json",
            ),
            capture_dir: env_path(
                "BEVY_FEEDBACK_CAPTURE_DIR",
                "target/agent-feedback/captures",
            ),
            // Freezes virtual/fixed time between `advance_time` requests.
            deterministic_time: std::env::var_os("BEVY_FEEDBACK_REALTIME").is_none(),
            ..Default::default()
        }));
        // Register app states/markers/resource fields here for semantic waits, e.g.
        // AgentFeedbackDiagnosticsPlugin::default().with_state::<AppState>()
        app.add_plugins(AgentFeedbackDiagnosticsPlugin::default());
    }
}
