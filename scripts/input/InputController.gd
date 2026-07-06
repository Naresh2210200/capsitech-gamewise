class_name InputController
extends Node
# Only job here is: turn a keypress or swipe into a Direction and hand it
# off to GridManager. Doesn't touch grid state or rendering at all.
#
#   User Gesture -> InputController -> GridManager -> LevelView3D

@export var swipe_threshold: float = 50.0   # min drag distance before it counts as a real swipe

var _touch_start: Vector2 = Vector2.ZERO
var _touch_active: bool = false


func _unhandled_input(event: InputEvent) -> void:
	_handle_keyboard(event)
	_handle_touch(event)


# ---------------------------------------------------------------------------
# keyboard - mainly for testing in the editor
# ---------------------------------------------------------------------------

func _handle_keyboard(event: InputEvent) -> void:
	if not event is InputEventKey or not event.pressed or event.echo:
		return   # ignore key-up and held-key repeats

	var direction := _direction_for_keycode(event.keycode)
	if direction == -1:
		return   # not a movement key, nothing to do

	GridManager.try_move(direction)


# separated out so _handle_keyboard doesn't have the undo special-case
# mixed in with the movement match
func _direction_for_keycode(keycode: int) -> int:
	match keycode:
		KEY_UP, KEY_W:
			return GridManager.Direction.UP
		KEY_DOWN, KEY_S:
			return GridManager.Direction.DOWN
		KEY_LEFT, KEY_A:
			return GridManager.Direction.LEFT
		KEY_RIGHT, KEY_D:
			return GridManager.Direction.RIGHT
		KEY_Z:
			GridManager.undo()
			return -1   # handled here, not a movement direction
		_:
			return -1


# ---------------------------------------------------------------------------
# touch / swipe - this is the one that matters on an actual phone
# ---------------------------------------------------------------------------

func _handle_touch(event: InputEvent) -> void:
	if event is InputEventScreenTouch:
		_on_touch(event)
	elif event is InputEventScreenDrag and _touch_active:
		_on_drag(event)


func _on_touch(event: InputEventScreenTouch) -> void:
	if event.pressed:
		_touch_start = event.position
		_touch_active = true
	else:
		_touch_active = false   # finger lifted, reset for next swipe


func _on_drag(event: InputEventScreenDrag) -> void:
	var delta: Vector2 = event.position - _touch_start
	if delta.length() < swipe_threshold:
		return   # not far enough yet, keep waiting

	GridManager.try_move(_direction_for_drag(delta))
	_touch_active = false   # only want one move per swipe, not a move every frame


# whichever axis moved further decides the direction
func _direction_for_drag(delta: Vector2) -> int:
	if abs(delta.x) > abs(delta.y):
		return GridManager.Direction.RIGHT if delta.x > 0 else GridManager.Direction.LEFT
	else:
		return GridManager.Direction.DOWN if delta.y > 0 else GridManager.Direction.UP
