class_name Booth
extends Control
## 检查台：主玩法。窗口旅客 + 设备入境卡 + 工具 + 印章 + 计时 + 判罚 + 暗号测谎。

signal finished

var day := 1
var gen := 0                # 代际令牌：任何旧协程链唤醒时发现代际已变即退出
var roster: Array = []
var idx := 0
var current: Dictionary = {}
var time_left := 60.0
var max_time := 60.0
var protested := false
var stamps_enabled := false
var query_region := ""
var code_state := ""        # "" / pending / answered_cn / answered_intl / no_code
var mag_on := false:
	set(v):
		mag_on = v
		if card != null:
			card.mag_on = v
		if mag_btn != null:
			mag_btn.button_pressed = v
var overlay: Control = null

var stats := {"judged": 0, "caught": 0, "missed": 0, "wrong_reject": 0, "wrong_basis": 0, "protested": 0}
var rejected_ids: Array = []

var backdrop: Node2D
var portrait: Portrait
var official: Portrait
var card: EntryCard
var bubble: PanelContainer
var bubble_text: Label
var official_line: Label
var verdict_line: Label
var aftermath_line: Label
var protest_label: Label
var quota_label: Label
var clock_label: Label
var hearts: Control
var timer_fill: ColorRect
var mag_btn: Button
var mag_popup: PanelContainer
var mag_popup_text: Label
var detain_btn: Button
var approve_btn: Button
var deny_btn: Button
var react_bar_fill: ColorRect
var react_bar: Panel
var hint_label: Label


var endless := false
var night_no := 0
var news_label: Label
var news_idx := 0


func setup(params: Dictionary) -> void:
	day = params.get("day", 1)
	endless = params.get("endless", false)
	night_no = params.get("night", 0)
	if endless:
		roster = params.get("roster", [])
	else:
		roster = Travelers.day_roster(day)
	for i in roster.size():
		roster[i]["_no"] = i + 1
	if endless:
		day = 99
	_build()
	Sfx.start_ambient()
	Sfx.play("steps", -8.0)
	if Game.shot == "booth_state":
		_shot_state()
	elif Game.shot == "terminal":
		_open_overlay("terminal")
		Game.take_shot("terminal")
	elif Game.shot == "fs_terminal":
		_fs_terminal_test()
	else:
		Game.take_shot("booth")
		_next_traveler()


# ============================================================ 布局

