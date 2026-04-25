@tool
@icon("res://npc/icons/npc.svg")
class_name NPC extends CharacterBody2D


signal do_behaviour_enabled

var state : String = "idle"
var direction : Vector2 = Vector2.DOWN
var do_behaviour : bool = true
var direction_name : String = "down"

@export var npc_resource : NPCResource :set = _set_npc_resource

@onready var animation: AnimationPlayer = $AnimationPlayer
@onready var sprite: Sprite2D = $Sprite2D

func _ready() -> void:
	setup_npc()
	if Engine.is_editor_hint():
		return
	gather_interactables()
	do_behaviour_enabled.emit()
	pass
	
	
	
	

func _physics_process(delta: float) -> void:
	move_and_slide()
	

func gather_interactables() -> void:
	for c in get_children():
		if c is DialogueInteraction:
			if not c.area_entered.is_connected( _on_dialogue_area_entered ):
				c.area_entered.connect( _on_dialogue_area_entered )
			if not c.player_interacted.is_connected( _on_player_interacted ):
				c.player_interacted.connect( _on_player_interacted )
			if not c.finished.is_connected( _on_interaction_finished ):
				c.finished.connect( _on_interaction_finished )


func _on_dialogue_area_entered( a : Area2D ) -> void:
	if (a.collision_layer & 4) == 0:
		return
	if PlayerManager.player == null:
		return
	update_direction( PlayerManager.player.global_position )
	update_animation()

func _on_player_interacted() -> void:
	update_direction( PlayerManager.player.global_position )
	state = "idle"
	velocity = Vector2.ZERO
	update_animation()
	do_behaviour = false
	pass

func _on_interaction_finished() -> void:
	state= "idle"
	update_animation()
	do_behaviour = true
	do_behaviour_enabled.emit()
	pass

func update_animation() -> void:
	animation.play(state + "_" + direction_name )


func update_direction( target_position : Vector2 ) -> void:
	direction = global_position.direction_to( target_position )
	
	update_direction_name()
	if direction_name == "side" and direction.x < 0:
		sprite.flip_h = true
	else:
		sprite.flip_h = false
	
	
func update_direction_name() -> void:
	var threshold : float = 0.45
	if direction.y < -threshold:
		direction_name = "up"
	elif direction.y > threshold:
		direction_name = "down"
	elif direction.x > threshold || direction.x < -threshold:
		direction_name = "side"

func setup_npc() -> void:
	if npc_resource:
		if sprite:
			sprite.texture = npc_resource.sprite
	pass

func _set_npc_resource( _npc : NPCResource) -> void:
	npc_resource = _npc
	setup_npc()
