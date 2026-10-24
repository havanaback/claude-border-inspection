extends Control
## 场景路由：标题 → [加载 → 日开场 → 检查台 → 日结算] × 8 → 最终日 → 结局 → 制作名单。


var current: Control = null
var _fade: ColorRect


func _ready() -> void:
	Game.test_mode = OS.get_cmdline_user_args().has("--auto-test")
	for arg in OS.get_cmdline_user_args():
		if arg.begins_with("--shot="):
			Game.shot = arg.substr(7)
			Game.test_mode = true
			Game.speed = 0.2
	if Game.test_mode:
		Game.speed = 0.2 if Game.shot != "" else 0.05
	DisplayServer.window_set_title("边境检察官：Claude 入境审查")

	_fade = ColorRect.new()
	_fade.color = Color.BLACK
	_fade.set_anchors_preset(Control.PRESET_FULL_RECT)
	# 关键：平时必须 IGNORE——透明不等于不拦截，STOP 会把整屏点击全部吞掉
	_fade.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_fade.modulate.a = 0.0
	add_child(_fade)

	if Game.shot == "title_click":
		Game.test_mode = true
		Game.speed = 1.0
	if Game.test_mode:
		Game.reset_run()
		if Game.shot == "title" or Game.shot == "title_click":
			var ts := Title.new()
			_mount(ts)
			if Game.shot == "title_click":
				_click_test(ts)
		else:
			_goto_day(Game.day)
	else:
		var title := Title.new()
		title.finished.connect(func(): _goto_day(Game.day))
		_mount(title)


func _mount(scene: Control, params: Dictionary = {}) -> void:
	if current != null:
		current.queue_free()
	current = scene
	if scene.has_method("setup"):
		scene.setup(params)
	add_child(scene)
	scene.set_anchors_preset(Control.PRESET_FULL_RECT)
	# 黑幕保持在最上层，转场时才能真正盖住画面（后加的场景会绘制在其上）
	move_child(_fade, get_child_count() - 1)


func _fade_to(alpha: float, dur: float) -> void:
	var tw := create_tween()
	tw.tween_property(_fade, "modulate:a", alpha, dur)
	await tw.finished


## 异步换场（黑屏过渡）
func swap(scene: Control, params: Dictionary = {}) -> void:
	_fade.mouse_filter = Control.MOUSE_FILTER_STOP
	await _fade_to(1.0, 0.25)
	_mount(scene, params)
	await _fade_to(0.0, 0.25)
	_fade.mouse_filter = Control.MOUSE_FILTER_IGNORE


## 加载画面 → 开场某一天
func _goto_day(day: int) -> void:
	if not Game.test_mode:
		await _loading_screen()
	var intro := DayIntro.new()
	intro.finished.connect(func():
		var booth := Booth.new()
		booth.setup({"day": day})
		booth.finished.connect(func():
			var sum := Summary.new()
			sum.setup({"day": day})
			sum.finished.connect(func():
				if day < Game.TOTAL_DAYS:
					Game.day = day + 1
					Game.save_game()
					_goto_day(Game.day)
				else:
					var fin := FinalDay.new()
					fin.finished.connect(func(ending_id: String):
						var ending := Ending.new()
						ending.setup({"ending": ending_id})
						ending.finished.connect(func():
							var cr := Credits.new()
							cr.finished.connect(func():
								Game.clear_save()
								var t := Title.new()
								swap(t)
							)
							swap(cr)
						)
						swap(ending, {"ending": ending_id})
					)
					swap(fin)
			)
			swap(sum, {"day": day})
		)
		swap(booth, {"day": day})
	)
	swap(intro, {"day": day})


## 讽刺加载界面
func _loading_screen() -> void:
	var dim := ColorRect.new()
	dim.color = Color(0.02, 0.02, 0.03, 0.92)
	dim.set_anchors_preset(Control.PRESET_FULL_RECT)
	dim.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(dim)

	var big := UIU.label("正在验证您的身份……", 26, UIU.COL_TEXT_LIGHT)
	big.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	big.set_anchors_preset(Control.PRESET_CENTER)
	big.grow_horizontal = Control.GROW_DIRECTION_BOTH
	big.position = Vector2(0, 300)
	big.size = Vector2(1280, 40)
	dim.add_child(big)

	var lines := Rules.loading_lines()
	for i in 5:
		big.text = lines[i % lines.size()]
		Sfx.play("beep", -14.0, 0.8 + 0.1 * i)
		await Game.wait(0.4)

	var cite := UIU.label(Rules.citations()[Game.day % Rules.citations().size()], 11, Color(0.45, 0.47, 0.42))
	cite.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	cite.position = Vector2(0, 660)
	cite.size = Vector2(1280, 30)
	dim.add_child(cite)
	await Game.wait(0.5)
	# 平滑淡出，避免幕布瞬间消失时旧画面闪现（转场黑幕在其上方同步接管）
	var tw := create_tween()
	tw.tween_property(dim, "color:a", 0.0, 0.55)
	tw.tween_callback(dim.queue_free)


## 自动点击验证：向标题页的“开始上班”注入真实鼠标事件，确认点击不再被透明层吞掉
func _click_test(title: Control) -> void:
	await get_tree().create_timer(1.2).timeout
	var btn: Button = null
	for n in title.find_children("*", "Button", true, false):
		var b := n as Button
		if b.text.contains("开始上班") or b.text.contains("继续上班"):
			btn = b
			break
	if btn == null:
		print("CLICK_TEST: no button found")
		Game.take_shot("title_click")
		return
	var gp := btn.get_global_rect().get_center()
	var ev := InputEventMouseButton.new()
	ev.position = gp
	ev.global_position = gp
	ev.button_index = MOUSE_BUTTON_LEFT
	ev.pressed = true
	Input.parse_input_event(ev)
	var ev2 := ev.duplicate()
	ev2.pressed = false
	Input.parse_input_event(ev2)
	print("CLICK_TEST: clicked ", btn.text, " at ", gp)
	await get_tree().create_timer(2.0).timeout
	Game.take_shot("title_click")


## F11 切换全屏 / 窗口
func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo:
		if event.keycode == KEY_F11:
			if DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_FULLSCREEN:
				DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
			else:
				DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
