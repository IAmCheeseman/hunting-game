extends Control

const TOOLTIP_ELEMENT := preload("res://ui/inventory/tooltip/tooltip_value.tscn")

var label_settings = {
	"melee_damage": Color.RED,
	"ranged_damage": Color.RED,
	"throwing_damage": Color.RED,
	"pierces": Color.GREEN,
	"stuns": Color.CORNFLOWER_BLUE,
	"element": Color.BEIGE,
	"ammo": Color.AQUAMARINE,
	"durability": Color.PALE_GREEN,
}

@onready var elements := %Elements
@onready var elements_margin := %Margin
@onready var panel := %Panel
@onready var item_name := %Name
@onready var item_rarity := %Rarity
@onready var item_description := %Description

var item: Item

func _ready() -> void:
	for i in label_settings.keys():
		var settings = LabelSettings.new()
		settings.font_color = label_settings[i]
		settings.font_size = 8
		label_settings[i] = settings

func _process(_delta: float) -> void:
	panel.size = elements_margin.size
	panel.global_position = global_position
	
	var target_position = get_global_mouse_position() + Vector2.ONE * 4
	target_position += panel.size
	if target_position.y > get_viewport_rect().end.y - 5:
		target_position.y = get_viewport_rect().end.y - 5
	if target_position.x > get_viewport_rect().end.x - 5:
		target_position.x  = get_viewport_rect().end.x - 5
	target_position -= panel.size
	
	global_position = target_position

func set_item(to: Item) -> void:
	item = to
	_update_tooltip()

func _create_tooltip_element(element: TooltipData) -> HBoxContainer:
	var tooltip_element := TOOLTIP_ELEMENT.instantiate()
	elements.add_child(tooltip_element)
	tooltip_element.label.text = tr("tooltip.%s" % element.id)
	tooltip_element.label.label_settings = label_settings[element.id]
	if element.value != "":
		tooltip_element.label.text += ":"
	
	tooltip_element.value.text = tr(element.value)
	if TranslationServer.get_locale() == "gb" and element.value != "":
		var characters = [ "S", "f", "e", "DA", "tr", "f", "B", "O" ]
		characters.shuffle()
		for i in randi_range(0, 3):
			characters.pop_back()
		var str = ""
		for i in characters:
			str += i
		tooltip_element.value.text = str
	return tooltip_element

func _update_tooltip() -> void:
	if item == null:
		visible = false
		return
	visible = true
	
	Utils.free_children(elements)
	
	item_name.text = item.get_item_name()
	item_rarity.text = item.get_rarity_string()
	item_description.text = item.get_description()
	for i in item.tooltip:
		_create_tooltip_element(i)

  
