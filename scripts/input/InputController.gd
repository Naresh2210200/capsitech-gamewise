class_name InputController  extends Node
## InputController
##
## Sole entry point for player input. Converts raw input events —
## keyboard (desktop/editor testing) or touch swipes (mobile) — into
## discrete Direction enum values and forwards them to GridManager.
##
## This node NEVER touches grid state directly and NEVER touches
## rendering. It only knows: "a gesture happened, ask GridManager if
## the move is legal." This is the first stage of the required pipeline:
##
##   User Gesture -> InputController -> GridManager -> LevelView3D

## Minimum swipe distance (pixels) before a touch drag counts as a swipe.
@export var swipe_threshold: float = 50.0

var _touch_start: Vector2 = Vector2.ZERO
var _touch_active: bool = false


func _unhandled_input(event: InputEvent) -> void:
	_handle_keyboard(event)
	_handle_touch(event)


# ---------------------------------------------------------------------------
# Keyboard (desktop / editor testing)
# ---------------------------------------------------------------------------

func _handle_keyboard(event: InputEvent) -> void:
	if not event is InputEventKey or not event.pressed or event.echo:
		return

	var direction: int = -1
	match event.keycode:
		KEY_UP, KEY_W:
			direction = GridManager.Direction.UP
		KEY_DOWN, KEY_S:
			direction = GridManager.Direction.DOWN
		KEY_LEFT, KEY_A:
			direction = GridManager.Direction.LEFT
		KEY_RIGHT, KEY_D:
			direction = GridManager.Direction.RIGHT
		KEY_Z:
			GridManager.undo()
			return
		_:
			return

	GridManager.try_move(direction)


# ---------------------------------------------------------------------------
# Touch / swipe (mobile)
# ---------------------------------------------------------------------------

func _handle_touch(event: InputEvent) -> void:
	if event is InputEventScreenTouch:
		if event.pressed:
			_touch_start = event.position
			_touch_active = true
		else:
			_touch_active = false

	elif event is InputEventScreenDrag and _touch_active:
		var delta: Vector2 = event.position - _touch_start
		if delta.length() < swipe_threshold:
			return

		var direction: int
		if abs(delta.x) > abs(delta.y):
			direction = GridManager.Direction.RIGHT if delta.x > 0 else GridManager.Direction.LEFT
		else:
			direction = GridManager.Direction.DOWN if delta.y > 0 else GridManager.Direction.UP

		GridManager.try_move(direction)
		_touch_active = false   # one discrete move per swipe, no repeat until re-touch
