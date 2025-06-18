extends Container

@onready var gameLabel = $MainMenuTitle
var everythingReady = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	gameLabel.text = "GYRO PER MINUTE"
	gameLabel.position = get_viewport().size / 2
	everythingReady = true
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_resized() -> void:
	if everythingReady:
		gameLabel.position = get_viewport().size / 2
