extends CharacterBody3D

const ACCEL_DEFAULT = 7
const ACCEL_AIR = 4

var speed = 10
var sprintspeed = 20
var appliedspeed;
var applied_acceleration;
var gravity = 20
var jumpstrength = 10

var snap : Vector3 = Vector3.ZERO
var gravity_vector : Vector3 = Vector3.ZERO

# Called when the node enters the scene tree for the first time.
func _ready():
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	var move_input : Vector2 = Input.get_vector("left","right","down","up")
	var dir : Vector3 = Vector3()
	dir += move_input.x * Vector3.RIGHT
	dir += move_input.y * Vector3.FORWARD
	dir = dir.rotated(Vector3(0, 1, 0), self.rotation.y).normalized()
	
	if is_on_floor():
		applied_acceleration = ACCEL_DEFAULT
		if Input.is_action_just_pressed("jump"):
			gravity_vector = Vector3.UP * jumpstrength
		else:
			gravity_vector = Vector3.ZERO
	else:
		applied_acceleration = ACCEL_AIR
		gravity_vector += Vector3.DOWN * gravity * delta
	
	appliedspeed = speed
	if Input.is_action_pressed("sprint"):
		appliedspeed = sprintspeed
	velocity = velocity.lerp(dir * appliedspeed, applied_acceleration * delta)
	velocity.y = gravity_vector.y
	
	
	if Input.is_action_just_pressed("teleport"):
		do_teleport(Vector3(0, 2, 0))
	
	# Move the character
	move_and_slide()


func do_teleport(new_position : Vector3) -> void:
	self.position = new_position


# rotate along y axis with camera
func change_cam_orientation(y_rot_amt : float) -> void: 
	self.rotate(Vector3(0,1,0), deg_to_rad(y_rot_amt))