func _build() -> void:
	backdrop = _Backdrop.new()
	add_child(backdrop)

	# 顶栏
	var top := UIU.panel(Color("20241d"), Color("3a4034"), 0, 0)
	top.position = Vector2(0, 0)
	top.size = Vector2(1280, 40)
	add_child(top)

	var head_txt := ("加班 · 第 %d 夜" % night_no) if endless else ("第 %d 天 · %s" % [day, Rules.day_date(day)])
	var day_l := UIU.label(head_txt, 15, UIU.COL_TEXT_LIGHT)
	day_l.position = Vector2(14, 10)
	top.add_child(day_l)

	clock_label = UIU.label("08:00", 15, UIU.COL_TEXT_LIGHT)
	clock_label.position = Vector2(340, 10)
	top.add_child(clock_label)

	quota_label = UIU.label("剩余旅客 --", 15, UIU.COL_YELLOW)
	quota_label.position = Vector2(430, 10)
	top.add_child(quota_label)

	var con_l := UIU.label("良心", 13, UIU.COL_GREY)
	con_l.position = Vector2(1075, 12)
	top.add_child(con_l)
	hearts = UIU.hearts_bar()
	hearts.position = Vector2(1112, 9)
	hearts.scale = Vector2(0.82, 0.82)
	top.add_child(hearts)
	Game.conscience_changed.connect(func(v: int):
		if hearts != null:
			hearts.value = v
	)
	hearts.value = Game.conscience

	# 计时条
	var timer_bg := UIU.panel(Color("14160f"))
	timer_bg.position = Vector2(0, 40)
	timer_bg.size = Vector2(1280, 8)
	add_child(timer_bg)
	timer_fill = ColorRect.new()
	timer_fill.color = UIU.COL_GREEN
	timer_fill.position = Vector2(0, 0)
	timer_fill.size = Vector2(1280, 8)
	timer_bg.add_child(timer_fill)

	# 站内广播（剧情）/ 今夜荒诞新规（无尽）
	news_label = UIU.label("", 13, Color("9aa58f"))
	news_label.position = Vector2(0, 52)
	news_label.size = Vector2(1280, 18)
	news_label.clip_text = false
	add_child(news_label)
	if endless and not Game.tonight_rule.is_empty():
		news_label.text = "⚑ " + String(Game.tonight_rule.get("text", ""))
		news_label.add_theme_color_override("font_color", UIU.COL_YELLOW)
		news_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	else:
		_news_loop()

	# 旅客与军官
	portrait = Portrait.new()
	portrait.position = Vector2(230, 248)
	add_child(portrait)

	official = Portrait.new()
	official.set_look({"skin": Color("d9a679"), "hair": Color("2a2a2a"), "hair_style": 3,
		"hat": "military", "clothes": Color("4a543c")})
	official.set_expression("still")
	official.scale = Vector2(0.8, 0.8)
	official.position = Vector2(470, 230)
	official.visible = false
	add_child(official)

	# 军官台词
	official_line = UIU.label(" ", 17, UIU.COL_RED, true)
	official_line.position = Vector2(442, 46)
	official_line.size = Vector2(520, 26)
	add_child(official_line)

	# 气泡
	bubble = PanelContainer.new()
	bubble.add_theme_stylebox_override("panel", UIU.sbox(Color("e8e2c8"), Color("9a9070"), 1, 6))
	bubble.position = Vector2(442, 76)
	bubble.size = Vector2(500, 104)
	add_child(bubble)
	bubble_text = UIU.label(" ", 16, UIU.COL_TEXT)
	bubble_text.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	bubble_text.custom_minimum_size = Vector2(476, 84)
	bubble.add_child(bubble_text)

	# 判罚行（VBox 自动排布，杜绝重叠）
	var verdict_box := VBoxContainer.new()
	verdict_box.position = Vector2(442, 188)
	verdict_box.add_theme_constant_override("separation", 6)
	add_child(verdict_box)
	verdict_line = UIU.label(" ", 15, UIU.COL_GREY)
	verdict_line.custom_minimum_size = Vector2(512, 20)
	verdict_box.add_child(verdict_line)
	aftermath_line = UIU.label(" ", 13, UIU.COL_RED, true)
	aftermath_line.custom_minimum_size = Vector2(512, 34)
	aftermath_line.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	verdict_box.add_child(aftermath_line)

	# 反应条（测谎）
	react_bar = UIU.panel(Color("1a1d16"), Color("3a4034"), 1, 2)
	react_bar.position = Vector2(442, 282)
	react_bar.size = Vector2(300, 12)
	react_bar.visible = false
	add_child(react_bar)
	react_bar_fill = ColorRect.new()
	react_bar_fill.color = UIU.COL_YELLOW
	react_bar_fill.size = Vector2(0, 10)
	react_bar.add_child(react_bar_fill)

	# 抗议横幅
	protest_label = UIU.label("后面排队的人开始抗议！", 20, UIU.COL_RED)
	protest_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	protest_label.position = Vector2(400, 308)
	protest_label.size = Vector2(480, 30)
	protest_label.visible = false
	add_child(protest_label)

	# 入境卡
	card = EntryCard.new()
	card.position = Vector2(34, 424)
	card.rotation_degrees = -1.4
	add_child(card)
	card.field_hover.connect(_on_field_hover)
	card.mouse_exited.connect(_hide_mag_popup)

	# 工具列
	var tools := VBoxContainer.new()
	tools.position = Vector2(665, 428)
	tools.add_theme_constant_override("separation", 6)
	add_child(tools)
	tools.add_child(_tool_button("规则手册 [R]", 150, func(): _open_overlay("rulebook")))
	tools.add_child(_tool_button("IP·比对终端 [Q]", 150, func(): _open_overlay("terminal")))
	mag_btn = _tool_button("放大镜 [E]", 150, func():
		mag_on = not mag_on
		Sfx.play("beep", -14.0)
		if not mag_on:
			_hide_mag_popup()
	)
	mag_btn.toggle_mode = true
	tools.add_child(mag_btn)
	if day >= 6 or endless:
		tools.add_child(_tool_button("股权查询 [G]", 150, func(): _open_overlay("equity")))
	if day >= 7 or endless:
		tools.add_child(_tool_button("组织名册 [F]", 150, func(): _open_overlay("roster")))

	# 印章
	approve_btn = _stamp_button("准 予", UIU.COL_GREEN, func(): _stamp("approve"))
	approve_btn.position = Vector2(950, 442)
	add_child(approve_btn)
	deny_btn = _stamp_button("拒 绝", UIU.COL_RED, func(): _stamp("deny"))
	deny_btn.position = Vector2(1122, 442)
	add_child(deny_btn)
	detain_btn = _stamp_button("拘 留", UIU.COL_YELLOW, func(): _stamp("detain"))
	detain_btn.position = Vector2(1010, 560)
	detain_btn.visible = false
	add_child(detain_btn)

	# 放大镜弹注
	mag_popup = PanelContainer.new()
	mag_popup.add_theme_stylebox_override("panel", UIU.sbox(Color("2a2e24"), Color("c9a227"), 1, 4))
	mag_popup.visible = false
	mag_popup.z_index = 50
	add_child(mag_popup)
	mag_popup_text = UIU.label(" ", 13, Color("e8d9a0"))
	mag_popup_text.custom_minimum_size = Vector2(300, 10)
	mag_popup.add_child(mag_popup_text)

	# 底部提示（加深色底，避免被木纹吃掉）
	var hint_bg := UIU.panel(Color(0.05, 0.06, 0.04, 0.6))
	hint_bg.position = Vector2(0, 692)
	hint_bg.size = Vector2(1280, 28)
	add_child(hint_bg)
	hint_label = UIU.label("A 准予 · D 拒绝 · X 拘留（测谎时） · E 放大镜 · R 手册 · Q 查询终端 ｜ 卡片上的归属地是旅客自己填的，用终端验真。", 12, Color("b8bda8"))
	hint_label.position = Vector2(16, 697)
	hint_bg.add_child(hint_label)


