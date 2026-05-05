class_name State_Walk extends State

@export var move_speed : float = 100.0
@onready var idle: State_Idle = $"../Idle"
@onready var charge_attack: State_ChargeAttack = $"../ChargeAttack"


## What happens when the player enters this State
func enter() -> void:
	player.update_animation("walk")
	pass

## What happens when the player exits this State
func exit() -> void:
	pass
	
## What heppens during the process update in the State
func process(_delta : float) -> State:
	if player.direction == Vector2.ZERO:
		return idle
		
	player.velocity = player.direction*move_speed
	
	if player.set_direction():
		player.update_animation("walk")
		
	return null
	
## What happens during the _physics_process update in the State
func physics( _delta : float) -> State:
	return null
	
## What happens whit input events in this State
func handle_input( _event : InputEvent) -> State:
	if _event.is_action_pressed("attack"):
		return charge_attack
	if _event.is_action_pressed("interact"):
		PlayerManager.interact_pressed.emit()
	return null
