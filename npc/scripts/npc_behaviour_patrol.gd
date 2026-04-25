@tool
extends NPCBehaviour

const COLORS = [Color(1, 0, 0), Color(1, 1, 0), Color(0, 1, 0),
	 Color(0, 1, 1), Color(0, 0, 1), Color(1, 0, 1)]


@export var walk_speed: float = 30.0

var patrol_loactions: Array[PatrolLocation]
var current_location_index: int = 0
var target: PatrolLocation
var is_handling_arrival: bool = false

var has_started: bool = false
var last_phase: String = ""
var direction: Vector2
@onready var timer: Timer = $Timer


func _ready() -> void:
	gather_patrol_locations()
	if Engine.is_editor_hint():
		child_entered_tree.connect(gather_patrol_locations)
		child_order_changed.connect(gather_patrol_locations)
		return
	pass
	super ()
	if patrol_loactions.size() == 0:
		process_mode = Node.PROCESS_MODE_DISABLED
		return
	target = patrol_loactions[0]


func _process(delta: float) -> void:
	if Engine.is_editor_hint():
		return
	if is_handling_arrival:
		return
	if target == null:
		return
	if npc.global_position.distance_to(target.target_position) < 1:
		start()

func gather_patrol_locations(_n: Node = null) -> void:
	patrol_loactions = []
	for c in get_children():
		if c is PatrolLocation:
			patrol_loactions.append(c)
			
	if Engine.is_editor_hint():
		if patrol_loactions.size() > 0:
			for i in patrol_loactions.size():
				var _p = patrol_loactions[i] as PatrolLocation
				
				if not _p.transform_changed.is_connected(gather_patrol_locations):
					_p.transform_changed.connect(gather_patrol_locations)
				
				_p.update_label(str(i))
				_p.modulate = _get_color_by_index(i)
				
				var _next: PatrolLocation
				if i < patrol_loactions.size() - 1:
					_next = patrol_loactions[i + 1]
				else:
					_next = patrol_loactions[0]
				_p.update_line(_next.position)
	pass


func start() -> void:
	if npc.do_behaviour == false or patrol_loactions.size() < 2:
		return
	if is_handling_arrival:
		return

	if has_started == false:
		has_started = true

	if npc.global_position.distance_to(target.target_position) >= 1.0:
		walk_phase()
		return

	is_handling_arrival = true
	idle_phase()
	return
	
	
func idle_phase() -> void:
	npc.global_position = target.target_position
	npc.state = "idle"
	npc.velocity = Vector2.ZERO
	npc.update_animation()
	
	var wait_time: float = target.wait_time
	
	if wait_time > 0:
		timer.start(wait_time)
		await timer.timeout
	#await get_tree().create_timer( wait_time ).timeout

	if npc.do_behaviour == false:
		has_started = false
		is_handling_arrival = false
		return

	current_location_index += 1
	if current_location_index >= patrol_loactions.size():
		current_location_index = 0

	target = patrol_loactions[current_location_index]
	
	walk_phase()
	pass
	
func walk_phase() -> void:
	npc.state = "walk"
	direction = npc.global_position.direction_to(target.target_position)
	npc.direction = direction
	npc.velocity = walk_speed * direction
	npc.update_direction(target.target_position)
	npc.update_animation()
	is_handling_arrival = false
	pass
	

func _get_color_by_index(i: int) -> Color:
	var color_count: int = COLORS.size()
	while i > color_count - 1:
		i -= color_count
	return COLORS[i]