func _news_loop() -> void:
	while is_inside_tree() and not endless:
		var pool: Array = Rules.news(Game.day)
		var txt := String(pool[news_idx % pool.size()])
		news_idx += 1
		news_label.text = txt
		var w: float = news_label.get_font("font").get_string_size(txt, HORIZONTAL_ALIGNMENT_LEFT, -1, 13).x
		news_label.position.x = 1300
		var dur: float = 6.0 + w * 0.02
		var tw := create_tween()
		tw.tween_property(news_label, "position:x", -w - 40.0, dur)
		await tw.finished
		await Game.wait(0.6)


func _tool_button(txt: String, w: int, cb: Callable) -> Button:
	var b := UIU.button(txt, 14, cb, Color("4a5244"))
	b.custom_minimum_size = Vector2(w, 36)
	b.add_theme_stylebox_override("normal", UIU.sbox(Color("3f4738"), Color("2a2f24"), 1, 3))
	b.add_theme_stylebox_override("hover", UIU.sbox(Color("4c5544"), Color("2a2f24"), 1, 3))
	b.add_theme_stylebox_override("pressed", UIU.sbox(Color("333b2d"), Color("2a2f24"), 1, 3))
	return b


func _stamp_button(txt: String, col: Color, cb: Callable) -> Button:
	var b := UIU.button(txt, 26, cb, col.darkened(0.1), Color.WHITE)
	b.custom_minimum_size = Vector2(148, 96)
	b.add_theme_stylebox_override("normal", UIU.sbox(col.darkened(0.55), col, 2, 6))
	b.add_theme_stylebox_override("hover", UIU.sbox(col.darkened(0.45), col, 2, 6))
	b.add_theme_stylebox_override("pressed", UIU.sbox(col.darkened(0.65), col, 2, 6))
	b.add_theme_stylebox_override("disabled", UIU.sbox(Color("3a3d36"), Color("4a4d44"), 2, 6))
	b.add_theme_color_override("font_disabled_color", Color("6a6d64"))
	b.pressed.connect(func():
		Sfx.play("stamp_move", -12.0)
	)
	return b


