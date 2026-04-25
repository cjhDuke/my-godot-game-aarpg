class_name EnemyState extends Node

var enemy : Enemy
var state_machine : EnemyStateMachine

##Whate happens when we initialize this state?
func init() -> void:
	pass

## What happens when the player enters this State
func enter() -> void:
	pass

## What happens when the player exits this State
func exit() -> void:
	pass
	
## What heppens during the process update in the State
func process(_delta : float) -> EnemyState:
	return null
	
## What happens during the _physics_process update in the State
func physics( _delta : float) -> EnemyState:
	return null
