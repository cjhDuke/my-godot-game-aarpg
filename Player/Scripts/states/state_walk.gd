class_name State_Walk extends State

@export var move_speed : float = 100.0
@onready var idle: State_Idle = $"../Idle"
@onready var attack: State_Attack = $"../Attack"


## What happens when the player enters this State
func Enter() -> void:
	player.UpdateAnimation("walk")
	pass

## What happens when the player exits this State
func Exit() -> void:
	pass
	
## What heppens during the process update in the State
func Process(_delta : float) -> State:
	if player.direction == Vector2.ZERO:
		return idle
		
	player.velocity = player.direction*move_speed
	
	if player.SetDirection():
		player.UpdateAnimation("walk")
		
	return null
	
## What happens during the _physics_process update in the State
func Physics( _delta : float) -> State:
	return null
	
## What happens whit input events in this State
func HandleInput( _event : InputEvent) -> State:
	if _event.is_action_pressed("attack"):
		return attack
	if _event.is_action_pressed("interact"):
		PlayerManager.interact_pressed.emit()
	return null
