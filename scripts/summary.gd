class_name Summary
extends Control
## 日结算：绩效、工资、良心、家庭状况 + 申诉箱 + 替代方案图鉴。

signal finished

var day := 1
var wage := 0
var endless := false


func setup(params: Dictionary) -> void:
	day = params.get("day", 1)
	endless = params.get("endless", false)


func _ready() -> void:
	var stats: Dictionary = Game.day_stats
	if endless:
		_endless_ready(stats)
		return
	var bg := UIU.panel(UIU.COL_BG)
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(bg)

	var caught: int = stats.get("caught", 0)
	var missed: int = stats.get("missed", 0)
	var wb: int = stats.get("wrong_basis", 0)
	var judged: int = stats.get("judged", 0)
	var prot: int = stats.get("protested", 0)
	wage = clampi(20 + caught * 3 - missed * 5 - wb * 2 - prot * 2, 0, 999)
	Game.money += wage

	var title := UIU.label("第 %d 天 · 日结 ｜ %s" % [day, Rules.day_date(day)], 26, UIU.COL_TEXT_LIGHT)
	title.position = Vector2(140, 44)
	add_child(title)
	var sub := UIU.label("「绩效不是为了让你守法，是为了让你永远可能违规。」", 13, UIU.COL_GREY)
	sub.position = Vector2(140, 78)
	add_child(sub)

	# 左：绩效
	var grid := GridContainer.new()
	grid.columns = 2
	grid.position = Vector2(140, 110)
	grid.add_theme_constant_override("h_separation", 34)
	grid.add_theme_constant_override("v_separation", 12)
	add_child(grid)
	grid.add_child(UIU.label("审查人数", 16, UIU.COL_GREY))
	grid.add_child(UIU.label("%d" % judged, 16, UIU.COL_TEXT_LIGHT))
	grid.add_child(UIU.label("查获", 16, UIU.COL_GREY))
	grid.add_child(UIU.label("%d　（+%d 克朗）" % [caught, caught * 3], 16, Color("8fd08f")))
	grid.add_child(UIU.label("漏放", 16, UIU.COL_GREY))
	grid.add_child(UIU.label("%d　（-%d 克朗）" % [missed, missed * 5], 16, Color("e08a7a") if missed > 0 else UIU.COL_TEXT_LIGHT))
	grid.add_child(UIU.label("依据不足", 16, UIU.COL_GREY))
	grid.add_child(UIU.label("%d　（-%d 克朗）" % [wb, wb * 2], 16, Color("e0b050") if wb > 0 else UIU.COL_TEXT_LIGHT))
	grid.add_child(UIU.label("排队抗议", 16, UIU.COL_GREY))
	grid.add_child(UIU.label("有　（-2 克朗）" if prot > 0 else "无", 16, Color("e0b050") if prot > 0 else UIU.COL_TEXT_LIGHT))
	grid.add_child(UIU.label("误拒率", 16, UIU.COL_GREY))
	grid.add_child(UIU.label("【系统无此项统计】", 16, Color("9a8fb8")))

	var wage_box := UIU.panel(Color("232820"), Color("565e4e"), 1, 4)
	wage_box.position = Vector2(140, 330)
	wage_box.size = Vector2(430, 92)
	add_child(wage_box)
	var wl1 := UIU.label("今日工资：%d 克朗" % wage, 22, UIU.COL_YELLOW)
	wl1.position = Vector2(20, 12)
	wage_box.add_child(wl1)
	var wl2 := UIU.label("累计：%d 克朗" % Game.money, 14, UIU.COL_GREY)
	wl2.position = Vector2(20, 52)
	wage_box.add_child(wl2)

	# 中：家庭
	var fam := UIU.panel(Color("262b22"), Color("565e4e"), 1, 4)
	fam.position = Vector2(610, 110)
	fam.size = Vector2(300, 240)
	add_child(fam)
	var fh := UIU.label("— 全家福 —", 15, UIU.COL_GREY)
	fh.position = Vector2(105, 10)
	fam.add_child(fh)
	var photo := _FamilyPhoto.new()
	photo.position = Vector2(75, 36)
	fam.add_child(photo)
	var ft := UIU.label(Game.family_text(), 14, UIU.COL_TEXT_LIGHT)
	ft.position = Vector2(16, 158)
	ft.size = Vector2(268, 70)
	ft.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	fam.add_child(ft)

	# 右：良心
	var con := UIU.panel(Color("262b22"), Color("565e4e"), 1, 4)
	con.position = Vector2(950, 110)
	con.size = Vector2(210, 240)
	add_child(con)
	var ch := UIU.label("良心值", 15, UIU.COL_GREY)
	ch.position = Vector2(76, 10)
	con.add_child(ch)
	var hearts := UIU.hearts_bar()
	hearts.position = Vector2(20, 40)
	hearts.scale = Vector2(0.85, 0.85)
	hearts.value = Game.conscience
	con.add_child(hearts)
	var cn := UIU.label("%d / %d" % [Game.conscience, Game.START_CONSCIENCE], 18, Color("c86bd8"))
	cn.position = Vector2(70, 70)
	con.add_child(cn)
	var cn2 := UIU.label("归零时，最终日\n你将只剩一个选择。", 12, UIU.COL_GREY)
	cn2.position = Vector2(30, 110)
	con.add_child(cn2)

	# 成就
	if Game.achievement_thanks:
		var ach := UIU.label("★ 成就解锁：感谢 Claude 老铁送来的用户", 16, UIU.COL_YELLOW)
		ach.position = Vector2(610, 370)
		add_child(ach)

	# 按钮
	var btns := HBoxContainer.new()
	btns.position = Vector2(140, 470)
	btns.add_theme_constant_override("separation", 14)
	add_child(btns)
	var b1 := UIU.button("申诉箱（休息时间）", 17, _open_appeals, Color("4a4252"))
	b1.custom_minimum_size = Vector2(210, 56)
	btns.add_child(b1)
	var b2 := UIU.button("替代方案图鉴", 17, _open_gallery, Color("3a4a5a"))
	b2.custom_minimum_size = Vector2(190, 56)
	btns.add_child(b2)
	var b4 := UIU.button("成 就", 17, _open_achievements, Color("4a4252"))
	b4.custom_minimum_size = Vector2(120, 56)
	btns.add_child(b4)

	var next_txt := "下班睡觉 →" if day < Game.TOTAL_DAYS else "睡觉。明天是最后一天 →"
	var b3 := UIU.button(next_txt, 20, func(): finished.emit(), Color("3e5a3a"))
	b3.custom_minimum_size = Vector2(300, 56)
	b3.position = Vector2(140, 560)
	add_child(b3)

	if day >= Game.TOTAL_DAYS:
		var warn := UIU.label("明天：例行核查。包括你。", 14, UIU.COL_RED, true)
		warn.position = Vector2(160, 626)
		add_child(warn)

	Sfx.play("coin", -8.0)
	if day >= Game.TOTAL_DAYS and Game.conscience >= Game.START_CONSCIENCE:
		Game.achieve("conscience_full")
	Game.take_shot("summary")
	if Game.shot == "gallery":
		_open_gallery()
		Game.take_shot("gallery")
	if Game.test_mode:
		await Game.wait(0.1)
		finished.emit()


