extends CharacterBody3D

@onready var parent_scene = $"../.."
@onready var player = $"../../Player"
@onready var particle_scene: PackedScene = load("res://particle_explosion.tscn")

@export var speed: float = 100


func initialize(start_position: Vector3, direction: Vector3) -> void:
    position = start_position
    rotation = direction

    velocity = (Vector3.FORWARD * speed).rotated(Vector3.UP, rotation.y)


func _physics_process(delta: float) -> void:
    var collision := move_and_collide(velocity * delta)

    if collision:
        parent_scene.explosions.append(position)

        var particle_explosion: GPUParticles3D = particle_scene.instantiate()
        particle_explosion.position = position
        parent_scene.add_child(particle_explosion)
        particle_explosion.restart()

        player.camera_shake = 2.0

        queue_free()
