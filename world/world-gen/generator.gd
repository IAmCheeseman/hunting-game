extends Node2D
class_name WorldGenerator

static func get_gen_rect(from: CanvasItem) -> Rect2:
	var cam_size := from.get_viewport_rect().size
	var start_pos := GameManager.camera.global_position + cam_size / 2
	var pos = start_pos.snapped(cam_size) - cam_size
	return Rect2(pos, cam_size)

static func get_view_rect(from: CanvasItem) -> Rect2:
	var cam_size := from.get_viewport_rect().size
	var start_pos := GameManager.camera.global_position - cam_size / 2
	var size = cam_size * 3
	var pos = start_pos.snapped(cam_size) - cam_size
	return Rect2(pos, size)

var _props: Array[Node2D] = []
#TODO)) Add state deletion queue, so we can delete states if we have too many
var _prop_state := {}

func _generate_chunk(chunk_rect: Rect2) -> void:
	var chunk_pos: Vector2 = floor(chunk_rect.position / chunk_rect.size)
	var pos_hash := hash(chunk_pos) + GameManager.world_seed
	seed(pos_hash)
	
	var points := Props.COST_PER_CHUNK
	
	var seed_offset := 0
	
	while points > 0:
		var tries := 0
		var prop := Props.get_random()
		while tries < 20 and points - prop.cost < 0:
			prop = Props.get_random()
			tries += 1
		points -= prop.cost
		var count = prop.get_count.call(randf())
		
		for i in count:
			seed(pos_hash + seed_offset)
			var new_prop = prop.scene.instantiate()
			new_prop.position = (
				chunk_rect.position + chunk_rect.size * Vector2(randf(), randf())
			).round()
			new_prop.world_generator = self
			
			_props.append(new_prop)
			GameManager.world.add_child(new_prop)
			seed_offset += 1

func register_state(object: Node2D, index: int, state) -> void:
	if not _prop_state.has(hash(object.position)):
		_prop_state[hash(object.position)] = []
	var arr = _prop_state[hash(object.position)]
	for i in index - arr.size() + 1:
		arr.append(null)
	arr[index] = state

func get_state(object: Node2D, index: int, default):
	if not _prop_state.has(hash(object.position)):
		return default
	var arr = _prop_state[hash(object.position)]
	if index >= arr.size():
		return default
	return arr[index]

func generate() -> void:
	for i in _props:
		i.queue_free()
	_props.clear()
	
	var chunk_rect = WorldGenerator.get_gen_rect(self)
	
	var pos = chunk_rect.position
	var size = chunk_rect.size
	
	_generate_chunk(chunk_rect)
	
	_generate_chunk(Rect2( # TL
		pos.x - size.x, pos.y - size.y,
		size.x, size.y))
	_generate_chunk(Rect2( # BL
		pos.x - size.x, pos.y + size.y,
		size.x, size.y))
	_generate_chunk(Rect2( # TR
		pos.x + size.x, pos.y - size.y,
		size.x, size.y))
	_generate_chunk(Rect2( # BR
		pos.x + size.x, pos.y + size.y,
		size.x, size.y))
	_generate_chunk(Rect2( # T
		pos.x, pos.y - size.y,
		size.x, size.y))
	_generate_chunk(Rect2( # B
		pos.x, pos.y + size.y,
		size.x, size.y))
	_generate_chunk(Rect2( # R
		pos.x + size.x, pos.y,
		size.x, size.y))
	_generate_chunk(Rect2( # L
		pos.x - size.x, pos.y,
		size.x, size.y))