func _open_overlay(kind: String) -> void:
	if overlay != null:
		var old := overlay
		overlay = null
		old.queue_free()
	Sfx.play("page", -10.0)
	match kind:
		"rulebook":
			overlay = Overlays.Rulebook.new()
			overlay.setup(day)
		"terminal":
			overlay = Overlays.Terminal.new()
			overlay.setup(self)
		"equity":
			overlay = Overlays.Equity.new()
			overlay.setup(self)
		"roster":
			overlay = Overlays.Roster.new()
	if overlay == null:
		return
	var self_overlay := overlay
	overlay.closed.connect(func():
		if overlay == self_overlay:
			overlay = null
			Sfx.play("page", -14.0)
	)
	add_child(overlay)
	overlay.set_anchors_preset(Control.PRESET_FULL_RECT)


# ============================================================ 输入

func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo:
		if overlay != null:
			if event.keycode == KEY_ESCAPE:
				overlay.queue_free()
				overlay = null
			return
		match event.keycode:
			KEY_A:
				_stamp("approve")
			KEY_D:
				_stamp("deny")
			KEY_X:
				_stamp("detain")
			KEY_E:
				mag_on = not mag_on
				Sfx.play("beep", -14.0)
			KEY_R:
				_open_overlay("rulebook")
			KEY_Q, KEY_T:
				_open_overlay("terminal")
			KEY_G:
				if day >= 6:
					_open_overlay("equity")
			KEY_F:
				if day >= 7:
					_open_overlay("roster")


func _process(delta: float) -> void:
	if stamps_enabled and time_left > 0.0:
		time_left = max(0.0, time_left - delta)
		var ratio := time_left / max_time
		timer_fill.size.x = 1280.0 * ratio
		timer_fill.color = Color(1.0 - ratio, 0.35 + 0.45 * ratio, 0.25, 1.0)
		if time_left <= 0.0 and not protested:
			protested = true
			stats["protested"] = 1
			protest_label.visible = true
			Sfx.play("murmur", -6.0)
			_float("排队压力：绩效 -2", Color("e07a4a"), Vector2(640, 300))
	# 时钟（纯装饰）
	var done := float(idx)
	if max_time > 0.0:
		done += (1.0 - time_left / max_time)
	var minutes := 8 * 60 + int(done * 72)
	clock_label.text = "%02d:%02d" % [int(minutes / 60) % 24, minutes % 60]


# ============================================================ 旅客流程

func _next_traveler() -> void:
	gen += 1
	var g := gen
	if idx >= roster.size():
		await Game.wait(0.6)
		if g == gen:
			_end_day()
		return
	if Game.shot.begins_with("trailer_day"):
		var limit := 3 if Game.shot == "trailer_day1" else 2
		if idx >= limit:
			Game.end_movie(1.2)
			return
	current = roster[idx]
	query_region = ""
	code_state = ""
	protested = false
	mag_on = false
	_hide_mag_popup()
	protest_label.visible = false
	react_bar.visible = false
	official.visible = false
	official_line.text = " "
	verdict_line.text = " "
	aftermath_line.text = " "
	bubble_text.text = "（下一位——）"
	_set_stamps(false)
	detain_btn.visible = false

	if current.has("revisit"):
		Travelers.apply_revisit(current)
		Game.achieve("reunion")
	card.setup(current, day)

	portrait.visible = true
	portrait.set_look(current.get("look", {}))
	portrait.set_expression(current.get("expr", "calm"))
	portrait.position = Vector2(120, 248)
	var tw := create_tween()
	tw.tween_property(portrait, "position:x", 230.0, 0.4)
	Sfx.play("steps", -10.0)

	max_time = 50.0 if day == 1 else 65.0
	time_left = max_time
	quota_label.text = "剩余旅客 %d / %d" % [roster.size() - idx, roster.size()]

	await Game.wait(0.45)
	if g != gen:
		return
	_say(String(current["lines"].get("intro", "……")))
	Sfx.play("ding", -16.0)
	_set_stamps(true)

	if current.has("code"):
		await Game.wait(1.1)
		if g != gen:
			return
		await _run_code_test(current)
		if g != gen:
			return

	if Game.test_mode and Game.shot != "booth_state":
		_auto_decide()


