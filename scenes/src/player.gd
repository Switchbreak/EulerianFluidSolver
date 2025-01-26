extends CharacterBody3D

@onready var bullets := $"../Bullets"

@export var speed: float = 50
@export var cooldown: float = 0.2
@export var bullet_scene: PackedScene

var fire_cooldown: bool = false
var camera_shake: float = 0.0

func _physics_process(delta: float) -> void:
    var camera := get_viewport().get_camera_3d()

    var direction := handle_input(camera)
    animate_player(direction)

    var vel := direction * speed
    velocity = Vector3(vel.x, velocity.y - 100.0 * delta, vel.z)

    move_and_slide()
    camera_follow(camera)


func handle_input(camera: Camera3D) -> Vector3:
    var direction = Vector3.ZERO

    if Input.is_key_pressed(KEY_RIGHT):
        direction += camera.global_transform.basis.x
    if Input.is_key_pressed(KEY_LEFT):
        direction -= camera.global_transform.basis.x
    if Input.is_key_pressed(KEY_UP):
        direction -= camera.global_transform.basis.z
    if Input.is_key_pressed(KEY_DOWN):
        direction += camera.global_transform.basis.z
    if Input.is_key_pressed(KEY_SPACE) && !fire_cooldown:
        spawn_bullet()

    direction.y = 0

    return direction.normalized()


func animate_player(direction: Vector3) -> void:
    if direction != Vector3.ZERO:
        var dest := Quaternion(Basis.looking_at(direction))
        quaternion = quaternion.slerp(dest, 0.2)

        $GDbotSkin.walk()
    else:
        $GDbotSkin.idle()


func shake_camera() -> Vector3:
    if camera_shake > 0:
        camera_shake = lerp(camera_shake, 0.0, 0.2)
    return Vector3(randf_range(-camera_shake, camera_shake), 0.0, randf_range(-camera_shake, camera_shake))


func camera_follow(camera: Camera3D) -> void:
    var dir_from_origin := Vector2(position.x, position.z).normalized() * 50
    var destination := Vector3(dir_from_origin.x, camera.position.y, dir_from_origin.y)
    var distance := camera.position.distance_to(destination)

    camera.position = camera.position.lerp(destination, clamp(0.8 / distance, 0, 1)) + shake_camera()
    camera.look_at(Vector3.ZERO)


func spawn_bullet() -> void:
    fire_cooldown = true
    wait_cooldown()

    var bullet = bullet_scene.instantiate()
    bullet.initialize(position, rotation)

    bullets.add_child(bullet)

    velocity = Vector3.FORWARD.rotated(Vector3.UP, rotation.y) * -100.0
    velocity.y = 15.0;
    move_and_slide()


func wait_cooldown() -> void:
    await get_tree().create_timer(cooldown).timeout
    fire_cooldown = false
