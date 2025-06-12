extends Node3D

var LineDrawer = preload("res://DrawLine3D.gd").new()
var line_color : Color = Color(0, 255, 100)

@export var shootRayCast : RayCast3D

@onready var camera : Camera3D = self.get_parent().get_node("Camera3D")

var currentWeapon : Dictionary

var collisions : Array = []

var timeSinceLastShot : float = 0
var fireCooldown : float = 0 # cooldown after one shot (semi auto and burst)
var fireCooldownTimer : float = 0
var fireRate : float = 0 # shots per second (full auto and burst)
var fireRateDelay : float = 0 # delay time after shot (full auto and burst) (1 / fireRate) 
var fireRateTimer : float = 0

var firetype : String
var shootbehaviorlambda

var currentReserveAmmo : int = 0
var currentClipAmmo : int = 0
var maxClipAmmo : int = 0
var maxReserveAmmo : int = 0
var reloadTime : float = 0
var reloadWaitTimer : float = 0
var reloading : bool = false

var semiautolambda = func (delta):
	if Input.is_action_just_pressed("shoot") && fireCooldownTimer >= fireCooldown && currentClipAmmo > 0 && !reloading:
		shoot()
		currentClipAmmo -= 1
		fireCooldownTimer = 0
		print(camera.get_camera_forward())
	
	if fireCooldownTimer < fireCooldown: 
		fireCooldownTimer += delta

var fullautolambda = func (delta):
	if Input.is_action_pressed("shoot") && fireRateTimer >= fireRateDelay && currentClipAmmo > 0 && !reloading:
		shoot()
		currentClipAmmo -= 1
		fireRateTimer = 0
	
	if fireRateTimer < fireRateDelay: 
		fireRateTimer += delta

var burstlambda = func (delta):
	pass


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	add_child(LineDrawer)
	equipWeapon("fullautosmg")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	shootbehaviorlambda.call(delta)
	
	if (Input.is_action_just_pressed("reload") || currentClipAmmo == 0) && (reloadWaitTimer >= reloadTime):
		if !reloading:
			reloadWaitTimer = 0
		reloading = true

	
	if reloadWaitTimer < reloadTime: 
		reloadWaitTimer += delta
	elif reloading: # && reloadWaitTimer >= reloadTime
		reload()
		reloading = false
	
	for x in collisions:
		LineDrawer.DrawCube(x, 0.5, line_color)

func shoot():
	shootRayCast.global_position = camera.get_target_position()
	shootRayCast.target_position = camera.get_camera_forward() * currentWeapon.get("range")
	shootRayCast.force_raycast_update()
	
	if(shootRayCast.is_colliding()):
		LineDrawer.DrawCube(shootRayCast.get_collision_point(), 0.1, line_color, 1.5)


func reload():
	if currentReserveAmmo > 0:
		currentReserveAmmo -= abs(currentClipAmmo - maxClipAmmo)
		currentClipAmmo = min(maxClipAmmo, abs(maxReserveAmmo - currentReserveAmmo))


func equipWeapon(filename : String):
	currentWeapon = load("res://resources/weapons/%s.json" % [filename]).data
	if currentWeapon.get("shootcooldown") != null:
		fireCooldown = currentWeapon.get("shootcooldown")
		fireCooldownTimer = fireCooldown
	if currentWeapon.get("firetype") != null:
		firetype = currentWeapon.get("firetype")
		if firetype == "semiauto":
			shootbehaviorlambda = semiautolambda
		if firetype == "fullauto":
			shootbehaviorlambda = fullautolambda
		if firetype == "burst":
			shootbehaviorlambda = burstlambda
	if currentWeapon.get("firerate") != null:
		fireRate = currentWeapon.get("firerate")
		fireRateDelay = 1 / fireRate 
		fireRateTimer = fireRateDelay
	if currentWeapon.get("ammo") != null:
		maxClipAmmo = currentWeapon.get("ammo")
		currentClipAmmo = maxClipAmmo
	if currentWeapon.get("maxreserveammo") != null:
		maxReserveAmmo = currentWeapon.get("maxreserveammo")
		currentReserveAmmo = maxReserveAmmo
	if currentWeapon.get("reloadtime") != null:
		reloadTime = currentWeapon.get("reloadtime")
		reloadWaitTimer = reloadTime
