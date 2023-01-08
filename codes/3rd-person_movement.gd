extends KinematicBody

# ------------------------------------------------------------
# Use 'W', 'S' keys for move + 'Shift'/'Ctrl' to sprint/creep.
# For enter/exit view mode press 'Tab'.
# Script author: Warrpy
# -------------------------------------------------------------
onready var gun_controller = $GunController

var velocity = Vector3()
var direction = Vector3()
var speed = 10
var gravity = -14
var accelerating = false
var define_direction = false
var initial_speed = 10
var forward = false
var backward = false
var view_mode = false
var slowly = 0

# variables that can be edited in the Inspector tab.
export var acceleration = 0.01
export var deceleration = 0.05
export var max_speed = 10
export var angle_ease = 5

var jump = false
var fall = false
var creep = false
var sprint = false

var boost = 0

onready var axis = get_parent().get_node("Axis")
onready var animator = $"atomic-robot/AnimationPlayer"

# ------------------------------------------------------------------
# Robot 3D model from Atomic Game Engine examples, author Bartheinz.
# ------------------------------------------------------------------
onready var anim = get_node("Body/rimi/AnimationPlayer")

func _physics_process(delta):
	direction = Vector3()
	var pres = 0
	
	if Input.is_action_pressed("a"):
		pres = 1
		direction.x = 1
		if not jump and not fall and not sprint:
			animator.play_backwards("Walking")
			anim.play("walk right-loop")
			
	if Input.is_action_pressed("d"):
		pres = 1
		direction.x = -1
		if not jump and not fall and not sprint:
			animator.play_backwards("Walking")
			anim.play("walk right-loop")
			
	if Input.is_action_pressed("w"):
		pres = 1
		forward = true
		direction.z = 1
		define_direction = true
		
		# walking animation control block.
		if not jump and not fall and not sprint and not creep:
			animator.play("Walking", 0.2)
			anim.play("walk forward-loop")
	else:
		forward = false
		# default pose.
		if not jump and not fall and not backward:
			animator.play("Default", 0.3) 
	if Input.is_action_pressed("s"):
		pres = 1
		backward = true
		direction.z = -1
		define_direction = false
		# walking backwards.
		if not jump and not fall and not sprint:
			animator.play_backwards("Walking")
			anim.play("walk backward-loop")
	else:
		backward = false		
	if pres == 0:
		anim.play("idle-loop")
		speed = 0
	else:
		speed = max_speed
		
	
				
	if Input.is_action_pressed("sprint"):
		if forward and not jump and not fall:
			sprint = true
			boost = 1.4
			animator.play("Running", 0.3)
			if forward:
				anim.play("run forward-loop")
			elif backward:
				anim.play("run backward-loop")				
	else:
		sprint = false
		boost = 1
		
#	if Input.is_action_pressed("creep"):
#		if forward:
#			creep = true
#			animator.play("Creep", 0.3)
#	else:
#		creep = false
#	if Input.is_action_just_pressed("view_mode"):
#		if view_mode:
#			view_mode = false
#		else:
#			view_mode = true
		
	if pres == 1:
		if not view_mode:
			# smoothly rotates from one rotation to another.
			slowly = lerp_angle(rotation.y, axis.rotation.y, deg2rad(angle_ease))
			rotation.y = slowly
		# acceleration.
#		initial_speed = lerp(speed, max_speed, acceleration)
#		speed = initial_speed
	else:
		# determines where the movement was directed last,
		# forward or backward.
		if define_direction:
			direction.z = 1
		else:
			direction.z = -1
		# deceleration.
#		initial_speed = lerp(speed, 0, deceleration)
#		speed = initial_speed

#	slowly = lerp_angle(rotation.y, axis.rotation.y, deg2rad(angle_ease))
#	rotation.y = slowly
#	speed = max_speed
	
	direction = direction.normalized() 
	direction *= speed * boost
	
	# rotates the direction of movement depending on the rotation.
	# easier, body moves where it is directed/faced.
	direction = direction.rotated(Vector3(0, 1, 0), rotation.y)
	
	velocity.x = direction.x
	velocity.z = direction.z
	velocity.y += gravity * delta
	
	velocity = move_and_slide(velocity, Vector3.UP)
	
	# if all boolean values are false, the body is falling.
	if not is_on_floor() and not jump and not fall:
		fall = true
		animator.play("Fall")
	
	if is_on_floor() and fall:
		fall = false
	
	if is_on_floor() and jump:
		jump = false
	
	if is_on_floor() and Input.is_action_pressed("jump"):
		velocity.y = 10
		animator.play("Jump")
		anim.play("jump loop-loop")
		jump = true
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


func _on_Void_body_shape_entered(body_rid, body, body_shape_index, local_shape_index):
	pass # Replace with function body.


func _on_Stats_update_health():
	anim.play("Hit Reaction-loop")
	pass # Replace with function body.