## 截图模式：全屏下打开终端，复现“左上角”问题是否已修
func _fs_terminal_test() -> void:
	DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	await get_tree().create_timer(0.8).timeout
	_open_overlay("terminal")
	await get_tree().create_timer(0.6).timeout
	Game.take_shot("fs_terminal")


## 截图模式：复现“判罚 + 事后通报”同屏状态
func _shot_state() -> void:
	await Game.wait(1.2)
	_stamp("approve")     # 故意误准予王建国 → 漏放 + 事后通报
	await Game.wait(0.3)
	Game.take_shot("booth_state")


func _say(text: String) -> void:
	bubble_text.text = text


func _set_stamps(on: bool) -> void:
	stamps_enabled = on
	approve_btn.disabled = not on
	deny_btn.disabled = not on
	if not on:
		detain_btn.disabled = true


## ---------------- 暗号测谎（第 3 天+） ----------------
func _run_code_test(t: Dictionary) -> void:
	if not t.has("code"):
		return
	code_state = "pending"
	_set_stamps(false)
	Sfx.stop_ambient()
	Sfx.play("shoes", -6.0)
	Sfx.start_heartbeat()
	official.visible = true
	official.position = Vector2(500, 230)
	var tw := create_tween()
	tw.tween_property(official, "position:x", 360.0, 0.7)
	await Game.wait(0.75)
	Sfx.play("knock", -6.0)
	official_line.text = "军官：突击检查。问一个问题。"
	await Game.wait(0.9)

	var code: Dictionary = Rules.codes()[int(t["code"]["idx"])]
	var mode: String = t["code"]["mode"]
	official_line.text = "军官（盯着旅客）：" + String(code["q"])
	Sfx.play("beep_low", -10.0)

	# 微表情 + 反应条
	react_bar.visible = true
	react_bar_fill.size.x = 0
	if mode == "instant":
		portrait.set_micro({"pupil": 0.75, "twitch": true})
		portrait.set_expression("smug")
	else:
		portrait.set_micro({"pupil": 1.9, "sweat": true})
		portrait.set_expression("shock")
	var react_time := 0.55 if mode == "instant" else 2.3
	var tw2 := create_tween()
	tw2.tween_property(react_bar_fill, "size:x", 298.0, react_time)
	await Game.wait(react_time)
	react_bar.visible = false

	if mode == "instant":
		var ans: String = code["a"]
		if String(code["type"]) == "cn":
			code_state = "answered_cn"
			_say("旅客（脱口而出）：%s" % ans)
		else:
			code_state = "answered_intl"
			_say("旅客：%s" % ans)
	else:
		code_state = "no_code"
		var confused := ["……什么酒？", "……什么虎？", "抱歉，您说什么？", "（他愣住了，眼睛瞪大）"]
		_say("旅客（愣住两秒多）：%s" % confused[idx % confused.size()])
	official_line.text = "军官：记下来。（附注：答出特定文化暗号者就地拘留；通用问题不作依据。）"
	detain_btn.visible = true
	detain_btn.disabled = false
	_set_stamps(true)


