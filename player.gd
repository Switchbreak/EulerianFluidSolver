extends CharacterBody3D

@export var speed: float = 50

func _physics_process(_delta: float) -> void:
    var camera := get_viewport().get_camera_3d()
    var direction = Vector3.ZERO

    if Input.is_key_pressed(KEY_RIGHT):
        direction += camera.global_transform.basis.x
    if Input.is_key_pressed(KEY_LEFT):
        direction -= camera.global_transform.basis.x
    if Input.is_key_pressed(KEY_UP):
        direction -= camera.global_transform.basis.z
    if Input.is_key_pressed(KEY_DOWN):
        direction += camera.global_transform.basis.z

    direction.y = 0

    if direction != Vector3.ZERO:
        direction = direction.normalized()
        var dest := Quaternion(Basis.looking_at(direction))
        quaternion = quaternion.slerp(dest, 0.2)

        $GDbotSkin.walk()
    else:
        $GDbotSkin.idle()

    velocity = direction * speed
    move_and_slide()

    var dir_from_origin := Vector2(position.x, position.z).normalized() * 50
    var destination := Vector3(dir_from_origin.x, camera.position.y, dir_from_origin.y)
    var distance := camera.position.distance_to(destination)

    camera.position = camera.position.lerp(destination, clamp(0.8 / distance, 0, 1))
    camera.look_at(Vector3.ZERO)
