class_name Portrait
extends Node2D
## 程序化像素头像：发型/肤色/眼镜/胡子/军帽 + 表情与微表情动画。

var u := 7.0
var look := {
	"skin": Color("d9a679"), "hair": Color("3a2a1c"), "hair_style": 0,
	"beard": false, "glasses": false, "hat": "", "female": false,
	"clothes": Color("5a5f52"), "earring": false,
}
var expr := {
	"eyes": "open", "brow": 0, "mouth": "flat", "pupil": 1.0,
	"pupil_dx": 0, "sweat": false,
}

var micro_twitch := false
var _t := 0.0
var _twitch_phase := 0.0


func set_look(lk: Dictionary) -> void:
	for k in lk:
		look[k] = lk[k]
	queue_redraw()


func set_expression(name: String) -> void:
	var presets := {
		"calm": {"eyes": "open", "brow": 0, "mouth": "flat"},
		"innocent": {"eyes": "wide", "brow": 1, "mouth": "smile"},
		"nervous": {"eyes": "open", "brow": -1, "mouth": "frown", "sweat": true},
		"shifty": {"eyes": "squint", "brow": -1, "mouth": "twitch", "pupil_dx": 1},
		"angry": {"eyes": "wide", "brow": -2, "mouth": "grit"},
		"shock": {"eyes": "wide", "brow": 2, "mouth": "open", "pupil": 1.9},
		"sad": {"eyes": "open", "brow": 1, "mouth": "frown"},
		"still": {"eyes": "open", "brow": 0, "mouth": "flat"},
		"smug": {"eyes": "squint", "brow": -1, "mouth": "smile"},
	}
	if presets.has(name):
		for k in presets[name]:
			expr[k] = presets[name][k]
	queue_redraw()


func set_micro(opts: Dictionary) -> void:
	for k in opts:
		expr[k] = opts[k]
	if opts.get("twitch", false):
		micro_twitch = true
		_twitch_phase = 0.0
	queue_redraw()


func _process(delta: float) -> void:
	_t += delta
	if micro_twitch:
		_twitch_phase += delta
	queue_redraw()


func _r(x: float, y: float, w: float, h: float, c: Color) -> void:
	draw_rect(Rect2(x * u, y * u, w * u, h * u), c)


