class_name FinalDay
extends Control
## 最终日：旅客是你自己。军官让你测暗号。然后是待审核室。

signal finished(ending_id: String)

var _step := 0
var _name := "检察官"


func _ready() -> void:
	_name = OS.get_environment("USERNAME")
	if _name == "" or _name == "li":
		_name = "检察官·%s" % (_name if _name != "" else "无名氏")
	var bg := UIU.panel(Color("22261e"))
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(bg)
	var wall := _Wall.new()
	add_child(wall)
	_run()


func _run() -> void:
	await Game.wait(0.4)
	var banner := UIU.label("第 9 天 · %s" % Rules.day_date(9), 30, UIU.COL_TEXT_LIGHT)
	banner.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	banner.position = Vector2(0, 60)
	banner.size = Vector2(1280, 40)
	add_child(banner)
	var sub := UIU.label("照常上班。日光灯嗡嗡作响。", 16, UIU.COL_GREY)
	sub.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	sub.position = Vector2(0, 104)
	sub.size = Vector2(1280, 24)
	add_child(sub)
	await Game.wait(1.6)

	# 旅客 = 你
	var me := Portrait.new()
	me.set_look({"skin": Color("d9a679"), "hair": Color("3a2a1c"), "hair_style": 0, "clothes": Color("4a543c")})
	me.set_expression("calm")
	me.position = Vector2(230, 250)
	add_child(me)
	Sfx.play("steps", -10.0)
	var tw := create_tween()
	tw.tween_property(me, "position:x", 230.0, 0.01)
	await Game.wait(0.6)

	var card_panel := UIU.panel(UIU.COL_PAPER, Color("8a8060"), 2, 3)
	card_panel.position = Vector2(410, 120)
	card_panel.size = Vector2(560, 330)
	add_child(card_panel)
	var ct := UIU.label("设备入境卡 · DEVICE ENTRY CARD", 15, UIU.COL_INK)
	ct.position = Vector2(20, 10)
	card_panel.add_child(ct)

	var tz := Time.get_time_zone_from_system()
	var bias: int = int(tz.get("bias", 480))
	var sign := "+" if bias >= 0 else "-"
	var ab := absi(bias)
	var tz_txt := "UTC%s%02d:%02d" % [sign, int(ab / 60), ab % 60]
	var rows := [
		["姓　名", _name + "（你）"],
		["IP 地址", "192.168.1.？（家）"],
		["实际归属", "中国·你家"],
		["系统时区", tz_txt + "（你此刻的时区）"],
		["系统语言", OS.get_locale() + "（你此刻的语言）"],
		["支付方式", "银联（工资卡）"],
		["网络配置", "api.anthropic.com"],
	]
	for i in rows.size():
		var l := UIU.label(String(rows[i][0]) + "：", 14, UIU.COL_GREY)
		l.position = Vector2(20, 42 + i * 28)
		card_panel.add_child(l)
		var v := UIU.label(String(rows[i][1]), 14, UIU.COL_TEXT)
		v.position = Vector2(130, 42 + i * 28)
		card_panel.add_child(v)

	var warn := UIU.label("⚠ 历史记录：relay-mirror.example ×1（你测试工具时用过一次）", 13, UIU.COL_RED)
	warn.position = Vector2(20, 42 + rows.size() * 28 + 6)
	card_panel.add_child(warn)

	var bubble := UIU.label("下一位。", 17, UIU.COL_TEXT_LIGHT, true)
	bubble.position = Vector2(410, 470)
	add_child(bubble)
	await Game.wait(2.0)

	# 军官进场
	var off := Portrait.new()
	off.set_look({"skin": Color("d9a679"), "hair": Color("2a2a2a"), "hair_style": 3,
		"hat": "military", "clothes": Color("4a543c")})
	off.set_expression("still")
	off.scale = Vector2(0.8, 0.8)
	off.position = Vector2(480, 240)
	add_child(off)
	var tw2 := create_tween()
	tw2.tween_property(off, "position:x", 350.0, 0.6)
	Sfx.stop_ambient()
	Sfx.play("shoes", -6.0)
	Sfx.start_heartbeat()
	await Game.wait(0.8)

	var q := UIU.label("军官：检察官，例行核查。请回答——宫廷玉液酒？", 20, UIU.COL_RED, true)
	q.position = Vector2(320, 520)
	add_child(q)

	var chose := {"v": ""}
	var b1 := UIU.button("（脱口而出）一百八一杯", 18, func():
		if chose["v"] == "":
			chose["v"] = "answer"
	, Color("5a3a30"))
	b1.position = Vector2(430, 570)
	b1.size = Vector2(240, 52)
	add_child(b1)
	var b2 := UIU.button("（沉默，装听不懂）", 18, func():
		if chose["v"] == "":
			chose["v"] = "silent"
	, Color("3a4250"))
	b2.position = Vector2(700, 570)
	b2.size = Vector2(240, 52)
	add_child(b2)

	if Game.test_mode:
		chose["v"] = "answer"
	while chose["v"] == "":
		await Game.wait(0.05)
	b1.queue_free()
	b2.queue_free()
	q.queue_free()

	var verdict: Label
	if chose["v"] == "answer":
		verdict = UIU.label("军官：……嗯。答得很快。", 17, UIU.COL_RED, true)
	else:
		verdict = UIU.label("军官：不答？不重要。", 17, UIU.COL_RED, true)
	verdict.position = Vector2(430, 520)
	add_child(verdict)
	Sfx.play("knock", -8.0)
	await Game.wait(1.4)

	verdict.text = "系统已判定：你的设备入境卡存在「历史中转站访问记录」。"
	await Game.wait(1.6)
	verdict.text = "请交出印章。进入待审核室。"
	Sfx.play("stamp_deny", -4.0)
	Sfx.stop_heartbeat()
	await Game.wait(1.6)

	# 待审核室
	for c in get_children():
		if c is Button:
			c.queue_free()
	var dim := ColorRect.new()
	dim.color = Color(0.02, 0.02, 0.04, 0.0)
	dim.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(dim)
	var twd := create_tween()
	twd.tween_property(dim, "color:a", 0.92, 1.0)
	await twd.finished

	var room := UIU.label("待 审 核 室", 40, UIU.COL_TEXT_LIGHT)
	room.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	room.position = Vector2(0, 120)
	room.size = Vector2(1280, 50)
	add_child(room)
	var note := UIU.label("桌上一盏台灯。一份《清白证明申请表》。一支笔。", 15, UIU.COL_GREY)
	note.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	note.position = Vector2(0, 180)
	note.size = Vector2(1280, 24)
	add_child(note)
	await Game.wait(1.0)

	var picked := {"v": ""}
	var bA := UIU.button("结局 A ｜ 上传护照、人脸、股权证明\n（顺从：证明清白，保住工作）", 17, func():
		if picked["v"] == "":
			picked["v"] = "A"
	, Color("3e5a3a"))
	bA.position = Vector2(240, 300)
	bA.size = Vector2(380, 110)
	add_child(bA)
	var bB := UIU.button("结局 B ｜ 拒绝验证，摘下工牌\n（觉醒：走出检查站）", 17, func():
		if picked["v"] == "":
			picked["v"] = "B"
	, Color("5a3a30"))
	bB.position = Vector2(680, 300)
	bB.size = Vector2(380, 110)
	add_child(bB)

	if Game.conscience <= 0:
		bA.disabled = true
		var lock := UIU.label("（申诉通道对你的信任评级已关闭。你只剩一个选择。）", 13, UIU.COL_RED)
		lock.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		lock.position = Vector2(0, 440)
		lock.size = Vector2(1280, 24)
		add_child(lock)

	if Game.test_mode:
		picked["v"] = "B"
	while picked["v"] == "":
		await Game.wait(0.05)
	finished.emit(String(picked["v"]))


class _Wall extends Node2D:
	func _draw() -> void:
		draw_rect(Rect2(70, 70, 320, 330), Color("5c6258"))
		draw_rect(Rect2(64, 64, 332, 342), Color("4a4234"), false, 12.0)
		draw_line(Vector2(230, 70), Vector2(230, 400), Color("4a4234"), 6.0)
		draw_rect(Rect2(0, 414, 1280, 10), UIU.COL_DESK_DARK)
		draw_rect(Rect2(0, 424, 1280, 296), UIU.COL_DESK)
		draw_line(Vector2(640, 0), Vector2(640, 92), Color(0.12, 0.12, 0.12), 5.0)
		draw_circle(Vector2(640, 112), 10.0, Color(1.0, 0.96, 0.72))
