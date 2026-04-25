class_name State extends Node

## Stores a reference to the player that this State belongs to
static var player : Player
static var state_machine : PlayerStateMachine

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

## What happens when the player enters this State
func enter() -> void:
	pass

## What happens when the player exits this State
func exit() -> void:
	pass

## Optional one-time initialization hook called by PlayerStateMachine.initialize
func init() -> void:
	pass
	
## What heppens during the process update in the State
func process(_delta : float) -> State:
	return null
	
## What happens during the _physics_process update in the State
func physics( _delta : float) -> State:
	return null
	
## What happens whit input events in this State
func handle_input( _event : InputEvent) -> State:
	return null