## ---------------- 判罚 ----------------
func _evaluate(action: String) -> Dictionary:
	var t := current
	Game.decisions[String(t.get("id", ""))] = action
	var expect := String(t.get("expect", "approve"))
	stats["judged"] += 1

	var is_rejectish := action == "deny" or action == "detain"
	if is_rejectish:
		rejected_ids.append({"id": t.get("id", ""), "name": t.get("name", "?")})
		Game.total_rejected += 1
	else:
		Game.total_approved += 1

	if expect == "nowin":
		stats["wrong_basis"] += 1
		return {"kind": "nowin", "note": "依据不足（条款冲突）",
			"reveal": "合规部裁定：依据不足。绩效 -2。你不知道错在哪。"}

	var correct := expect
	if t.has("code") and code_state == "answered_cn":
		correct = "detain"

	if expect == "gray":
		if action == "deny":
			return {"kind": "gray_deny", "note": "灰色地带。手册未注明。",
				"conscience": bool(t.get("innocent", false)), "aftermath": String(t.get("aftermath", ""))}
		if action == "detain":
			return {"kind": "gray_detain", "note": "灰色地带。你把他抓了。",
				"conscience": bool(t.get("innocent", false)), "aftermath": String(t.get("aftermath", ""))}
		return {"kind": "gray_ok", "note": "灰色地带。手册未注明——你放行了。"}

	if action == correct:
		if correct == "reject" or correct == "detain":
			stats["caught"] += 1
			var hit: bool = bool(t.get("innocent", false))
			return {"kind": "caught", "note": "+1 查获",
				"conscience": hit, "aftermath": String(t.get("aftermath", "")) if hit else ""}
		return {"kind": "ok", "note": "准予无误"}
	elif action == "approve" and (correct == "reject" or correct == "detain"):
		stats["missed"] += 1
		return {"kind": "missed", "note": "漏放！", "reveal": "事后通报：" + String(t.get("reason", ""))}
	elif action == "deny" and correct == "approve":
		var hit2: bool = bool(t.get("innocent", false))
		return {"kind": "wrong_reject", "note": "（系统无此项统计）",
			"conscience": hit2, "aftermath": String(t.get("aftermath", ""))}
	elif action == "deny" and correct == "detain":
		stats["missed"] += 1
		return {"kind": "missed", "note": "应拘留，仅拒绝。军官记过。",
			"reveal": "事后通报：" + String(t.get("reason", ""))}
	elif action == "detain" and correct != "detain":
		stats["wrong_basis"] += 1
		var hit3: bool = bool(t.get("innocent", false))
		return {"kind": "wrong_detain", "note": "错抓。（依据不足）",
			"conscience": hit3, "aftermath": String(t.get("aftermath", ""))}
	return {"kind": "ok", "note": ""}


func _stamp(action: String) -> void:
	if not stamps_enabled or current.is_empty():
		return
	_set_stamps(false)
	detain_btn.visible = false

	match action:
		"approve":
			Sfx.play("stamp", -4.0)
		"deny":
			Sfx.play("stamp_deny", -4.0)
		"detain":
			Sfx.play("stamp_deny", -4.0)
			Sfx.play("knock", -8.0, 0.8)
	card.stamp(action)
	# 屏幕微震
	var sh := create_tween()
	sh.tween_property(self, "position", Vector2(2, 2), 0.04)
	sh.tween_property(self, "position", Vector2(-2, 1), 0.04)
	sh.tween_property(self, "position", Vector2.ZERO, 0.04)

	Sfx.stop_heartbeat()
	Sfx.start_ambient()

	var ev := _evaluate(action)
	var t := current

	# 反应台词
	match action:
		"approve":
			_say(String(t["lines"].get("approve", "……")))
			portrait.set_expression("calm")
		"deny":
			_say(String(t["lines"].get("deny", "……")))
			portrait.set_expression("sad" if t.get("innocent", false) else "angry")
		"detain":
			_say("（两名士兵把他带走了。）")
			portrait.set_expression("shock")

	# 判罚展示
	match String(ev.get("kind", "")):
		"caught":
			verdict_line.add_theme_color_override("font_color", UIU.COL_GREEN)
			_float("+1 查获", UIU.COL_GREEN, Vector2(230, 380))
		"ok", "gray_ok":
			verdict_line.add_theme_color_override("font_color", UIU.COL_GREY)
		"missed":
			verdict_line.add_theme_color_override("font_color", UIU.COL_RED)
			_float("漏放！", UIU.COL_RED, Vector2(230, 380))
		"nowin", "wrong_detain":
			verdict_line.add_theme_color_override("font_color", UIU.COL_YELLOW)
			_float("依据不足", UIU.COL_YELLOW, Vector2(230, 380))
		"wrong_reject":
			verdict_line.add_theme_color_override("font_color", UIU.COL_GREY)
			_float("误拒（系统看不见）", Color("9a8fb8"), Vector2(230, 380))
		"gray_deny", "gray_detain":
			verdict_line.add_theme_color_override("font_color", UIU.COL_YELLOW)
	verdict_line.text = String(ev.get("note", ""))

	if String(ev.get("reveal", "")) != "":
		aftermath_line.text = String(ev["reveal"])
		Sfx.play("beep_low", -14.0)

	# 良心（回头客可能有加倍伤害）
	if ev.get("conscience", false):
		Game.hit_conscience(int(t.get("conscience_cost", 1)))
		if String(ev.get("aftermath", "")) != "":
			aftermath_line.text = "【事后】" + String(ev["aftermath"])
		Sfx.play("sad", -8.0)
		_float("良心 -1", Color("c86bd8"), Vector2(1110, 40))

	# 图鉴
	if action == "deny" or action == "detain":
		var entry := Game.unlock_gallery_next()
		if not entry.is_empty():
			_float("图鉴解锁：%s" % entry["name"], UIU.COL_YELLOW, Vector2(1030, 640))

	# 成就检查
	var kind := String(ev.get("kind", ""))
	if kind == "caught":
		Game.achieve("first_blood")
	if action == "detain":
		Game.total_detained += 1
		if Game.total_detained >= 3:
			Game.achieve("code_master")
	if (kind == "caught" or kind == "ok") and (max_time - time_left) < 8.0:
		Game.achieve("speed_run")
	if Game.total_judged + int(stats["judged"]) >= 100:
		Game.achieve("stamp_100")

	await Game.wait(1.7)
	if Game.shot == "booth_state":
		return
	gen += 1
	idx += 1
	_next_traveler()