## ---------------- 申诉箱 ----------------
func _open_appeals() -> void:
	Sfx.play("page", -8.0)
	var w := UIU.make_window(self, "申诉箱 · 今天被你拒绝的人写来的信", Vector2(660, 480))
	var c: VBoxContainer = w["content"]

	var todays: Array[Dictionary] = []
	for l in Game.letters:
		if int(l.get("day", 0)) == day:
			todays.append(l)
	if todays.is_empty():
		for l2 in Game.letters.slice(maxi(0, Game.letters.size() - 3)):
			todays.append(l2)

	if todays.is_empty():
		c.add_child(UIU.label("（今天没有申诉信。你今天没拒绝任何人。）", 15, UIU.COL_GREY))
	else:
		var list := VBoxContainer.new()
		list.add_theme_constant_override("separation", 6)
		c.add_child(list)
		for l in todays:
			var b := UIU.button("来自：%s" % String(l.get("sender", "匿名")), 14, func():
				_read_letter(String(l.get("text", "")))
			, Color("3a3f33"))
			b.custom_minimum_size = Vector2(500, 36)
			list.add_child(b)

	c.add_child(UIU.vsep(4))
	c.add_child(UIU.label("翻阅申诉信不会改变任何结果。", 13, UIU.COL_GREY))


