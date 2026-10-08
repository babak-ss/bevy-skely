import json
import bevy_feedback
from bevy_feedback import BevyFeedbackClient, fail

def main(game: BevyFeedbackClient) -> None:
    first = game.wait_until_first_capture()
    if not game.deterministic_time:
        fail("expected deterministic time")
    before = game.read_resource_field("InputProbe", "keys_pressed")
    game.key_tap("KeyA")
    game.wait_for_resource("InputProbe", "keys_pressed", "gt", before, max_frames=60)
    a = game.capture_after_frames(1, label="before_advance")
    b = game.capture_after_frames(5, label="frozen")  # frames pass, time frozen -> identical
    game.advance_time(0.5, step_seconds=1/60)
    c = game.capture_after_frames(1, label="after_advance")
    same = open(a, "rb").read() == open(b, "rb").read()
    changed = open(a, "rb").read() != open(c, "rb").read()
    print(json.dumps({"first": str(first), "keys_before": before,
        "keys_after": game.read_resource_field("InputProbe", "keys_pressed"),
        "frozen_identical": same, "advance_changed": changed,
        "window": game.window_info(), "c": str(c)}))
    if not (same and changed):
        fail("determinism check failed")

bevy_feedback.run(main)
