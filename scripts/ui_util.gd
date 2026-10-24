class_name UIU
extends RefCounted
## UI 工具：系统字体、配色、控件工厂、可拖动窗口。


const COL_BG := Color("2e342b")            # 墙面深灰绿
const COL_BG2 := Color("3d4438")           # 墙面
const COL_DESK := Color("8a6f4d")          # 桌面木色
const COL_DESK_DARK := Color("6b543a")
const COL_PAPER := Color("d8cfae")         # 纸张
const COL_PAPER_DARK := Color("c4b995")
const COL_TEXT := Color("1d1f1a")
const COL_TEXT_LIGHT := Color("d9dcc8")
const COL_RED := Color("c23b22")
const COL_GREEN := Color("3e7d3a")
const COL_YELLOW := Color("c9a227")
const COL_GREY := Color("7a7f72")
const COL_INK := Color("3a3f8f")           # 印刷蓝
const COL_HAND := Color("b3261e")          # 手写红
const COL_LAMP := Color(1.0, 0.95, 0.75, 0.07)

static var _font: SystemFont
static var _kai: SystemFont
static var _mono: SystemFont


static func font() -> SystemFont:
	if _font == null:
		_font = SystemFont.new()
		_font.font_names = PackedStringArray([
			"Microsoft YaHei UI", "Microsoft YaHei", "SimHei", "Noto Sans CJK SC", "sans-serif",
		])
	return _font


static func kai() -> SystemFont:
	if _kai == null:
		_kai = SystemFont.new()
		_kai.font_names = PackedStringArray(["KaiTi", "楷体", "STKaiti", "Microsoft YaHei"])
	return _kai


static func mono() -> SystemFont:
	if _mono == null:
		_mono = SystemFont.new()
		_mono.font_names = PackedStringArray(["Consolas", "Cascadia Mono", "Courier New", "Microsoft YaHei"])
	return _mono


static func label(text: String, size: int = 16, color: Color = COL_TEXT, use_kai: bool = false) -> Label:
	var l := Label.new()
	l.text = text
	l.add_theme_font_override("font", kai() if use_kai else font())
	l.add_theme_font_size_override("font_size", size)
	l.add_theme_color_override("font_color", color)
	return l


static func rich(text: String, size: int = 15, color: Color = COL_TEXT, use_kai: bool = false) -> RichTextLabel:
	var r := RichTextLabel.new()
	r.bbcode_enabled = true
	r.fit_content = true
	r.scroll_active = false
	r.append_text(text)
	r.add_theme_font_override("normal_font", kai() if use_kai else font())
	r.add_theme_font_override("bold_font", kai() if use_kai else font())
	r.add_theme_font_size_override("normal_font_size", size)
	r.add_theme_font_size_override("bold_font_size", size)
	r.add_theme_color_override("default_color", color)
	return r


static func sbox(bg: Color, border: Color = Color.TRANSPARENT, bw: int = 1, radius: int = 3) -> StyleBoxFlat:
	var sb := StyleBoxFlat.new()
	sb.bg_color = bg
	sb.border_color = border
	sb.set_border_width_all(bw)
	sb.set_corner_radius_all(radius)
	sb.content_margin_left = 8
	sb.content_margin_right = 8
	sb.content_margin_top = 5
	sb.content_margin_bottom = 5
	return sb


static func panel(bg: Color, border: Color = Color.TRANSPARENT, bw: int = 1, radius: int = 3) -> Panel:
	var p := Panel.new()
	p.add_theme_stylebox_override("panel", sbox(bg, border, bw, radius))
	return p


static func button(text: String, size: int = 15, cb: Callable = Callable(), bg: Color = Color("4a5244"), fg: Color = COL_TEXT_LIGHT) -> Button:
	var b := Button.new()
	b.text = text
	b.add_theme_font_override("font", font())
	b.add_theme_font_size_override("font_size", size)
	b.add_theme_color_override("font_color", fg)
	b.add_theme_color_override("font_hover_color", Color.WHITE)
	b.add_theme_color_override("font_pressed_color", fg.darkened(0.3))
	b.add_theme_color_override("font_disabled_color", fg.darkened(0.55))
	b.add_theme_stylebox_override("normal", sbox(bg, bg.darkened(0.4), 1, 3))
	b.add_theme_stylebox_override("hover", sbox(bg.lightened(0.12), bg.darkened(0.4), 1, 3))
	b.add_theme_stylebox_override("pressed", sbox(bg.darkened(0.2), bg.darkened(0.4), 1, 3))
	b.add_theme_stylebox_override("disabled", sbox(bg.darkened(0.35), bg.darkened(0.5), 1, 3))
	b.add_theme_stylebox_override("focus", StyleBoxEmpty.new())
	if cb.is_valid():
		b.pressed.connect(cb)
	return b


