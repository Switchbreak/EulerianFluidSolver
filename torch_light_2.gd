extends OmniLight3D

const MAX_VALUE = 10000000

@onready var noise := FastNoiseLite.new()

var value: float

func _ready() -> void:
    randomize()
    value = (randi() % MAX_VALUE)


func _physics_process(delta: float) -> void:
    value += 50 * delta
    if value > MAX_VALUE:
        value = 0.0

    var alpha := (noise.get_noise_1d(value) + 1.0) * 20.0 + 0.5
    self.light_energy = alpha
