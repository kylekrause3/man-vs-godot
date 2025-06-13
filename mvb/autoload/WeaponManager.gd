extends Node
class_name WeaponManager

var weapons: Dictionary = {}

func _ready():
	loadAllWeapons()
	print(weapons)
	
func getWeapon(key: String) -> Weapon:
	return weapons.get(key)

func loadAllWeapons():
	weapons.clear()
	loadWeapons("res://resources/weapons/")
	
func loadWeapons(json_directory: String) -> void:
	var dir = DirAccess.open(json_directory)
	if dir == null:
		push_warning("No weapon folder found.")
		return
	
	dir.list_dir_begin()
	var file = dir.get_next()
	while file != "":
		if file.ends_with(".json"):
			var path = json_directory + file
			var weapon: Weapon = load_weapon_from_json(path)
			weapons[weapon.name] = weapon
		file = dir.get_next()
	dir.list_dir_end()

func load_weapon_from_json(json_path: String) -> Weapon:
	var data = load(json_path).data
	if !data:
		push_error("Failed to parse JSON: %s" % json_path)
		return null

	var errors = []
	var name = data.get("name")
	var weapon_class_val = data.get("weaponClass")
	var fire_type_val = data.get("fireType")
	var round_type_val = data.get("roundType")

	var model_path = data.get("modelPath", "")
	var model_scale = data.get("modelScale", 1.0)

	var shoot_sfx_path = data.get("shootSFXPath", "")
	var reload_sfx_path = data.get("reloadSFXPath", "")

	var damage = data.get("damage")
	var range = data.get("range")
	var accuracy = data.get("accuracy")
	var recoil = data.get("recoil")
	var shoot_cooldown = data.get("shootCooldown")
	var fire_rate = data.get("fireRate")
	var ammo = data.get("ammo")
	var max_reserve_ammo = data.get("maxReserveAmmo")
	var reload_time = data.get("reloadTime")

	if name == null:
		errors.append("Missing required field: name")
	if weapon_class_val == null:
		errors.append("Missing required field: weaponClass")
	if fire_type_val == null:
		errors.append("Missing required field: fireType")

	var weapon_class = null
	if weapon_class_val != null:
		weapon_class = Weapon.WeaponClassType.get(weapon_class_val)
		if weapon_class == null:
			errors.append("Invalid weaponClass value: %s" % weapon_class_val)

	var fire_type = null
	if fire_type_val != null:
		fire_type = Weapon.FireType.get(fire_type_val)
		if fire_type == null:
			errors.append("Invalid fireType value: %s" % fire_type_val)
			
	var round_type = null
	if round_type_val != null:
		round_type = Weapon.RoundType.get(round_type_val)
		if round_type == null:
			errors.append("Invalid fireType value: %s" % round_type_val)

	var numeric_fields = {
		"damage": damage,
		"range": range,
		"accuracy": accuracy,
		"recoil": recoil,
		"shootCooldown": shoot_cooldown,
		"fireRate": fire_rate,
		"ammo": ammo,
		"maxReserveAmmo": max_reserve_ammo,
		"reloadTime": reload_time,
	}

	for key in numeric_fields.keys():
		if numeric_fields[key] == null:
			errors.append("Missing required numeric field: %s" % key)

	if errors.size() > 0:
		for err in errors:
			push_error(err)
		return null

	var weapon: Weapon = Weapon.new()
	weapon.name = name
	weapon.weaponClass = weapon_class
	weapon.fireType = fire_type
	weapon.roundType = round_type

	weapon.modelPath = model_path
	weapon.modelScale = model_scale

	weapon.shootSFXPath = shoot_sfx_path
	weapon.reloadSFXPath = reload_sfx_path

	weapon.damage = float(damage)
	weapon.range = float(range)
	weapon.accuracy = float(accuracy)
	weapon.recoil = float(recoil)
	weapon.shootCooldown = float(shoot_cooldown)
	weapon.ammo = int(ammo)
	weapon.maxReserveAmmo = int(max_reserve_ammo)
	weapon.reloadTime = float(reload_time)
	weapon.fireRate = fire_rate

	return weapon
