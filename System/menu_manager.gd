extends Node
class_name MenuManager

var current_menu: Node = null
var menu_stack: Array[Node] = []

var main_menu: PackedScene = preload("res://System/Menus/MainMenu.tscn")

func Setup():
	pass

func clean():
	if current_menu:
		current_menu.queue_free()
		current_menu = null

func open_main_menu():
	push_menu(main_menu.instantiate())

func push_menu(menu: Node):
	if current_menu:
		current_menu.queue_free()
	current_menu = menu
	add_child(current_menu)

func pop_menu():
	if menu_stack.size() > 0:
		var prev_menu = menu_stack.pop_back()
		if current_menu:
			current_menu.queue_free()
		current_menu = prev_menu
		add_child(current_menu)