func _read_letter(text: String) -> void:
	Sfx.play("page", -8.0)
	var dlg := UIU.make_window(self, "一封信", Vector2(560, 380))
	var c: VBoxContainer = dlg["content"]
	var rl := RichTextLabel.new()
	rl.bbcode_enabled = true
	rl.size_flags_vertical = Control.SIZE_EXPAND_FILL
	rl.add_theme_font_override("normal_font", UIU.kai())
	rl.add_theme_font_size_override("normal_font_size", 16)
	rl.add_theme_color_override("default_color", Color("d9d4c0"))
	c.add_child(rl)

	var skip := UIU.button("跳过打字效果", 13, func(): pass, Color("3a3f33"))
	c.add_child(skip)
	var done := {"v": false}
	skip.pressed.connect(func():
		done["v"] = true
	)

	for i in text.length():
		if done["v"]:
			rl.clear()
			rl.append_text(text)
			break
		rl.append_text(text[i])
		if i % 2 == 0:
			Sfx.play("type", -22.0)
			await Game.wait(0.018)
	c.add_child(UIU.label("（你合上了信。什么也没有发生。）", 13, UIU.COL_GREY))


## ---------------- 图鉴 ----------------
func _open_gallery() -> void:
	Sfx.play("page", -8.0)
	var w := UIU.make_window(self, "替代方案图鉴 · 每拒绝一位旅客，解锁一条", Vector2(700, 430))
	var c: VBoxContainer = w["content"]

	var grid := GridContainer.new()
	grid.columns = 3
	grid.add_theme_constant_override("h_separation", 12)
	grid.add_theme_constant_override("v_separation", 12)
	c.add_child(grid)

	for e in Rules.gallery_entries():
		var unlocked: bool = String(e["id"]) in Game.gallery_ids
		var cell := PanelContainer.new()
		cell.add_theme_stylebox_override("panel", UIU.sbox(
			Color("2c3326") if unlocked else Color("22261e"),
			Color("7fdd7f") if unlocked else Color("3a4034"), 1, 4))
		var v := VBoxContainer.new()
		v.add_theme_constant_override("separation", 4)
		var name_l: Label
		var desc_l: Label
		if unlocked:
			name_l = UIU.label(String(e["name"]), 17, Color("8fd08f"))
			desc_l = UIU.label(String(e["desc"]), 12, UIU.COL_TEXT_LIGHT)
		else:
			name_l = UIU.label("？？？", 17, UIU.COL_GREY)
			desc_l = UIU.label("（拒绝一位旅客后解锁）", 12, UIU.COL_GREY)
		desc_l.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		desc_l.custom_minimum_size = Vector2(190, 60)
		v.add_child(name_l)
		v.add_child(desc_l)
		cell.add_child(v)
		grid.add_child(cell)

	if Game.achievement_thanks:
		c.add_child(UIU.label("★ 成就解锁：感谢 Claude 老铁送来的用户（图鉴集齐）", 15, UIU.COL_YELLOW))


class _FamilyPhoto extends Node2D:
	func _draw() -> void:
		draw_rect(Rect2(0, 0, 150, 110), Color("6b543a"))
		draw_rect(Rect2(6, 6, 138, 98), Color("c9c0a5"))
		var tier: int = Game.family_tier()
		# 三口人
		for p in [Vector2(45, 48), Vector2(75, 44), Vector2(105, 48)]:
			draw_circle(p, 11.0, Color("4a4234"))
			draw_rect(Rect2(p.x - 12, p.y + 10, 24, 26), Color("5a5244"))
		# 桌子
		draw_rect(Rect2(22, 84, 106, 6), Color("7a6a4a"))
		if tier >= 1:
			draw_rect(Rect2(58, 76, 12, 8), Color("9aa5b5"))    # 一碗汤
		if tier >= 2:
			draw_circle(Vector2(96, 74), 6.0, Color("b0543a"))   # 一碗肉


