extends Node2D

@onready var projector: TextureRect = $Projector
@onready var projector_d: TextureRect = $Projector_DensityField
@onready var behavior_buffer := PackedFloat32Array()
@onready var explosion_image: Image = load("res://assets/Circle-Small.exr")

@export var cells_x: int = 256
@export var cells_y: int = 256
@export var overrelaxation: float = 1.0
@export var iterations: int = 10

var rd: RenderingDevice
var advection_shader: RID
var projection_shader: RID
var imageR: RID
var imageW: RID
var behavior: RID
var advection_uniform_set: RID
var projection_uniform_set: RID
var advection_pipeline: RID
var projection_pipeline: RID

var output_texture: Texture2D
var prev_pos := Vector2i(-1, -1)

func init_compute_shader() -> void:
    rd = RenderingServer.get_rendering_device()

    advection_shader = load_shader(rd, "res://shaders/Advection.glsl")
    projection_shader = load_shader(rd, "res://shaders/Projection.glsl")

    imageR = create_image(cells_x, cells_y)
    imageW = create_image(cells_x, cells_y)

    behavior_buffer.resize(4)
    behavior_buffer[0] = 0.0
    behavior = create_buffer_uniform(behavior_buffer.to_byte_array())

    var imageR_uniform := create_uniform(imageR, 0, RenderingDevice.UNIFORM_TYPE_IMAGE)
    var imageW_uniform := create_uniform(imageW, 1, RenderingDevice.UNIFORM_TYPE_IMAGE)
    var behavior_uniform := create_uniform(behavior, 2, RenderingDevice.UNIFORM_TYPE_UNIFORM_BUFFER)
    advection_uniform_set = rd.uniform_set_create([imageR_uniform, imageW_uniform, behavior_uniform], advection_shader, 0)
    projection_uniform_set = rd.uniform_set_create([imageR_uniform, behavior_uniform], projection_shader, 0)

    advection_pipeline = rd.compute_pipeline_create(advection_shader)
    projection_pipeline = rd.compute_pipeline_create(projection_shader)


func cleanup_compute_shader() -> void:
    output_texture.texture_rd_rid = RID()
    RenderingServer.call_on_render_thread(cleanup_compute_resources)


func cleanup_compute_resources() -> void:
    rd.free_rid(advection_pipeline)
    rd.free_rid(projection_pipeline)
    rd.free_rid(advection_uniform_set)
    rd.free_rid(projection_uniform_set)
    rd.free_rid(imageR)
    rd.free_rid(imageW)
    rd.free_rid(behavior)
    rd.free_rid(advection_shader)
    rd.free_rid(projection_shader)
    rd.free()


func load_shader(rendering_device: RenderingDevice, path: String) -> RID:
    var shader_file := load(path)
    var shader_spirv: RDShaderSPIRV = shader_file.get_spirv()
    return rendering_device.shader_create_from_spirv(shader_spirv)


func create_image(width: int, height: int) -> RID:
    var image_format := RDTextureFormat.new()

    image_format.format = RenderingDevice.DATA_FORMAT_R16G16B16A16_SFLOAT
    image_format.width = width
    image_format.height = height
    image_format.usage_bits = \
        RenderingDevice.TEXTURE_USAGE_SAMPLING_BIT + \
        RenderingDevice.TEXTURE_USAGE_COLOR_ATTACHMENT_BIT + \
        RenderingDevice.TEXTURE_USAGE_STORAGE_BIT + \
        RenderingDevice.TEXTURE_USAGE_CAN_UPDATE_BIT + \
        RenderingDevice.TEXTURE_USAGE_CAN_COPY_FROM_BIT + \
        RenderingDevice.TEXTURE_USAGE_CAN_COPY_TO_BIT

    return rd.texture_create(image_format, RDTextureView.new())


func create_uniform(resource: RID, binding: int, uniform_type: RenderingDevice.UniformType) -> RDUniform:
    var uniform := RDUniform.new()
    uniform.uniform_type = uniform_type
    uniform.binding = binding
    uniform.add_id(resource)

    return uniform


func create_buffer_uniform(bytes: PackedByteArray) -> RID:
    return rd.uniform_buffer_create(bytes.size(), bytes)


func update_uniform_values(uniform_rid: RID, bytes: PackedByteArray) -> void:
    rd.buffer_update(uniform_rid, 0, bytes.size(), bytes)


func dispatch_compute(pipeline: RID, uniform_set: RID, x_groups: int, y_groups: int, z_groups: int) -> void:
    var compute_list := rd.compute_list_begin()
    rd.compute_list_bind_compute_pipeline(compute_list, pipeline)
    rd.compute_list_bind_uniform_set(compute_list, uniform_set, 0)
    rd.compute_list_dispatch(compute_list, x_groups, y_groups, z_groups)
    rd.compute_list_end()

    rd.submit()
    rd.sync()


