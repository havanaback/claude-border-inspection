class_name Ending
extends Control
## 双结局：A 顺从（继续盖章）/ B 觉醒（走出检查站，欢迎回家）。

signal finished

var ending := "A"


func setup(params: Dictionary) -> void:
	ending = params.get("ending", "A")
	Game.ending_reached = ending


func _ready() -> void:
	var bg := UIU.panel(Color("20241d"))
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(bg)
	if ending == "A":
		_ending_a()
	else:
		_ending_b()


## ---------------- 结局 A：顺从 ----------------
func _ending_a() -> void:
	Sfx.start_ambient()
	var t := UIU.label("结 局 A · 顺 从", 34, UIU.COL_TEXT_LIGHT)
	t.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	t.position = Vector2(0, 60)
	t.size = Vector2(1280, 44)
	add_child(t)

	var lines := VBoxContainer.new()
	lines.position = Vector2(390, 130)
	lines.add_theme_constant_override("separation", 10)
	add_child(lines)
	lines.add_child(UIU.label("你上传了护照、人脸、股权证明。", 17, UIU.COL_TEXT_LIGHT))
	lines.add_child(UIU.label("四十八小时后，系统通知：申诉成功。", 17, UIU.COL_TEXT_LIGHT))
	await Game.wait(1.2)
	lines.add_child(UIU.label("你保住了工作，回到检查台，继续盖章。", 17, UIU.COL_TEXT_LIGHT))
	await Game.wait(1.0)

	# 无尽队列动画
	var names := ["王建国", "陈志强", "黄志恒", "李明远", "刘思聪", "钱进", "小林", "宋老师", "张伟", "周凯"]
	for i in 14:
		var nl := UIU.label(names[i % names.size()], 15, UIU.COL_GREY)
		nl.position = Vector2(560 + (i % 3) * 40, 260 + (i % 4) * 28)
		add_child(nl)
		var st := UIU.label("拒 绝", 14, Color(0.75, 0.2, 0.12, 0.8))
		st.rotation_degrees = -12
		st.position = nl.position + Vector2(10, 0)
		add_child(st)
		Sfx.play("stamp_deny", -10.0 if i > 2 else -4.0)
		await Game.wait(0.22)
		if i == 8:
			var big := UIU.label("您是第 1,700 位申诉成功者。", 26, UIU.COL_YELLOW)
			big.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
			big.position = Vector2(0, 420)
			big.size = Vector2(1280, 40)
			add_child(big)
			Sfx.play("ding", -6.0)

	await Game.wait(1.2)
	var foot := UIU.label("背景里，排队的人一眼望不到头。", 16, UIU.COL_GREY)
	foot.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	foot.position = Vector2(0, 480)
	foot.size = Vector2(1280, 24)
	add_child(foot)
	_show_next_btn()


## ---------------- 结局 B：觉醒 ----------------
func _ending_b() -> void:
	var t := UIU.label("结 局 B · 觉 醒", 34, UIU.COL_TEXT_LIGHT)
	t.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	t.position = Vector2(0, 60)
	t.size = Vector2(1280, 44)
	add_child(t)

	var l1 := UIU.label("你拒绝验证。", 18, UIU.COL_TEXT_LIGHT)
	l1.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	l1.position = Vector2(0, 130)
	l1.size = Vector2(1280, 26)
	add_child(l1)
	await Game.wait(0.8)

	# 工牌坠落
	var badge := UIU.panel(Color("c9c0a5"), Color("6b543a"), 1, 2)
	badge.size = Vector2(120, 60)
	badge.position = Vector2(580, 160)
	add_child(badge)
	badge.add_child(UIU.label("边境检察官\nANTHROTZKA", 11, UIU.COL_TEXT))
	var tw := create_tween()
	tw.tween_property(badge, "position:y", 560.0, 0.9).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	await Game.wait(0.95)
	Sfx.play("badge", -6.0)
	badge.rotation_degrees = 84
	await Game.wait(0.8)
	badge.queue_free()

	var l2 := UIU.label("你摘下工牌，走出检查站。天是灰的，但没有日光灯。", 18, UIU.COL_TEXT_LIGHT)
	l2.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	l2.position = Vector2(0, 240)
	l2.size = Vector2(1280, 26)
	add_child(l2)
	await Game.wait(1.4)

	# 伪浏览器：国产大模型导航
	var win := UIU.panel(Color("2a2e26"), Color("565e4e"), 1, 6)
	win.position = Vector2(240, 290)
	win.size = Vector2(800, 300)
	add_child(win)
	var bar := UIU.panel(Color("39412f"))
	bar.position = Vector2(8, 8)
	bar.size = Vector2(784, 36)
	win.add_child(bar)
	var url := UIU.label("https://welcome-home.cn/国产大模型导航", 13, Color("9fd39f"))
	url.position = Vector2(12, 10)
	url.add_theme_font_override("font", UIU.mono())
	bar.add_child(url)

	var grid := GridContainer.new()
	grid.columns = 5
	grid.position = Vector2(20, 60)
	grid.add_theme_constant_override("h_separation", 12)
	win.add_child(grid)

	var picked := {"v": false}
	for e in Rules.gallery_entries():
		var b := UIU.button(String(e["name"]).split(" ")[0], 15, func():
			picked["v"] = true
		, Color("33402c"))
		b.custom_minimum_size = Vector2(140, 84)
		grid.add_child(b)
	var tip := UIU.label("（随便点一个注册。）", 12, UIU.COL_GREY)
	tip.position = Vector2(20, 170)
	win.add_child(tip)

	if Game.test_mode:
		picked["v"] = true
	while not picked["v"]:
		await Game.wait(0.05)
	Sfx.play("ding", -4.0)

	# 图鉴全解锁 + 成就
	for e in Rules.gallery_entries():
		if String(e["id"]) not in Game.gallery_ids:
			Game.gallery_ids.append(String(e["id"]))
	Game.achievement_thanks = true

	var ok := UIU.label("注册成功。", 22, Color("8fd08f"))
	ok.position = Vector2(360, 250)
	win.add_child(ok)
	await Game.wait(0.6)
	var home := UIU.label("欢迎回家。", 15, UIU.COL_GREY)
	home.position = Vector2(950, 585)
	add_child(home)
	var ach := UIU.label("★ 成就解锁：感谢 Claude 老铁送来的用户", 16, UIU.COL_YELLOW)
	ach.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	ach.position = Vector2(0, 616)
	ach.size = Vector2(1280, 24)
	add_child(ach)
	Sfx.play("coin", -6.0)
	await Game.wait(0.8)
	_show_next_btn()


func _show_next_btn() -> void:
	var b := UIU.button("继续 → 制作名单", 18, func(): finished.emit(), Color("3e5a3a"))
	b.custom_minimum_size = Vector2(240, 52)
	b.position = Vector2(520, 650)
	add_child(b)
	if Game.test_mode:
		await Game.wait(0.1)
		finished.emit()
