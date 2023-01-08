extends KinematicBody

onready var gun_controller = $GunController

#var speed = 0
var max_speed = 8
var velocity := Vector3()
var move_direction := Vector3()
const GRAVITY = 5
const ACCEL = 1
var falling_speed = 0

var ray_origin = Vector3()
var ray_end = Vector3()

var speed = 10
const ACCEL_DEFAULT = 10
const ACCEL_AIR = 1
onready var accel = ACCEL_DEFAULT
var gravity = 9.8
var jump = 10

var cam_accel = 40
var mouse_sense = 0.1
var snap

var angular_velocity = 30
var angular_acceleration = 7

var direction = Vector3()
#var velocity = Vector3()
var gravity_vec = Vector3()
var movement = Vector3()

onready var head = $Body
onready var mesh = $MeshInstance
onready var anim = get_node("Body/rimi/AnimationPlayer")

func _ready():
	#hides the cursor
	Globals.player = self
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	direction = Vector3.BACK.rotated(Vector3.UP, $Camroot/h.global_transform.basis.get_euler().y)
	# Sometimes in the level design you might need to rotate the Player object itself
	# So changing the direction at the beginning
	#mesh no longer inherits rotation of parent, allowing it to rotate freely
	mesh.set_as_toplevel(true)
	
func _input(event):
	#get mouse input for camera rotation
	if event is InputEventMouseMotion:
		rotate_y(deg2rad(-event.relative.x * mouse_sense))
		head.rotate_x(deg2rad(-event.relative.y * mouse_sense))
		head.rotation.x = clamp(head.rotation.x, deg2rad(-89), deg2rad(89))

func _physics_process(delta):
	#get keyboard input
	direction = Vector3.ZERO
	var h_rot = $Camroot/h.global_transform.basis.get_euler().y

	var f_input = Input.get_action_strength("w") - Input.get_action_strength("s")
	var h_input = Input.get_action_strength("a") - Input.get_action_strength("d")
	
	if f_input > 0:
		anim.play("walk forward-loop")
	direction = Vector3(h_input, 0, f_input).rotated(Vector3.UP, h_rot).normalized()
	direction = $Camroot/h.global_transform.basis.z
	
	#jumping and gravity
	if is_on_floor():
		snap = -get_floor_normal()
		accel = ACCEL_DEFAULT
		gravity_vec = Vector3.ZERO
	else:
		snap = Vector3.DOWN
		accel = ACCEL_AIR
		gravity_vec += Vector3.DOWN * gravity * delta
		
	if Input.is_action_just_pressed("jump") and is_on_floor():
		snap = Vector3.ZERO
		gravity_vec = Vector3.UP * jump
		anim.play("")
	#anim.play("Breathing Idle-loop")
	#make it move
	velocity = velocity.linear_interpolate(direction * speed, accel * delta)
	movement = velocity + gravity_vec
	
	move_and_slide_with_snap(movement, snap, Vector3.UP)
	$Body.rotation.y = lerp_angle($Body.rotation.y, $Camroot/h.rotation.y, delta * angular_acceleration)
	# Shoot shoot
	if Input.is_action_pressed("primary_action"):
		gun_controller.hold_trigger()
	else:
		gun_controller.release_trigger()
		
	# relaod
	if Input.is_action_just_pressed("reload"):
		gun_controller.reload()

func reset_position():
	global_transform.origin = Vector3(0, 3, 0)
	
func equip_item(ItemScene: PackedScene):
	var item = ItemScene.instance()
	
	# Handle different kinds of pickups:
	if item is Gun:
		gun_controller.equip_weapon(ItemScene)

func _on_Stats_you_died_signal():
	print("GAME OVER")
	queue_free()

func _on_Void_body_entered(body):
	print("AHHHHHHHHH!!!!!!!")
	queue_free()

func _on_Dropper_item_picked_up(ItemScene: PackedScene):
	equip_item(ItemScene)

func _on_WeaponSelector_weapon_selected(ItemScene: PackedScene):
	equip_item(ItemScene)