func update_image(clear:bool = false) -> void:
    var image_bytes := rd.texture_get_data(imageR, 0)
    var image := Image.create_from_data(cells_x, cells_y, false, Image.FORMAT_RGBAH, image_bytes)

    if clear:
        init_image(image)

    image.fill_rect(Rect2i(112, 107, 32, 43), Color(0, 0, 0, 0))

    if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT) || Input.is_mouse_button_pressed(MOUSE_BUTTON_RIGHT):
        var pos := Vector2i(projector_d.get_local_mouse_position())
        var vel := Vector2(pos - prev_pos) if prev_pos.x > 0 else Vector2.ZERO

        vel = vel.normalized() * 100.0;

        var alpha: float = 0.0 if Input.is_mouse_button_pressed(MOUSE_BUTTON_RIGHT) else 1.0

        if pos.x > 0 && pos.x < projector_d.size.x && pos.y > 0 && pos.y < projector_d.size.y:
            image.fill_rect(Rect2i(pos / 2, Vector2i(20, 20)), Color(vel.x, vel.y, alpha * 10.0, 1.0))
            if alpha == 0.0:
                image.fill_rect(Rect2i(prev_pos / 2, Vector2i(20, 20)), Color(vel.x, vel.y, 0.0, 1.0))
                image.fill_rect(Rect2i(pos / 2, Vector2i(20, 20)), Color(0, 0, 0.0, 0.0))

        prev_pos = pos

    if Input.is_key_pressed(KEY_SPACE):
        var pos := Vector2i(projector_d.get_local_mouse_position())
        if pos.x > 0 && pos.x < projector_d.size.x && pos.y > 0 && pos.y < projector_d.size.y:
            @warning_ignore("integer_division")
            image.blend_rect(explosion_image, Rect2i(0, 0, 40, 40), Vector2i(pos.x / 2 - 20, pos.y / 2 - 20))

    image_bytes = image.get_data()
    rd.texture_update(imageR, 0, image_bytes);


func init_image(image: Image) -> void:
    image.fill_rect(Rect2i(0, 0, cells_x, cells_y), Color(0.0, 0.0, 0.0, 0.0))
    #image.fill_rect(Rect2i(1, 1, cells_x - 2, cells_y - 2), Color(0.0, 0.0, 0.0, 1.0))

    var density_noise := FastNoiseLite.new()
    var velocity_x_noise := FastNoiseLite.new()
    var velocity_y_noise := FastNoiseLite.new()
    density_noise.seed = randi()
    velocity_x_noise.seed = randi()
    velocity_y_noise.seed = randi()

    for x: int in range(cells_x - 2):
        for y: int in range(cells_y - 2):
            image.set_pixel(x + 1, y + 1, Color(
                velocity_x_noise.get_noise_2d(x, y) * 100.0 - 5.0,
                velocity_y_noise.get_noise_2d(x, y) * 100.0 - 5.0,
                density_noise.get_noise_2d(x, y) * 5.0 + 5.0, 1.0))


func display_image() -> void:
    var output_bytes := rd.texture_get_data(imageW, 0)
    var output_image := Image.create_from_data(cells_x, cells_y, false, Image.FORMAT_RGBAH, output_bytes)
    var output_tex := ImageTexture.create_from_image(output_image)

    projector.texture = output_tex


func init_rd_texture() -> void:
    output_texture = Texture2DRD.new()

    output_texture.texture_rd_rid = imageW
    #output_texture.texture_rd_rid = imageR
    projector.texture = output_texture
    projector_d.texture = output_texture


func swap_textures() -> void:
    rd.texture_copy(imageW, imageR, Vector3(0, 0, 0), Vector3(0, 0, 0), Vector3(cells_x, cells_y, 0), 0, 0, 0, 0)


func init_compute_resources() -> void:
    init_compute_shader()
    init_rd_texture()
    update_image(true)


func process_compute(delta: float) -> void:
    behavior_buffer[0] = delta
    behavior_buffer[1] = overrelaxation
    behavior_buffer[2] = 0
    update_uniform_values(behavior, behavior_buffer.to_byte_array())

    dispatch_compute(advection_pipeline, advection_uniform_set, 127, 127, 1)
    swap_textures()

    for i: int in range(iterations):
        behavior_buffer[2] = 0
        update_uniform_values(behavior, behavior_buffer.to_byte_array())
        dispatch_compute(projection_pipeline, projection_uniform_set, 127, 254, 1)

        behavior_buffer[2] = 1
        update_uniform_values(behavior, behavior_buffer.to_byte_array())
        dispatch_compute(projection_pipeline, projection_uniform_set, 127, 254, 1)


func _ready() -> void:
    RenderingServer.call_on_render_thread(init_compute_resources)


func _process(delta: float) -> void:
    update_image()
    RenderingServer.call_on_render_thread(process_compute.bind(delta))


func _notification(what: int) -> void:
    if what == NOTIFICATION_PREDELETE:
        cleanup_compute_shader()
