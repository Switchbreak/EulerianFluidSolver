extends OmniLight3D

const MAX_VALUE = 10000000

@onready var noise := FastNoiseLite.new()

@export var flicker_amount: float = 50.0
@export var flicker_strength: float = 20.0

var value: float

func _ready() -> void:
    randomize()
    value = (randi() % MAX_VALUE)


func _physics_process(delta: float) -> void:
    value += flicker_amount * delta
    if value > MAX_VALUE:
        value = 0.0

    self.light_energy = (noise.get_noise_1d(value) + 1.0) * flicker_strength + 0.5
