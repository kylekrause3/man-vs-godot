extends Node
class_name HealthComponent
signal signalHealed()
signal signalDamaged()
signal signalZeroHealth()
signal signalFullHealth()

@export var max_health: float = 0.0
@export var current_health: float = 0.0
@export var regen_rate: float = 0.0 # health/second
@export var regen_cooldown: float = 0.0 # time to wait since last hit

var time_since_last_damage: float = 0.0

func _ready() -> void:
	current_health = max_health

func _physics_process(delta: float) -> void:
	if regen_rate <= 0.0:
		return
		
	time_since_last_damage += delta
	var should_regenerate: bool = (
		(current_health > 0.0) && 
		(current_health < max_health) && 
		(time_since_last_damage >= regen_cooldown)
	)
	
	if should_regenerate:
		var regen_amount = regen_rate * delta
		addHealth(regen_amount)

func addHealth(value: float) -> void:
	if value > 0:
		signalHealed.emit()
	
	self.current_health += value
	if self.current_health >= max_health:
		signalFullHealth.emit()
		self.current_health = max_health
		
func removeHealth(value: float) -> void:
	signalDamaged.emit()
	time_since_last_damage = 0.0
	
	self.current_health -= value
	if self.current_health <= 0.0:
		signalZeroHealth.emit()
		self.current_health = 0.0
		
func setHealth(value: float) -> void:
	self.current_health = value
	if self.current_health <= 0:
		signalZeroHealth.emit()
		self.current_health = 0
		
	elif self.current_health >= max_health:
		signalFullHealth.emit()
		self.current_health = max_health
		
func restoreHealthToFull() -> void:
	signalFullHealth.emit()
	self.current_health = max_health
