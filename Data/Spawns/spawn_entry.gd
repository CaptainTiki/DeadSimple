# res://data/spawns/Spawn_Entry.gd
@icon("res://Assets/Spawn_Icon.svg")
extends Resource
class_name SpawnEntry


enum EntryStyle { NONE, SLIDE_ONLY, SLIDE_PAUSE }
enum Behavior { NONE, RAM_PLAYER }

@export var spawner_name: StringName            # e.g. "RightHigh"
@export var delay_s: float = 0.0                # wait before this spawn
@export var scene: PackedScene                  # Rock.tscn (or enemy later)
@export var entry_style: EntryStyle = EntryStyle.SLIDE_ONLY
@export var behavior: Behavior = Behavior.NONE
@export var speed: float = 6.0                  # optional param for movers
 