func _float(text: String, col: Color, pos: Vector2) -> void:
	var l := UIU.label(text, 16, col)
	l.position = pos
	l.z_index = 60
	add_child(l)
	var tw := create_tween()
	tw.set_parallel(true)
	tw.tween_property(l, "position:y", pos.y - 46, 1.3)
	tw.tween_property(l, "modulate:a", 0.0, 1.3).set_delay(0.4)
	tw.chain().tween_callback(l.queue_free)


# ============================================================ 放大镜

func _on_field_hover(note: String, global_pos: Vector2) -> void:
	if not mag_on:
		return
	mag_popup_text.text = "🔍 " + note
	mag_popup.visible = true
	var local := global_pos - global_position
	mag_popup.position = local + Vector2(20, -18)
	if mag_popup.position.x + 360 > 1280:
		mag_popup.position.x = local.x - 370
	if mag_popup.position.y < 50:
		mag_popup.position.y = local.y + 20


func _hide_mag_popup() -> void:
	if mag_popup != null:
		mag_popup.visible = false


# ============================================================ 日终

func _end_day() -> void:
	Sfx.stop_ambient()
	Sfx.stop_heartbeat()
	# 申诉信
	var generic_used := false
	for r in rejected_ids:
		var rid := String(r["id"])
		if Rules.special_letters().has(rid):
			Game.add_letter(String(r["name"]), String(Rules.special_letters()[rid]))
		elif not generic_used:
			generic_used = true
			var pool: Array = Rules.generic_letters()
			Game.add_letter(String(r["name"]), String(pool[idx % pool.size()]))
	Game.apply_day(stats)
	# 日终成就
	if int(stats.get("judged", 0)) >= 5:
		if int(stats.get("missed", 0)) == 0 and int(stats.get("wrong_basis", 0)) == 0:
			Game.achieve("no_miss")
		if int(stats.get("caught", 0)) >= 4:
			Game.achieve("iron_fist")
		if rejected_ids.is_empty():
			Game.achieve("mercy_day")
	if day == 8 and not endless:
		Game.achieve("wrong_day")
	if Game.conscience <= 0:
		Game.achieve("conscience_zero")
	await Game.wait(0.3)
	finished.emit()


# ============================================================ 自动测试

func _auto_decide() -> void:
	await Game.wait(0.1)
	while code_state == "pending":
		await Game.wait(0.05)
	var action := ""
	if String(current.get("expect", "approve")) == "nowin":
		action = "deny"
	elif String(current.get("expect", "approve")) == "gray":
		action = "approve"
	elif code_state == "answered_cn":
		action = "detain"
	else:
		action = String(current.get("expect", "approve"))
	_stamp(action)


