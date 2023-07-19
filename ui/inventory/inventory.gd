extends Control

const SLOT := preload("res://ui/inventory/slot.tscn")
const RECIPES := preload("res://items/recipes.tres")

@onready var items: GridContainer = %Items
@onready var tooltip: Control = %Tooltip
@onready var recipe_items := %RecipeItems
@onready var recipes := %Recipes
@onready var craft_button := %Craft
@onready var crafting_menu := %CraftingMenu
@onready var inventory_ui := %Inventory

var open := false
var selected_recipe: CraftingRecipe
var selected := -1
var is_crafting_menu_open := false

func _ready() -> void:
	craft_button.hide()
	
	Inventory.data.connect("items_changed", _on_items_changed)
	_on_items_changed(null)

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("inventory") and \
	(not GameManager.is_gui_open or open):
		open = not open
		GameManager.is_gui_open = open
	
	if open:
		scale = scale.move_toward(Vector2.ONE, 12 * delta)
	else:
		scale = scale.move_toward(Vector2.ZERO, 24 * delta)
	
	if is_crafting_menu_open:
		inventory_ui.hide()
		crafting_menu.show()
	else:
		inventory_ui.show()
		crafting_menu.hide()

func _update_crafting_recipes() -> void:
	Utils.free_children(recipes)
	var can_craft := false
	for i in RECIPES.recipes:
		if not _can_craft(i):
			continue
		can_craft = true
		var button := Button.new()
		button.icon = i.creates.texture
		button.pressed.connect(_select_recipe.bind(i))
		button.custom_minimum_size = Vector2(16, 16)
		recipes.add_child(button)
	
	if not can_craft:
		var label = Label.new()
		label.text = "ui.inventory.no_recipes"
		recipes.add_child(label)
	
	if selected_recipe == null:
		return
	if not _can_craft(selected_recipe):
		selected_recipe = null
		craft_button.hide()
		Utils.free_children(recipe_items)	

func _select_recipe(recipe: CraftingRecipe) -> void:
	craft_button.show()
	
	selected_recipe = recipe
	Utils.free_children(recipe_items)
	
	var label := Label.new()
	label.text = "%s:" % tr(recipe.creates.get_item_name())
	label.vertical_alignment = VERTICAL_ALIGNMENT_BOTTOM
	recipe_items.add_child(label)
	
	for i in recipe.items:
		var texture := TextureRect.new()
		texture.texture = i.texture
		texture.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		recipe_items.add_child(texture)

func _can_craft(recipe) -> bool:
	var items = {}
	for i in recipe.items:
		if not items.has(i):
			items[i] = 0
		items[i] += 1
	
	# Verifying recipe can be made
	for i in items.keys():
		if Inventory.count_item(i) < items[i]:
			return false
	return true

func _craft() -> void:
	if selected_recipe == null:
		return
	var recipe := selected_recipe 
	for i in recipe.items:
		Inventory.remove_items(i, 1)
	Inventory.add_item(ItemState.new(recipe.creates))
	_update_crafting_recipes()

func _on_open_crafting_pressed() -> void:
	is_crafting_menu_open = not is_crafting_menu_open

func _on_items_changed(_item: ItemState) -> void:
	_update_crafting_recipes()
	
	Utils.free_children(items)
	
	for i in Inventory.get_inventory_snapshot():
		var slot := SLOT.instantiate()
		slot.item = i
		slot.connect("hover_updated", _on_slot_hover_update)
		items.add_child(slot)

func _on_slot_hover_update(slot: Control) -> void:
	selected = slot.get_index()
	if slot.item == null:
		tooltip.set_item(null)
		return
	tooltip.set_item(slot.item.item)
	if not slot.mouse_hovering:
		selected = -1
		tooltip.set_item(null)

func _unhandled_input(event: InputEvent) -> void: 
	if scale.is_zero_approx():
		return
	if event.is_action_pressed("move_item"):
		if Inventory.data.mouse_slot == null:
			Inventory.move_to_mouse_slot(selected)
			get_viewport().set_input_as_handled()
		elif selected == -1:
			var item = Item.create_drop_from(Inventory.data.mouse_slot)
			item.global_position = GameManager.player.global_position
			item.velocity = GameManager.player.global_position.direction_to(
				GameManager.player.get_global_mouse_position()) * 100
			GameManager.world.add_child(item)
			Inventory.data.mouse_slot = null
		else: 
			Inventory.drop_mouse_slot(selected)
			get_viewport().set_input_as_handled()
	elif event.is_action_pressed("drop_item") and Inventory.data.mouse_slot != null:
		var item = Item.create_drop_from(Inventory.data.mouse_slot)
		item.global_position = GameManager.player.global_position
		item.velocity = GameManager.player.global_position.direction_to(
			GameManager.player.get_global_mouse_position()) * 100
		GameManager.world.add_child(item)
		Inventory.data.mouse_slot = null
