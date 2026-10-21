
extends Node2D

const SPEED := 210.0
const MAX_HP := 100
const MAX_STAMINA := 100

var player_pos := Vector2.ZERO
var enemy_pos := Vector2.ZERO
var move_dir := Vector2.ZERO

var hp := MAX_HP
var stamina := MAX_STAMINA
var enemy_hp := 100

var attack_timer := 0.0
var enemy_timer := 0.0
var message := "Знайди шлях крізь темряву"

var ui: Control
var hud: Label
var buttons: Dictionary = {}

func _ready() -> void:
    ui = Control.new()
    ui.set_anchors_and_offsets_preset(
        Control.PRESET_FULL_RECT
    )
    add_child(ui)

    var size := get_viewport_rect().size
    player_pos = size * Vector2(0.38, 0.48)
    enemy_pos = size * Vector2(0.72, 0.48)

    hud = Label.new()
    hud.position = Vector2(18, 12)
    hud.add_theme_font_size_override("font_size", 18)
    ui.add_child(hud)

    _add_move("Вгору", "↑", Vector2(0, -1))
    _add_move("Вліво", "←", Vector2(-1, 0))
    _add_move("Вниз", "↓", Vector2(0, 1))
    _add_move("Вправо", "→", Vector2(1, 0))

    _add_button("Атака", "attack")
    _add_button("Знову", "restart")

    _layout_ui()
    get_viewport().size_changed.connect(_layout_ui)
    _update_hud()

func _add_move(
    key: String,
    caption: String,
    direction: Vector2
) -> void:
    var button := Button.new()
    button.text = caption
    button.custom_minimum_size = Vector2(58, 58)
    ui.add_child(button)
    buttons[key] = button

    button.button_down.connect(
        func():
            move_dir += direction
    )
    button.button_up.connect(
        func():
            move_dir -= direction
    )

func _add_button(caption: String, key: String) -> void:
    var button := Button.new()
    button.text = caption
    button.custom_minimum_size = Vector2(86, 58)
    ui.add_child(button)
    buttons[key] = button

    if key == "attack":
        button.pressed.connect(_attack)
    else:
        button.pressed.connect(_restart)

func _layout_ui() -> void:
    var size := get_viewport_rect().size

    buttons["Вгору"].position = Vector2(64, size.y - 190)
    buttons["Вліво"].position = Vector2(8, size.y - 126)
    buttons["Вниз"].position = Vector2(64, size.y - 126)
    buttons["Вправо"].position = Vector2(120, size.y - 126)

    buttons["attack"].position = Vector2(size.x - 104, size.y - 88)
    buttons["restart"].position = Vector2(size.x - 112, 12)

func _process(delta: float) -> void:
    if hp <= 0 or enemy_hp <= 0:
        return

    attack_timer = maxf(0.0, attack_timer - delta)
    enemy_timer -= delta

    var size := get_viewport_rect().size
    player_pos += move_dir.normalized() * SPEED * delta
    player_pos.x = clampf(player_pos.x, 35, size.x - 35)
    player_pos.y = clampf(player_pos.y, 35, size.y - 35)

    var distance := player_pos.distance_to(enemy_pos)

    if distance > 58:
        enemy_pos += (
            player_pos - enemy_pos
        ).normalized() * 65.0 * delta
    elif enemy_timer <= 0.0:
        hp = maxi(0, hp - 8)
        enemy_timer = 1.1

    if hp <= 0:
        message = "Ти впав. Спробуй ще раз!"
    elif enemy_hp <= 0:
        message = "Перемога! Ворог переможений."

    _update_hud()
    queue_redraw()

func _attack() -> void:
    if hp <= 0 or enemy_hp <= 0:
        return
    if attack_timer > 0.0 or stamina < 20:
        return

    stamina -= 20
    attack_timer = 0.6

    if player_pos.distance_to(enemy_pos) < 145:
        enemy_hp = maxi(0, enemy_hp - 25)

    if enemy_hp <= 0:
        message = "Перемога! Ворог переможений."

    _update_hud()
    queue_redraw()

func _update_hud() -> void:
    if hud == null:
        return

    hud.text = (
        "Здоров'я: %d/%d\n" % [hp, MAX_HP]
        + "Витривалість: %d/%d\n" % [stamina, MAX_STAMINA]
        + "Ворог: %d/100\n" % enemy_hp
        + message
    )

func _restart() -> void:
    var size := get_viewport_rect().size

    player_pos = size * Vector2(0.38, 0.48)
    enemy_pos = size * Vector2(0.72, 0.48)

    hp = MAX_HP
    stamina = MAX_STAMINA
    enemy_hp = 100
    attack_timer = 0.0
    enemy_timer = 0.0
    move_dir = Vector2.ZERO
    message = "Знайди шлях крізь темряву"

    _update_hud()
    queue_redraw()

func _draw() -> void:
    var size := get_viewport_rect().size

    draw_rect(
        Rect2(Vector2.ZERO, size),
        Color("#11121a")
    )

    draw_rect(
        Rect2(Vector2(24, 24), size - Vector2(48, 48)),
        Color("#292936"),
        false,
        5.0
    )

    for x in range(48, int(size.x) - 24, 48):
        draw_line(
            Vector2(x, 24),
            Vector2(x, size.y - 24),
            Color("#353442"),
            1.0
        )

    for y in range(48, int(size.y) - 24, 48):
        draw_line(
            Vector2(24, y),
            Vector2(size.x - 24, y),
            Color("#353442"),
            1.0
        )

    draw_circle(enemy_pos, 24, Color("#b64c50"))
    draw_circle(enemy_pos, 10, Color("#e6a4a0"))

    draw_circle(player_pos, 20, Color("#719bd5"))
    draw_circle(player_pos, 8, Color("#c5ddff"))

    draw_arc(
        player_pos,
        29,
        0.0,
        TAU,
        48,
        Color("#8bb5ef"),
        2.0
    )