static func vsep(h: int = 8) -> Control:
	var c := Control.new()
	c.custom_minimum_size = Vector2(0, h)
	return c


static func hsep(w: int = 8) -> Control:
	var c := Control.new()
	c.custom_minimum_size = Vector2(w, 0)
	return c


## 居中带标题栏 + 关闭按钮的窗口。返回 { win, content, close }
static func make_window(parent: Control, title: String, size: Vector2) -> Dictionary:
	var win := Panel.new()
	win.custom_minimum_size = size
	win.size = size
	win.add_theme_stylebox_override("panel", sbox(Color("262b22"), Color("565e4e"), 2, 4))
	parent.add_child(win)
	# 居中并夹在可视区内；视口尺寸变化（F11 全屏/还原、窗口拉伸）时自动重新居中
	var user_dragged := {"v": false}
	var recenter := func() -> void:
		if user_dragged["v"]:
			return
		var vps := win.get_viewport_rect().size
		var mx := Vector2(vps.x - win.size.x, vps.y - win.size.y).max(Vector2.ZERO)
		win.position = ((vps - win.size) * 0.5).clamp(Vector2.ZERO, mx)
		if Game.test_mode:
			print("WIN_DIAG parent.size=", parent.size, " vp=", vps, " winsize=", win.size, " pos=", win.position, " winscale=", win.get_global_transform().get_scale())
	parent.get_tree().root.size_changed.connect(recenter)
	win.tree_exited.connect(func() -> void:
		var tree := parent.get_tree()
		if tree != null:
			tree.root.size_changed.disconnect(recenter)
	)
	recenter.call()

	var bar := Panel.new()
	bar.custom_minimum_size = Vector2(size.x, 34)
	bar.position = Vector2(0, 0)
	bar.size = Vector2(size.x, 34)
	var bar_sb := sbox(Color("39412f"), Color("565e4e"), 0, 0)
	bar_sb.border_color = Color("6a7360")
	bar_sb.border_width_bottom = 2
	bar.add_theme_stylebox_override("panel", bar_sb)
	win.add_child(bar)

	var title_l := label(title, 15, COL_TEXT_LIGHT)
	title_l.position = Vector2(12, 7)
	bar.add_child(title_l)

	var content := VBoxContainer.new()
	content.position = Vector2(12, 44)
	content.size = Vector2(size.x - 24, size.y - 56)
	content.add_theme_constant_override("separation", 6)
	win.add_child(content)

	var closed := false
	var close := func() -> void:
		if not closed:
			closed = true
			win.queue_free()
	var close_b := button("× 关闭", 14, close, Color("6b3a30"))
	close_b.position = Vector2(size.x - 84, 4)
	close_b.size = Vector2(76, 26)
	bar.add_child(close_b)

	# 标题栏拖动：全局坐标 + 任何按键松开即停 + 永远夹在屏幕内
	var dragging := {"on": false, "off": Vector2.ZERO}
	bar.gui_input.connect(func(ev: InputEvent) -> void:
		if ev is InputEventMouseButton:
			if ev.button_index == MOUSE_BUTTON_LEFT and ev.pressed:
				dragging["on"] = true
				user_dragged["v"] = true
				dragging["off"] = win.global_position - ev.global_position
			else:
				dragging["on"] = false
		elif ev is InputEventMouseMotion and dragging["on"]:
			var target: Vector2 = ev.global_position + dragging["off"]
			var vp2 := win.get_viewport_rect().size
			var max_p := Vector2(vp2.x - win.size.x, vp2.y - win.size.y).max(Vector2.ZERO)
			win.global_position = target.clamp(Vector2.ZERO, max_p)
	)
	return {"win": win, "content": content, "close": close}


static func hearts_bar() -> Control:
	var hb: Control = load("res://scripts/hearts.gd").new()
	return hb