## ---------------- 无尽模式：夜结算 ----------------
func _endless_ready(stats: Dictionary) -> void:
	var caught: int = stats.get("caught", 0)
	var missed: int = stats.get("missed", 0)
	Game.endless_missed_night = missed
	if Game.endless_night >= 5:
		Game.achieve("endless_5")
	Game.endless_best = maxi(Game.endless_best, Game.endless_night)
	Game.save_game()

	var over := missed >= 3
	var bg := UIU.panel(Color("191d15"))
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(bg)

	var t1 := UIU.label(("绩效听证会" if over else "加班 · 第 %d 夜 · 战报" % Game.endless_night), 34,
		UIU.COL_RED if over else UIU.COL_TEXT_LIGHT)
	t1.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	t1.position = Vector2(0, 90)
	t1.size = Vector2(1280, 44)
	add_child(t1)

	var info := UIU.label("今夜规则：%s
查获 %d ｜ 漏放 %d ｜ %s" % [
		String(Game.tonight_rule.get("text", "—")), caught, missed,
		("漏放 3 人——你的执法资格被终止。" if over else "尚可继续。天亮了，但没有意义。")], 17, UIU.COL_TEXT_LIGHT)
	info.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	info.position = Vector2(0, 160)
	info.size = Vector2(1280, 60)
	add_child(info)

	if over:
		var total := "你一共坚持了 %d 夜。累计查获 %d 人，误拒的无辜者只有你自己知道。
历史最佳：%d 夜" % [
			Game.endless_night, Game.total_caught, Game.endless_best]
		var sum := UIU.label(total, 20, UIU.COL_YELLOW)
		sum.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		sum.position = Vector2(0, 280)
		sum.size = Vector2(1280, 80)
		add_child(sum)
		Game.endless_over = true
	else:
		var nxt := UIU.button("下一夜 → （困意不算理由）", 20, func():
			finished.emit()
		, Color("6b3a30"))
		nxt.custom_minimum_size = Vector2(340, 56)
		nxt.position = Vector2(470, 400)
		add_child(nxt)

	var ach := UIU.button("成就 / 图鉴 / 申诉箱", 16, func():
		_open_achievements()
	, Color("3a4a5a"))
	ach.custom_minimum_size = Vector2(240, 44)
	ach.position = Vector2(520, 480 if not over else 380)
	add_child(ach)

	var back := UIU.button("返回标题（认输）", 16, func():
		Game.endless = false
		Game.endless_over = false
		finished.emit()
	, Color("444a3f"))
	back.custom_minimum_size = Vector2(240, 44)
	back.position = Vector2(520, 540 if not over else 440)
	add_child(back)

	if Game.test_mode:
		await Game.wait(0.1)
		if Game.endless_over:
			Game.endless = false
			Game.endless_over = false
		finished.emit()


## ---------------- 成就列表窗 ----------------
func _open_achievements() -> void:
	Sfx.play("page", -8.0)
	var w := UIU.make_window(self, "成就 · 共 %d 项" % Rules.achievements().size(), Vector2(640, 470))
	var c: VBoxContainer = w["content"]
	var scr := ScrollContainer.new()
	scr.size_flags_vertical = Control.SIZE_EXPAND_FILL
	c.add_child(scr)
	var list := VBoxContainer.new()
	list.add_theme_constant_override("separation", 6)
	list.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scr.add_child(list)
	for def in Rules.achievements():
		var got: bool = String(def["id"]) in Game.achievements
		var box := PanelContainer.new()
		box.add_theme_stylebox_override("panel", UIU.sbox(
			Color("26301f") if got else Color("20241c"),
			Color("7fdd7f") if got else Color("3a4034"), 1, 3))
		var h := HBoxContainer.new()
		h.add_theme_constant_override("separation", 10)
		var mark := UIU.label("★" if got else "·", 17, UIU.COL_YELLOW if got else UIU.COL_GREY)
		h.add_child(mark)
		var v := VBoxContainer.new()
		v.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		v.add_child(UIU.label(String(def["name"]), 15, Color("8fd08f") if got else UIU.COL_GREY))
		v.add_child(UIU.label(String(def["desc"]), 12, UIU.COL_TEXT_LIGHT if got else UIU.COL_GREY))
		h.add_child(v)
		box.add_child(h)
		list.add_child(box)
