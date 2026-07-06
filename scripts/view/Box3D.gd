extends Node3D
# Goes on the root of the box scene. Just swaps the box's color when
# GridManager says it's sitting on a target. Doesn't read/write grid
# logic itself - LevelView3D tells it what to do via set_on_target().

@export var mesh_instance: MeshInstance3D
@export var default_color: Color = Color(0.85, 0.55, 0.25)   # tan/wood
@export var on_target_color: Color = Color(0.25, 0.85, 0.4)  # green

var _material: StandardMaterial3D


func _ready() -> void:
	if mesh_instance == null:
		mesh_instance = _find_first_mesh_instance(self)   # didn't get one assigned, go find it
	if mesh_instance:
		_material = StandardMaterial3D.new()
		_material.albedo_color = default_color
		mesh_instance.material_override = _material


func set_on_target(is_on_target: bool) -> void:
	if _material == null:
		return   # no mesh found in _ready, nothing to color
	_material.albedo_color = on_target_color if is_on_target else default_color


func _find_first_mesh_instance(node: Node) -> MeshInstance3D:
	if node is MeshInstance3D:
		return node
	for child in node.get_children():
		var found := _find_first_mesh_instance(child)
		if found:
			return found
	return null
