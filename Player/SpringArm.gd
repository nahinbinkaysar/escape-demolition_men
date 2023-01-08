extends Spatial

func _ready():
	set_as_toplevel(true)
	#Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

var ms = 0.5

func _input(event):
	if event is InputEventMouseMotion:
		print("mouse")
		rotation_degrees.x -= event.relative.y * ms
		rotation_degrees.x = clamp(rotation_degrees.x, -90, 30)
		
		rotation_degrees.y -= event.relative.x * ms
		rotation_degrees.y = wrapf(rotation_degrees.y, 0, 360)
