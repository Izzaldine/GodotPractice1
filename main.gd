extends Node2D

@onready var player: Area2D = $Player
@onready var game_over_ui: Control = $UI/GameOverPanel
@onready var game_over_sound: AudioStreamPlayer = $GameOverSound

var is_game_over := false


func _ready() -> void:
	game_over_ui.hide()
	player.hit.connect(_on_player_hit)


func _unhandled_input(event: InputEvent) -> void:
	if is_game_over and event.is_action_pressed("ui_accept"):
		_restart_game()


func _on_player_hit() -> void:
	is_game_over = true
	game_over_ui.show()
	game_over_sound.play()


func _on_restart_button_pressed() -> void:
	_restart_game()


func _restart_game() -> void:
	get_tree().reload_current_scene()
