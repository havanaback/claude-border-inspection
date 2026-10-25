class_name Title
extends Control
## 标题画面


func _ready() -> void:
	var bg := UIU.panel(UIU.COL_BG)
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(bg)

	# 顶部条纹（铁皮棚质感）
	var deco := _Deco.new()
	add_child(deco)

	var center := VBoxContainer.new()
	center.add_theme_constant_override("separation", 14)
	add_child(center)

	var t1 := UIU.label("边境检察官", 64, UIU.COL_TEXT_LIGHT)
	t1.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	center.add_child(t1)
	var t2 := UIU.label("Claude 入境审查", 30, UIU.COL_RED)
	t2.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	center.add_child(t2)
	var t3 := UIU.label("Papers, please. 以及你的时区，你的语言包，还有你的宫廷玉液酒。", 15, UIU.COL_GREY)
	t3.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	center.add_child(t3)
	center.add_child(UIU.vsep(18))

	if Game.has_save():
		var cont := UIU.button("继续上班（第 %d 天）" % Game.day, 20, func():
			Game.load_game()
			finished.emit()
		, Color("3e5a3a"))
		cont.custom_minimum_size = Vector2(300, 52)
		center.add_child(cont)

	var start := UIU.button("开始上班（新的一周）", 20, func():
		Game.reset_run()
		finished.emit()
	)
	start.custom_minimum_size = Vector2(300, 52)
	center.add_child(start)

	var endless_btn := UIU.button("加班无尽模式（Beta）", 18, func():
		Game.reset_run()
		Game.endless = true
		finished.emit()
	, Color("6b3a30"))
	endless_btn.custom_minimum_size = Vector2(300, 46)
	center.add_child(endless_btn)
	if Game.endless_best > 0:
		var best := UIU.label("无尽最佳纪录：第 %d 夜" % Game.endless_best, 13, UIU.COL_YELLOW)
		best.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		best.custom_minimum_size = Vector2(300, 18)
		center.add_child(best)

	var help := UIU.button("操作说明", 16, _show_help, Color("444a3f"))
	help.custom_minimum_size = Vector2(300, 40)
	center.add_child(help)

	# 精确居中（布局完成后按视口尺寸计算；全屏切换时自动保持）
	_center_control(center)
	get_tree().root.size_changed.connect(func():
		if is_instance_valid(center):
			_center_control(center)
	)

	Game.take_shot("title")

	var foot := UIU.label("本作纯属虚构，致敬 Lucas Pope《Papers, Please》。 ｜ A/D 盖章 · E 放大镜 · R 手册 · Q IP查询", 12, UIU.COL_GREY)
	foot.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	foot.position = Vector2(0, get_viewport_rect().size.y - 30)
	foot.size = Vector2(get_viewport_rect().size.x, 26)
	add_child(foot)
	get_tree().root.size_changed.connect(func():
		if is_instance_valid(foot):
			foot.position = Vector2(0, get_viewport_rect().size.y - 30)
			foot.size = Vector2(get_viewport_rect().size.x, 26)
	)


func _center_control(c: Control) -> void:
	await get_tree().process_frame
	await get_tree().process_frame
	if not is_instance_valid(c):
		return
	var vp := get_viewport_rect().size
	c.position = (vp - c.size) * 0.5


func _show_help() -> void:
	var w := UIU.make_window(self, "操作说明 · 边境检查员手册（员工版）", Vector2(640, 420))
	var c: VBoxContainer = w["content"]
	c.add_child(UIU.rich("""
[center][color=#d9dcc8]工 作 流 程[/color][/center]

1. 旅客递上[color=#c9a227]设备入境卡[/color]，卡片字段逐日增多。
2. 用桌面中央的工具核验：[color=#d9dcc8]规则手册（R）[/color]、[color=#d9dcc8]IP 查询终端（Q）[/color]、[color=#d9dcc8]放大镜（E）[/color]。
3. 判断后盖章：[color=#3e7d3a]准予（A）[/color] / [color=#c23b22]拒绝（D）[/color]；突击测谎日会出现 [color=#c9a227]拘留[/color]。
4. 盖章不可撤销。慢了，排队的人会抗议。

[color=#7a7f72]提示：卡片上的「IP 归属地」是旅客自己写的。真假，要用查询终端验证。[/color]
[color=#7a7f72]提示：放大镜悬停在可疑字段（BIN、网络配置、支付方式）上，能看到细节。[/color]
[color=#7a7f72]提示：良心值打不满也没有奖励。它只决定最后一天，你还剩几个选择。[/color]
""", 15))


signal finished


class _Deco extends Node2D:
	func _draw() -> void:
		# 铁皮墙纹
		for x in range(0, 1296, 86):
			draw_line(Vector2(x, 0), Vector2(x, 722), Color(0, 0, 0, 0.12), 2.0)
		for y in range(0, 736, 110):
			draw_line(Vector2(0, y), Vector2(1282, y), Color(0, 0, 0, 0.08), 2.0)
		# 灯
		draw_line(Vector2(640, 0), Vector2(640, 80), Color(0.1, 0.1, 0.1), 4.0)
		draw_circle(Vector2(640, 86), 12.0, Color(1.0, 0.95, 0.7))
		draw_circle(Vector2(640, 86), 26.0, Color(1.0, 0.95, 0.7, 0.15))
