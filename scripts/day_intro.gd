class_name DayIntro
extends Control
## 日开场：打卡上班、领取当日规则手册（新条款逐日加码）。

signal finished

var day := 1
var endless := false


func setup(params: Dictionary) -> void:
	day = params.get("day", 1)
	endless = params.get("endless", false)


func _ready() -> void:
	var bg := UIU.panel(UIU.COL_BG)
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(bg)

	# 日期牌
	var head := UIU.panel(Color("232820"), Color("565e4e"), 1, 4)
	head.position = Vector2(140, 70)
	head.size = Vector2(1000, 86)
	add_child(head)
	var h1_txt := ("加班 · 第 %d 夜 ｜ 规则全部叠加 ｜ 外加一条新规" % day) if endless else ("第 %d 天 ｜ %s ｜ Anthrotzka 边境检查站" % [day, Rules.day_date(day)])
	var h1 := UIU.label(h1_txt, 26 if not endless else 24, UIU.COL_TEXT_LIGHT)
	h1.position = Vector2(28, 12)
	head.add_child(h1)
	var h2_txt := String(Game.tonight_rule.get("text", "今夜没有新规。（这本身就是个问题）")) if endless else Rules.day_headline(day)
	var h2 := UIU.label(h2_txt, 16, UIU.COL_YELLOW)
	h2.position = Vector2(28, 52)
	head.add_child(h2)

	# 规则手册页
	var book := UIU.panel(UIU.COL_PAPER, Color("8a8060"), 2, 3)
	book.position = Vector2(190, 180)
	book.size = Vector2(900, 440)
	add_child(book)

	var title := UIU.label("— 今夜规则手册 · 全量摘录 —" if endless else "— 当日规则手册 · 摘录 —", 15, UIU.COL_INK)
	title.position = Vector2(30, 14)
	book.add_child(title)

	var scroll := ScrollContainer.new()
	scroll.position = Vector2(26, 44)
	scroll.size = Vector2(848, 380)
	book.add_child(scroll)
	var list := VBoxContainer.new()
	list.add_theme_constant_override("separation", 12)
	list.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll.add_child(list)

	var endless_rules: Array = []
	if endless:
		endless_rules = [{"kind": "hand", "text": String(Game.tonight_rule.get("text", ""))}] + Rules.day_rules(99)
	for rule in (endless_rules if endless else Rules.day_rules(day)):
		var box := PanelContainer.new()
		match String(rule["kind"]):
			"hand":
				box.add_theme_stylebox_override("panel", UIU.sbox(Color(0.96, 0.9, 0.82, 0.5), Color("b3261e"), 1, 2))
			"note":
				box.add_theme_stylebox_override("panel", UIU.sbox(Color(0.9, 0.9, 0.86, 0.4), Color("7a7f72"), 1, 2))
			"strike":
				box.add_theme_stylebox_override("panel", UIU.sbox(Color(0.82, 0.8, 0.72, 0.6), Color("555"), 1, 2))
			_:
				box.add_theme_stylebox_override("panel", UIU.sbox(Color(1, 1, 1, 0.35)))
		var use_kai := String(rule["kind"]) in ["hand", "note"]
		var txt: String = rule["text"]
		if rule["kind"] == "strike":
			txt = "[s]" + txt + "[/s]"
		elif rule["kind"] == "hand":
			txt = "[color=#b3261e]" + txt + "[/color]"
		elif rule["kind"] == "note":
			txt = "[color=#5a5f52]" + txt + "[/color]"
		else:
			txt = "[color=#2b2f6f]" + txt + "[/color]"
		var rl := UIU.rich(txt, 16 if rule["kind"] == "print" else 15, UIU.COL_TEXT, use_kai)
		if rule["kind"] == "hand":
			rl.rotation_degrees = -0.8
		box.add_child(rl)
		list.add_child(box)

	Game.take_shot("intro")
	if Game.test_mode:
		await Game.wait(0.05)
		finished.emit()
		return

	var btn := UIU.button("继续加班 →", 20 if endless else 20, func():
		Sfx.play("page")
		finished.emit()
	, Color("3e5a3a"))
	btn.custom_minimum_size = Vector2(320, 54)
	btn.position = Vector2(480, 648)
	add_child(btn)
	Sfx.play("page", -10.0)
