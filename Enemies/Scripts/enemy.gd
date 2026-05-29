class_name Enemy extends CharacterBody2D

signal direction_changed( new_direction : Vector2)
signal enemy_damaged( hit_box : HitBox )
signal enemy_destroyed( hit_box : HitBox )

const DIR_4 = [ Vector2.RIGHT , Vector2.DOWN , Vector2.LEFT , Vector2.UP ]

@export var hp : int = 3

var cardinal_direction : Vector2 = Vector2.DOWN
var direction : Vector2 = Vector2.ZERO
var player : Player
var invulnerable : bool = false
var _is_defeated : bool = false

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var sprite_2d: Sprite2D = $Sprite2D
@onready var state_machine : EnemyStateMachine = $EnemyStateMachine
@onready var hurt_box: HurtBox = $HurtBox



# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if _load_state():
		return
	state_machine.initialize( self )
	player = PlayerManager.player 
	hurt_box.Damaged.connect( _take_damage )
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass
	

func _physics_process(_delta):
	if _is_defeated:
		return
	move_and_slide()
	_save_state()


func set_direction( _new_direction : Vector2 ) -> bool:
	direction = _new_direction
	if direction == Vector2.ZERO:
		return false
	
	var direction_id : int = int ( 
		round( direction + cardinal_direction * 0.1 ).angle() / TAU * DIR_4.size() ) 
	
	var new_dir = DIR_4[ direction_id ]
	
	if new_dir == cardinal_direction:
		return false
		
	cardinal_direction = new_dir
	direction_changed.emit( new_dir )
	sprite_2d.scale.x = -1 if cardinal_direction == Vector2.LEFT else 1
	return true
	
	
func update_animation( state : String ) -> void:
	animation_player.play(state + "_" + anim_direction())
	pass
	
func anim_direction() -> String:
	if cardinal_direction == Vector2.DOWN:
		return "down"
	elif cardinal_direction == Vector2.UP:
		return "up"
	else:
		return "side"


func _take_damage( hit_box : HitBox ) ->void:
	if invulnerable == true:
		return
	hp -= hit_box.damage
	if hp > 0:
		enemy_damaged.emit( hit_box )
	else:
		enemy_destroyed.emit( hit_box )


func mark_defeated() -> void:
	_is_defeated = true
	_save_state()


func _load_state() -> bool:
	var state := SaveManager.get_scene_node_state(self)
	if state.is_empty():
		return false
	if bool(state.get("defeated", false)):
		_is_defeated = true
		queue_free()
		return true
	hp = int(state.get("hp", hp))
	if state.has("pos_x") and state.has("pos_y"):
		global_position = Vector2(float(state.pos_x), float(state.pos_y))
	return false


func _save_state() -> void:
	if _is_defeated:
		SaveManager.set_scene_node_state(self, { defeated = true })
		return
	SaveManager.set_scene_node_state(self, {
		defeated = false,
		hp = hp,
		pos_x = global_position.x,
		pos_y = global_position.y
	})
