class_name Credits
extends Control
## 制作名单 + 免责声明 + 来源标注。

signal finished


func _ready() -> void:
	var bg := UIU.panel(Color("191c16"))
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(bg)

	var box := VBoxContainer.new()
	box.position = Vector2(340, 700)
	box.add_theme_constant_override("separation", 12)
	add_child(box)

	var add := func(t: String, size: int, col: Color) -> Label:
		var l := UIU.label(t, size, col)
		l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		l.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		box.add_child(l)
		return l

	add.call("边境检察官：Claude 入境审查", 30, UIU.COL_TEXT_LIGHT)
	add.call("Papers, please. 以及你的时区，你的语言包，还有你的宫廷玉液酒。", 14, UIU.COL_GREY)
	box.add_child(UIU.vsep(20))
	add.call("设计 / 程序 / 像素 / 合成音效", 14, UIU.COL_GREY)
	add.call("ZCode × GLM", 22, UIU.COL_TEXT_LIGHT)
	box.add_child(UIU.vsep(20))
	add.call("旅客头像、背景、印章、音效均为程序化生成", 13, UIU.COL_GREY)
	add.call("（无任何外部素材，欢迎拆包检查）", 13, UIU.COL_GREY)
	box.add_child(UIU.vsep(20))
	add.call("致敬", 14, UIU.COL_GREY)
	add.call("Lucas Pope《Papers, Please》(2013)", 18, UIU.COL_TEXT_LIGHT)
	box.add_child(UIU.vsep(20))
	add.call("本作纯属虚构。所有「规则」均为对真实事件的黑色幽默改编：", 13, UIU.COL_GREY)
	add.call("· 2025年1月，Anthropic 向部分中国用户发送「立即封禁」邮件，约145万账号受影响", 12, UIU.COL_GREY)
	add.call("· 约1700名用户提交申诉；有用户报告申诉后解封，亦有石沉大海者", 12, UIU.COL_GREY)
	add.call("· 地区白名单、时区/语言一致性、支付核验、组织连坐——均取材于用户社区的真实遭遇", 12, UIU.COL_GREY)
	box.add_child(UIU.vsep(20))
	add.call("「规则不是为了让人遵守，", 16, Color("c9a227"))
	add.call("而是为了让你永远处于可能违规的状态。」", 16, Color("c9a227"))
	box.add_child(UIU.vsep(26))
	add.call("感谢游玩。", 20, UIU.COL_TEXT_LIGHT)

	var tw := create_tween()
	tw.tween_property(box, "position:y", -820.0, 22.0).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_LINEAR)

	var back := UIU.button("返回标题", 16, func(): finished.emit(), Color("3e5a3a"))
	back.position = Vector2(540, 672)
	add_child(back)
	Sfx.play("page", -10.0)

	if Game.test_mode:
		print("AUTOTEST_OK ending=", Game.ending_reached)
		await Game.wait(0.2)
		get_tree().quit(0)
