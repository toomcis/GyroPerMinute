extends Button


func _on_pressed() -> void:
	get_tree().change_scene_to_file("res://GameScene/Debug Scene/MainDebug.tscn")
