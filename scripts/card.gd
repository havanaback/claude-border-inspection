class_name EntryCard
extends Control
## 设备入境卡：字段随规则逐日增多；放大镜悬停可揭示隐藏细节；盖章后留下印记。

signal field_hover(note: String, global_pos: Vector2)

const LABELS := {
	"name": "姓　名", "nationality": "声称国籍", "ip": "IP 地址", "region_claim": "卡片归属地",
	"device": "设备型号", "reason": "入境事由", "tz": "系统时区", "lang": "系统语言",
	"ime": "默认输入法", "pay": "支付方式", "bin": "卡 BIN 段", "api": "网络配置(API)",
	"employer": "雇　主", "org": "所属组织",
}
const ORDER := ["name", "nationality", "ip", "region_claim", "device", "reason",
	"tz", "lang", "ime", "pay", "bin", "api", "employer", "org"]

const CARD_W := 500.0

var traveler := {}
var day := 1
var mag_on := false:
	set(v):
		mag_on = v
		_refresh_hints()
var stamp_text := ""
var stamp_col := Color.RED

var _photo: Portrait
var _value_labels: Array[Label] = []
var _field_keys: Array[String] = []


func setup(t: Dictionary, p_day: int) -> void:
	traveler = t
	day = p_day
	_build()


func _visible_fields() -> Array[String]:
	var keys: Array[String] = ["name", "nationality", "ip", "region_claim", "device", "reason"]
	if day >= 2:
		keys += ["tz", "lang", "ime"]
	if day >= 4:
		keys += ["pay", "bin"]
	if day >= 5:
		keys.append("api")
	if day >= 6:
		keys.append("employer")
	if day >= 7:
		keys.append("org")
	return keys


func _build() -> void:
	for c in get_children():
		c.queue_free()
	_value_labels.clear()
	_field_keys.clear()

	var keys := _visible_fields()
	var rows := int(ceil(keys.size() / 2.0))
	var h := 96.0 + rows * 24.0
	custom_minimum_size = Vector2(CARD_W, h)
	size = Vector2(CARD_W, h)

	var head := UIU.label("设备入境卡 · DEVICE ENTRY CARD", 14, UIU.COL_INK)
	head.position = Vector2(90, 7)
	add_child(head)
	var no := UIU.label("No.%d-%04d · Anthrotzka 边检" % [day, int(traveler.get("_no", 1))], 11, UIU.COL_GREY)
	no.position = Vector2(90, 26)
	add_child(no)

	_photo = Portrait.new()
	_photo.set_look(traveler.get("look", {}))
	_photo.set_expression(traveler.get("expr", "calm"))
	_photo.scale = Vector2(0.32, 0.32)
	_photo.position = Vector2(38, 92)
	add_child(_photo)

	# 两列字段：photo 右侧开始
	for i in keys.size():
		var k := keys[i]
		var col := i % 2
		var row := i / 2
		var lx := 76.0 if col == 0 else 292.0
		var ly := 48.0 + row * 24.0
		if row == 0:
			ly = 48.0
		var lab := UIU.label(LABELS[k] + "：", 11, UIU.COL_GREY)
		lab.position = Vector2(lx, ly)
		add_child(lab)
		var val := UIU.label(str(traveler.get("name", "—") if k == "name" else traveler["fields"].get(k, "—")), 12, UIU.COL_TEXT)
		val.position = Vector2(lx + 70, ly - 1)
		val.size = Vector2(140, 20)
		val.mouse_filter = Control.MOUSE_FILTER_STOP
		add_child(val)
		var note := str(traveler.get("hidden", {}).get(k, ""))
		if note != "":
			val.mouse_entered.connect(func():
				if mag_on:
					field_hover.emit(note, val.get_global_rect().get_center())
			)
		_value_labels.append(val)
		_field_keys.append(k)

	var deco := _Barcode.new()
	deco.position = Vector2(80, h - 16)
	deco.size = Vector2(150, 9)
	add_child(deco)
	_refresh_hints()


func _refresh_hints() -> void:
	var suspicious := ["bin", "api", "pay", "tz"]
	for i in _value_labels.size():
		var has_note: bool = traveler.get("hidden", {}).has(_field_keys[i])
		if mag_on and has_note:
			_value_labels[i].add_theme_color_override("font_color", Color("8a5a00"))
		elif mag_on and _field_keys[i] in suspicious:
			_value_labels[i].add_theme_color_override("font_color", Color("4a4a6a"))
		else:
			_value_labels[i].add_theme_color_override("font_color", UIU.COL_TEXT)


func set_expression(e: String) -> void:
	if _photo != null:
		_photo.set_expression(e)


func stamp(kind: String) -> void:
	match kind:
		"approve":
			stamp_text = "准 予"
			stamp_col = Color(0.2, 0.45, 0.2, 0.85)
		"deny":
			stamp_text = "拒 绝"
			stamp_col = Color(0.75, 0.2, 0.12, 0.85)
		"detain":
			stamp_text = "拘 留"
			stamp_col = Color(0.75, 0.6, 0.1, 0.85)
	queue_redraw()


func _draw() -> void:
	draw_rect(Rect2(Vector2.ZERO, size), UIU.COL_PAPER)
	draw_rect(Rect2(Vector2(2, 2), size - Vector2(4, 4)), Color(0.75, 0.7, 0.55), false, 2.0)
	draw_rect(Rect2(Vector2(84, 6), Vector2(size.x - 92, 34)), Color(0.88, 0.84, 0.7))
	draw_line(Vector2(8, 42), Vector2(size.x - 8, 42), Color(0.75, 0.7, 0.55), 1.5)
	draw_circle(Vector2(14, 22), 3.0, Color(0.5, 0.47, 0.4))
	if stamp_text != "":
		var center := size / 2.0 + Vector2(0, 14)
		draw_set_transform(center, deg_to_rad(-14.0), Vector2(1.6, 1.6))
		var f := UIU.font()
		var w := f.get_string_size(stamp_text, HORIZONTAL_ALIGNMENT_CENTER, -1, 24).x
		draw_string(f, Vector2(-w / 2.0, 8), stamp_text, HORIZONTAL_ALIGNMENT_LEFT, -1, 24, stamp_col)
		draw_rect(Rect2(Vector2(-w / 2.0 - 10, -12), Vector2(w + 20, 30)), stamp_col, false, 3.0)
		draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)


class _Barcode extends Node2D:
	var size := Vector2(150.0, 9.0)

	func _draw() -> void:
		var x := 0.0
		var i := 0
		while x < size.x:
			var w := 1.0 + fmod(float(i * 7.0), 3.0)
			if i % 2 == 0:
				draw_rect(Rect2(x, 0, w, size.y), Color(0.2, 0.2, 0.2))
			x += w + 2.0
			i += 1