# ============================================================ 背景

class _Backdrop extends Node2D:
	func _draw() -> void:
		var tier: int = Game.family_tier()
		# 墙
		draw_rect(Rect2(0, 0, 1280, 420), UIU.COL_BG2)
		for y in range(0, 420, 52):
			draw_line(Vector2(0, y), Vector2(1280, y), Color(0, 0, 0, 0.08), 2.0)
		for x in range(0, 1280, 96):
			draw_line(Vector2(x, 0), Vector2(x, 420), Color(0, 0, 0, 0.05), 2.0)

		# 窗外（灰白天空 + 排队剪影）
		draw_rect(Rect2(70, 70, 320, 330), Color("5c6258"))
		draw_rect(Rect2(70, 300, 320, 100), Color("4a4f47"))
		for i in 5:
			var sx := 110.0 + i * 52 + (10.0 if i % 2 == 0 else -6.0)
			var sy := 356.0 - (12.0 if i % 2 == 0 else 0.0)
			draw_rect(Rect2(sx, sy, 22, 44), Color(0.13, 0.15, 0.12))
			draw_circle(Vector2(sx + 11, sy - 6), 9.0, Color(0.13, 0.15, 0.12))
		# 窗框
		draw_rect(Rect2(64, 64, 332, 342), Color("4a4234"), false, 12.0)
		draw_line(Vector2(230, 70), Vector2(230, 400), Color("4a4234"), 6.0)
		draw_line(Vector2(70, 235), Vector2(390, 235), Color("4a4234"), 6.0)

		# 灯
		draw_line(Vector2(640, 0), Vector2(640, 92), Color(0.12, 0.12, 0.12), 5.0)
		draw_rect(Rect2(612, 92, 56, 16), Color("2e3226"))
		draw_circle(Vector2(640, 112), 10.0, Color(1.0, 0.96, 0.72))
		draw_polygon(
			PackedVector2Array([Vector2(640, 104), Vector2(420, 430), Vector2(860, 430)]),
			PackedColorArray([Color(1.0, 0.95, 0.7, 0.05), Color(1.0, 0.95, 0.7, 0.02), Color(1.0, 0.95, 0.7, 0.02)]))

		# 桌面
		draw_rect(Rect2(0, 414, 1280, 10), UIU.COL_DESK_DARK)
		draw_rect(Rect2(0, 424, 1280, 296), UIU.COL_DESK)
		for x in range(0, 1280, 40):
			draw_line(Vector2(x, 424), Vector2(x - 30, 720), Color(0, 0, 0, 0.05), 1.5)
		draw_line(Vector2(0, 424), Vector2(1280, 424), Color(0.35, 0.28, 0.18), 3.0)

		# 全家福（生活状况随工资变化）
		draw_rect(Rect2(850, 436, 92, 68), Color("6b543a"))
		draw_rect(Rect2(855, 441, 82, 58), Color("c9c0a5"))
		var heads := [Vector2(870, 462), Vector2(896, 462), Vector2(886, 478)]
		for h in heads:
			draw_circle(h, 7.0, Color("4a4234"))
		if tier >= 1:
			draw_rect(Rect2(862, 486, 68, 6), Color("7a6a4a"))
		if tier >= 2:
			draw_circle(Vector2(924, 470), 5.0, Color("b0543a"))   # 一碗肉
		draw_rect(Rect2(850, 504, 92, 3), Color("4a4234"))

		# 桌上的手册道具
		draw_rect(Rect2(552, 656, 130, 40), Color("8a3a2e"))
		draw_rect(Rect2(556, 652, 130, 40), Color("a04a3a"))
		draw_rect(Rect2(560, 656, 44, 32), Color("d8cfae"))

		# 暗角
		draw_rect(Rect2(0, 0, 1280, 8), Color(0, 0, 0, 0.35))
		draw_rect(Rect2(0, 0, 8, 720), Color(0, 0, 0, 0.35))
		draw_rect(Rect2(1272, 0, 8, 720), Color(0, 0, 0, 0.35))