func _draw() -> void:
	var skin: Color = look["skin"]
	var skin_d := skin.darkened(0.18)
	var hair: Color = look["hair"]
	var hair_d := hair.darkened(0.25)
	var bob := sin(_t * 2.2) * 1.5
	var tw := 0.0
	if micro_twitch:
		tw = 1.0 if fmod(_twitch_phase, 0.5) < 0.12 else 0.0

	draw_set_transform(Vector2(0, bob))
	# 躯干（画在头后面）
	var clothes: Color = look["clothes"]
	_r(-9.0, 10.0, 18.0, 10.0, clothes)
	_r(-11.0, 14.0, 22.0, 8.0, clothes.darkened(0.15))
	if String(look["hat"]) == "military":
		_r(-6.0, 10.0, 12.0, 4.0, Color("2f3a2a").lightened(0.08))  # 领口
		_r(-1.0, 11.5, 2.0, 8.0, Color("2f3a2a").lightened(0.08))
	# 耳朵
	_r(-8.0, -1.0, 1.0, 3.0, skin_d)
	_r(7.0, -1.0, 1.0, 3.0, skin_d)
	if look["earring"]:
		draw_circle(Vector2(-7.5 * u, 2.6 * u), 0.6 * u, Color("d8b13c"))
		draw_circle(Vector2(7.5 * u, 2.6 * u), 0.6 * u, Color("d8b13c"))
	# 脸
	_r(-7.0, -9.0, 14.0, 18.0, skin)
	_r(-6.0, 9.0, 12.0, 1.0, skin_d)   # 下颌阴影
	# 头发
	var style := int(look["hair_style"])
	match style:
		0:
			_r(-7.0, -9.0, 14.0, 3.5, hair)
			_r(-7.0, -6.0, 1.2, 4.0, hair)
			_r(5.8, -6.0, 1.2, 4.0, hair)
		1:
			_r(-7.0, -9.0, 14.0, 3.0, hair)
			_r(-7.0, -6.0, 4.5, 2.0, hair)
			_r(3.0, -8.0, 4.0, 3.5, hair_d)
		2:
			_r(-7.0, -9.0, 14.0, 3.5, hair)
			_r(-8.0, -9.0, 2.0, 20.0, hair)
			_r(6.0, -9.0, 2.0, 20.0, hair)
		3:
			_r(-7.0, -9.0, 3.0, 1.2, hair_d)
			_r(4.0, -9.0, 3.0, 1.2, hair_d)
		4:
			_r(-7.0, -9.0, 14.0, 3.0, hair)
			draw_circle(Vector2(0, -10.5 * u), 2.2 * u, hair)
	# 帽子
	if String(look["hat"]) == "military":
		_r(-8.0, -14.0, 16.0, 4.0, Color("3d4a33"))
		_r(-8.0, -10.5, 16.0, 1.8, Color("8a2f26"))
		_r(-8.0, -11.4, 11.0, 1.4, Color("20261b"))
		draw_circle(Vector2(0, -12.2 * u), 0.8 * u, Color("c9a227"))
	elif String(look["hat"]) == "beanie":
		_r(-7.5, -11.5, 15.0, 4.0, Color("5b4a63"))
		_r(-7.5, -8.2, 15.0, 1.2, Color("4a3c50"))
	# 眉毛（tilt: 负=怒·内侧压低，正=挑眉）
	var brow_t := int(expr["brow"])
	var brow_c := hair.darkened(0.1)
	var by := -5.2 + (0.3 if brow_t > 0 else 0.0)
	for s in [-1, 1]:
		var raise_y := -0.9 if brow_t == 2 else (-0.5 if brow_t == 1 else 0.0)
		var drop_y := (0.7 if brow_t == -1 else 1.3) if brow_t < 0 else 0.0
		if s == 1:
			_r(3.5, by + raise_y, 1.5, 1.0, brow_c)
			_r(2.0, by + raise_y + drop_y, 1.5, 1.0, brow_c)
		else:
			_r(-5.0, by + raise_y, 1.5, 1.0, brow_c)
			_r(-3.5, by + raise_y + drop_y, 1.5, 1.0, brow_c)
	# 眼睛
	var eyes: String = expr["eyes"]
	var pup: float = expr["pupil"]
	var pdx: int = expr["pupil_dx"]
	for s in [-1, 1]:
		var ex := 1.5 if s == 1 else -4.5
		if eyes == "closed":
			_r(ex, -2.0, 3.0, 0.6, skin_d)
			continue
		if eyes == "squint":
			_r(ex, -2.4, 3.0, 1.2, Color.WHITE)
			_r(ex + 1.0 + pdx, -2.4, 1.0, 1.2, Color("20221c"))
			continue
		var eh := 2.4 if eyes == "wide" else 2.0
		var ey := -3.0 if eyes == "wide" else -2.6
		_r(ex, ey, 3.0, eh, Color.WHITE)
		var pw := 1.0 * pup
		var px := ex + 1.5 - pw / 2.0 + pdx * 0.5 + tw * 0.4
		_r(px, ey + eh / 2.0 - pw / 2.0, pw, pw, Color("20221c"))
	# 鼻子
	_r(-0.5, -0.5, 1.0, 2.0, skin_d)
	_r(-1.2, 1.5, 2.4, 0.6, skin_d)
	# 嘴
	var mouth: String = expr["mouth"]
	var my := 4.8
	match mouth:
		"smile":
			_r(-2.0, my, 4.0, 0.8, Color("8a4a3f"))
			_r(-2.6, my - 0.8, 0.8, 0.8, Color("8a4a3f"))
			_r(1.8, my - 0.8, 0.8, 0.8, Color("8a4a3f"))
		"frown":
			_r(-2.0, my + 0.6, 4.0, 0.8, Color("8a4a3f"))
			_r(-2.6, my + 1.4, 0.8, 0.8, Color("8a4a3f"))
			_r(1.8, my + 1.4, 0.8, 0.8, Color("8a4a3f"))
		"open":
			_r(-1.5, my - 0.2, 3.0, 2.2, Color("6b2f2a"))
			_r(-1.5, my - 0.2, 3.0, 0.7, Color.WHITE)
		"twitch":
			_r(-2.0, my, 4.0, 0.8, Color("8a4a3f"))
			_r(1.4, my - 0.7 + tw * 0.5, 1.2, 0.8, Color("8a4a3f"))
		"grit":
			_r(-2.5, my - 0.4, 5.0, 1.6, Color.WHITE)
			_r(-2.5, my + 0.4, 5.0, 0.6, skin_d)
			for i in 4:
				_r(-2.0 + i * 1.2, my - 0.4, 0.25, 1.6, skin_d)
		_:
			_r(-2.0, my, 4.0, 0.8, Color("8a4a3f"))
	# 胡子
	if look["beard"]:
		_r(-4.5, 3.2, 9.0, 0.8, hair_d)
		_r(-4.5, 6.0, 9.0, 3.0, hair)
		_r(-2.5, 8.5, 5.0, 1.0, hair_d)
	# 眼镜
	if look["glasses"]:
		for s in [-1, 1]:
			var gx := 1.2 if s == 1 else -4.8
			draw_rect(Rect2(gx * u, -3.4 * u, 3.6 * u, 2.8 * u), Color(0.1, 0.1, 0.1, 0.55), false, 2.0)
		draw_line(Vector2(-1.2 * u, -2.0 * u), Vector2(1.2 * u, -2.0 * u), Color(0.1, 0.1, 0.1), 2.0)
	# 汗
	if expr["sweat"]:
		var sy := -7.0 + fmod(_t * 3.0, 2.0)
		draw_circle(Vector2(9.2 * u, sy * u), 1.0 * u, Color(0.65, 0.82, 0.95))
		draw_circle(Vector2(9.2 * u, (sy - 1.4) * u), 0.6 * u, Color(0.65, 0.82, 0.95))
	draw_set_transform(Vector2.ZERO)
