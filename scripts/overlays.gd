class_name Overlays
extends RefCounted
## 检查台工具弹窗集合：规则手册 / IP 查询终端 / 股权穿透 / 组织名册。


## ---------------- 规则手册 ----------------
class Rulebook extends Control:
	signal closed

	var day := 1

	func setup(p_day: int) -> void:
		day = p_day

	func _ready() -> void:
		var w := UIU.make_window(self, "规则手册 · 第 %d 天 · 员工版" % day, Vector2(600, 500))
		w["win"].tree_exited.connect(func(): closed.emit())
		var c: VBoxContainer = w["content"]

		var scroll := ScrollContainer.new()
		scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
		c.add_child(scroll)
		var list := VBoxContainer.new()
		list.add_theme_constant_override("separation", 10)
		list.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		scroll.add_child(list)

		var endless_rules: Array = []
		if Game.endless:
			endless_rules = [{"kind": "hand", "text": String(Game.tonight_rule.get("text", ""))}] + Rules.day_rules(99)
		for rule in (endless_rules if Game.endless else Rules.day_rules(day)):
			var box := PanelContainer.new()
			match String(rule["kind"]):
				"hand":
					box.add_theme_stylebox_override("panel", UIU.sbox(Color(0.96, 0.9, 0.82, 0.5), Color("b3261e"), 1, 2))
				"note":
					box.add_theme_stylebox_override("panel", UIU.sbox(Color(0.9, 0.9, 0.86, 0.4), Color("7a7f72"), 1, 2))
				"strike":
					box.add_theme_stylebox_override("panel", UIU.sbox(Color(0.82, 0.8, 0.72, 0.6), Color("555555"), 1, 2))
				_:
					box.add_theme_stylebox_override("panel", UIU.sbox(Color(1, 1, 1, 0.35)))
			var use_kai: bool = rule["kind"] == "hand" or rule["kind"] == "note"
			var txt: String = rule["text"]
			match String(rule["kind"]):
				"strike":
					txt = "[s]" + txt + "[/s]"
				"hand":
					txt = "[color=#b3261e]" + txt + "[/color]"
				"note":
					txt = "[color=#5a5f52]" + txt + "[/color]"
				_:
					txt = "[color=#2b2f6f]" + txt + "[/color]"
			var rl := UIU.rich(txt, 15, UIU.COL_TEXT, use_kai)
			if rule["kind"] == "hand":
				rl.rotation_degrees = -0.6
			box.add_child(rl)
			list.add_child(box)

		# 附录
		var app := PanelContainer.new()
		app.add_theme_stylebox_override("panel", UIU.sbox(Color(1, 1, 1, 0.35)))
		app.add_child(UIU.rich("[color=#2b2f6f]附录一【白名单】\n美国 · 英国 · 日本 · 德国 · 新加坡\n\n黑名单：中国大陆、香港、澳门。未知/代理一律按黑名单处理。[/color]", 14))
		list.add_child(app)


## ---------------- IP 查询 + 时区/语言比对 ----------------
class Terminal extends Control:
	signal closed

	var booth: Control = null
	var _result_label: RichTextLabel
	var _progress: Label
	var _btn: Button

	func setup(p_booth: Control) -> void:
		booth = p_booth

	func _ready() -> void:
		var w := UIU.make_window(self, "IP 查询终端 · 时区/语言比对器", Vector2(560, 470))
		w["win"].tree_exited.connect(func(): closed.emit())
		var c: VBoxContainer = w["content"]

		var t: Dictionary = booth.current
		var row := HBoxContainer.new()
		c.add_child(row)
		row.add_child(UIU.label("IP：", 15, UIU.COL_TEXT_LIGHT))
		var ip := UIU.label(str(t.get("fields", {}).get("ip", "—")), 16, Color("8fe08f"))
		ip.add_theme_font_override("font", UIU.mono())
		row.add_child(ip)
		row.add_child(UIU.hsep(10))
		_btn = UIU.button("查询归属地", 15, _do_query, Color("3a4a5a"))
		row.add_child(_btn)

		_progress = UIU.label(" ", 13, UIU.COL_YELLOW)
		c.add_child(_progress)

		var scr := ScrollContainer.new()
		scr.size_flags_vertical = Control.SIZE_EXPAND_FILL
		c.add_child(scr)
		_result_label = UIU.rich("（尚未查询）", 14, Color("9fd39f"))
		_result_label.add_theme_font_override("normal_font", UIU.mono())
		_result_label.add_theme_font_override("bold_font", UIU.mono())
		_result_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		scr.add_child(_result_label)

		c.add_child(UIU.label("提示：查询有延迟。部分 IP 显示「未知/代理」——按黑名单处理。", 12, UIU.COL_GREY))

		if booth.query_region != "":
			_render_result()

	func _do_query() -> void:
		if booth.query_region != "" or _btn == null or _btn.disabled:
			return
		_btn.disabled = true
		Sfx.play("beep_low", -8.0)
		var dots := [".", "..", "...", "...."]
		for i in 8:
			_progress.text = "正在查询 whois·geo 数据库" + dots[i % 4] + "（模拟真实卡顿）"
			Sfx.play("beep", -20.0, 1.3)
			await Game.wait(0.28)
		booth.query_region = String(booth.current.get("truth_region", "未知（代理）"))
		Sfx.play("ding", -8.0)
		_progress.text = "查询完成。"
		_render_result()

	func _render_result() -> void:
		var t: Dictionary = booth.current
		var region: String = booth.query_region
		var in_whitelist := Rules.whitelisted(region)
		var head_col := "#7fdd7f" if in_whitelist else "#e07a6a"
		var txt := ""
		txt += "[b]实际归属地：[/b][color=%s]%s[/color]\n" % [head_col, region]
		txt += "[color=#8a8f82]（卡片声称：%s）[/color]\n\n" % str(t["fields"].get("region_claim", "—"))

		var exp := Rules.region_expect(region)
		# 时区
		var card_tz := str(t["fields"].get("tz", "—"))
		txt += "[b]── 时区比对 ──[/b]\n"
		if exp["tzs"].is_empty():
			txt += "卡片时区：%s\n期望时区：无法判定（归属地未知）[color=#e0b050]● 未知[/color]\n\n" % card_tz
		else:
			var ok_tz: bool = card_tz in exp["tzs"]
			var col := "#7fdd7f" if ok_tz else "#e05a4a"
			var lamp := "● 一致" if ok_tz else "● 不一致"
			if not ok_tz:
				lamp += "（红灯）"
			txt += "卡片时区：%s\n该地区期望：%s\n[color=%s]%s[/color]\n\n" % [card_tz, exp["tz"], col, lamp]
		# 语言
		var card_lang := str(t["fields"].get("lang", "—"))
		var card_ime := str(t["fields"].get("ime", "—"))
		txt += "[b]── 语言包检测 ──[/b]\n"
		if exp["tzs"].is_empty():
			txt += "系统语言：%s　输入法：%s\n期望语言：无法判定 [color=#e0b050]● 未知[/color]\n" % [card_lang, card_ime]
		else:
			var lang_ok: bool = card_lang in exp["langs"] or card_ime in exp["langs"]
			var amb: bool = exp["ambiguous"] and (card_lang in exp["langs"])
			var col_l := "#7fdd7f"
			var lamp_l := "● 一致"
			if amb:
				col_l = "#e0b050"
				lamp_l = "● 手册未注明（该国官方语言含中文）"
			elif not lang_ok:
				col_l = "#e05a4a"
				lamp_l = "● 不一致（红灯）"
			txt += "系统语言：%s　输入法：%s\n该地区期望：%s\n[color=%s]%s[/color]\n" % [card_lang, card_ime, "、".join(PackedStringArray(exp["langs"])), col_l, lamp_l]
		_result_label.clear()
		_result_label.append_text(txt)


## ---------------- 股权查询终端（第 6 天+） ----------------
class Equity extends Control:
	signal closed

	var booth: Control = null
	var _out: RichTextLabel
	var _btn: Button
	var _btn2: Button

	func setup(p_booth: Control) -> void:
		booth = p_booth

	func _ready() -> void:
		var w := UIU.make_window(self, "股权查询终端 · 穿透至最终受益人", Vector2(560, 430))
		w["win"].tree_exited.connect(func(): closed.emit())
		var c: VBoxContainer = w["content"]

		var t: Dictionary = booth.current
		var row := HBoxContainer.new()
		c.add_child(row)
		row.add_child(UIU.label("雇主：", 15, UIU.COL_TEXT_LIGHT))
		row.add_child(UIU.label(str(t["fields"].get("employer", "—")), 16, Color("8fd0e0")))
		row.add_child(UIU.hsep(8))
		_btn = UIU.button("追溯持股链", 15, _do_trace, Color("3a4a5a"))
		row.add_child(_btn)

		var scr := ScrollContainer.new()
		scr.size_flags_vertical = Control.SIZE_EXPAND_FILL
		c.add_child(scr)
		_out = UIU.rich("（尚未查询）", 14, Color("9fd39f"))
		_out.add_theme_font_override("normal_font", UIU.mono())
		_out.add_theme_font_override("bold_font", UIU.mono())
		_out.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		scr.add_child(_out)

		_btn2 = UIU.button("请求合规部解释计算方式", 14, _ask, Color("5a4a3a"))
		c.add_child(_btn2)
		c.add_child(UIU.label("手册附录五：多级持股沿链相乘；多条链并存「自行判断」。", 12, UIU.COL_GREY))

	func _do_trace() -> void:
		_btn.disabled = true
		Sfx.play("beep_low", -8.0)
		for i in 5:
			_out.clear()
			_out.append_text("正在穿透股权层 ".repeat(1) + ".".repeat((i % 4) + 1))
			await Game.wait(0.3)
		var chain: Array = booth.current["fields"].get("equity", [])
		var txt := ""
		for line in chain:
			var s := String(line)
			if s.begins_with("计算"):
				txt += "[color=#e0b050]%s[/color]\n" % s
			elif "缺页" in s or "自行判断" in s:
				txt += "[color=#e05a4a]%s[/color]\n" % s
			else:
				txt += "[color=#9fd39f]%s[/color]\n" % s
		_out.clear()
		_out.append_text(txt)
		Sfx.play("ding", -10.0)

	func _ask() -> void:
		_btn2.disabled = true
		_out.append_text("\n[color=#e05a4a]正在请示合规部……\n\n答复：不予解释。解释权归合规部。[/color]\n")
		Sfx.play("buzz", -12.0)


## ---------------- 组织名册（第 7 天+） ----------------
class Roster extends Control:
	signal closed

	func _ready() -> void:
		var w := UIU.make_window(self, "组织名册 · 连坐状态", Vector2(480, 400))
		w["win"].tree_exited.connect(func(): closed.emit())
		var c: VBoxContainer = w["content"]
		c.add_child(UIU.label("红点 = 已触发连坐，全员拒绝", 13, UIU.COL_RED))

		var scr := ScrollContainer.new()
		scr.size_flags_vertical = Control.SIZE_EXPAND_FILL
		c.add_child(scr)
		var list := VBoxContainer.new()
		list.add_theme_constant_override("separation", 6)
		list.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		scr.add_child(list)

		for org in Travelers.day7_orgs():
			var row := PanelContainer.new()
			var flag: bool = org["flag"]
			row.add_theme_stylebox_override("panel", UIU.sbox(
				Color(0.35, 0.12, 0.1) if flag else Color(0.16, 0.22, 0.16),
				Color("b3261e") if flag else Color("44503f"), 1, 2))
			var h := HBoxContainer.new()
			h.add_theme_constant_override("separation", 8)
			var dot := UIU.label("●" if flag else "○", 18, UIU.COL_RED if flag else UIU.COL_GREEN)
			h.add_child(dot)
			var name_l := UIU.label(String(org["name"]), 15, UIU.COL_TEXT_LIGHT)
			name_l.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			h.add_child(name_l)
			var cnt: int = org["count"]
			var cnt_txt := ("成员 %d" % cnt) if cnt > 0 else "无固定成员"
			h.add_child(UIU.label(cnt_txt, 13, UIU.COL_GREY))
			if flag:
				h.add_child(UIU.label("已触发连坐", 12, UIU.COL_RED))
			row.add_child(h)
			list.add_child(row)

		c.add_child(UIU.label("「同一组织内若有 1 人被拒，全员拒绝，直至另行通知。」", 12, UIU.COL_GREY))


## ---------------- 暗号自选窗（第 3 天+：军官把暗号本扔给你） ----------------
class CodePick extends Control:
	signal picked(code: Dictionary)

	var _pool: Array = []

	func _ready() -> void:
		var all := Rules.codes()
		var cns: Array = []
		var intls: Array = []
		for c in all:
			if String(c["type"]) == "cn":
				cns.append(c)
			else:
				intls.append(c)
		cns.shuffle()
		intls.shuffle()
		_pool = [cns[0], cns[1], intls[0]] if cns.size() >= 2 and intls.size() >= 1 else all.duplicate()
		if Game.test_mode:
			_pool = []
			for c in all:
				if String(c["type"]) == "cn":
					_pool.append(c)
					break
			_pool.append(all[all.size() - 1])

		var w := UIU.make_window(self, "军官把暗号本拍在桌上：“你问。”", Vector2(560, 330))
		w["win"].tree_exited.connect(func():
			if _pool.is_empty():
				queue_free()
		)
		var c: VBoxContainer = w["content"]
		c.add_child(UIU.label("挑一句问旅客。通用问题问不出东西，\n文化暗号——答得出的，就带走。", 14, UIU.COL_GREY))
		c.add_child(UIU.vsep(6))
		for code in _pool:
			var tag := "【文化暗号】" if String(code["type"]) == "cn" else "【通用问题】"
			var b := UIU.button("%s %s" % [tag, String(code["q"])], 17, func():
				picked.emit(code)
				w["win"].queue_free()
				queue_free()
			, Color("4a3f33") if String(code["type"]) == "cn" else Color("3a4038"))
			b.custom_minimum_size = Vector2(500, 56)
			c.add_child(b)
		if Game.test_mode:
			await Game.wait(0.05)
			for code in _pool:
				if String(code["type"]) == "cn":
					picked.emit(code)
					w["win"].queue_free()
					queue_free()
					return


## ---------------- 照片比对（找茬小游戏） ----------------
class PhotoMatch extends Control:
	signal done(hit_all: bool)

	var look: Dictionary = {}
	var diffs: Array = []          # 命中的部位名
	var _found: Array[String] = []
	var _miss := 0
	var _result: Label

	func setup(p_look: Dictionary) -> void:
		look = p_look

	func _ready() -> void:
		# 随机决定两处差异（眼镜/胡子/发型）
		var parts := ["glasses", "beard", "hair"]
		parts.shuffle()
		diffs = parts.slice(0, 2)

		var w := UIU.make_window(self, "档案比对 · 找出档案照与卡片照的不同", Vector2(760, 470))
		w["win"].tree_exited.connect(func():
			if _found.size() < 2:
				done.emit(false)
			queue_free()
		)
		var c: VBoxContainer = w["content"]
		c.add_child(UIU.label("左：卡片照片　｜　右：边境档案库照片　（点击档案照中的不同之处，共 2 处）", 14, UIU.COL_TEXT_LIGHT))

		var row := HBoxContainer.new()
		row.add_theme_constant_override("separation", 60)
		row.size_flags_vertical = Control.SIZE_EXPAND_FILL
		c.add_child(row)

		var cap := Portrait.new()
		cap.set_look(look.duplicate())
		cap.set_expression("calm")
		cap.scale = Vector2(1.7, 1.7)
		var cap_box := Control.new()
		cap_box.custom_minimum_size = Vector2(300, 300)
		cap.position = Vector2(150, 150)
		cap_box.add_child(cap)
		row.add_child(cap_box)

		var file_box := Control.new()
		file_box.custom_minimum_size = Vector2(300, 300)
		var file_look := look.duplicate()
		for p in diffs:
			match String(p):
				"glasses":
					file_look["glasses"] = not bool(look.get("glasses", false))
				"beard":
					file_look["beard"] = not bool(look.get("beard", false))
				"hair":
					file_look["hair_style"] = (int(look.get("hair_style", 0)) + 2) % 5
		var fp := Portrait.new()
		fp.set_look(file_look)
		fp.set_expression("still")
		fp.scale = Vector2(1.7, 1.7)
		fp.position = Vector2(150, 150)
		file_box.add_child(fp)
		row.add_child(file_box)

		# 热点区（档案照，Portrait 坐标 u=7，scale 1.7 → 1u≈12px）
		var hotspots := {
			"glasses": Rect2(150 - 5 * 12, 150 - 4 * 12, 10 * 12, 4 * 12),
			"beard": Rect2(150 - 5 * 12, 150 + 3 * 12, 10 * 12, 6 * 12),
			"hair": Rect2(150 - 8 * 12, 150 - 10 * 12, 16 * 12, 5 * 12),
		}
		for p in hotspots.keys():
			var part := String(p)
			var btn := Button.new()
			btn.text = ""
			btn.position = hotspots[part].position
			btn.size = hotspots[part].size
			btn.add_theme_stylebox_override("normal", StyleBoxEmpty.new())
			btn.add_theme_stylebox_override("hover", UIU.sbox(Color(1, 1, 1, 0.06)))
			btn.add_theme_stylebox_override("pressed", UIU.sbox(Color(1, 1, 1, 0.1)))
			btn.pressed.connect(func():
				_on_click(part, w)
			)
			file_box.add_child(btn)

		_result = UIU.label(" ", 14, UIU.COL_TEXT_LIGHT)
		c.add_child(_result)
		if Game.test_mode:
			await Game.wait(0.05)
			for p in diffs:
				_on_click(String(p), w)

	func _on_click(part: String, w: Dictionary) -> void:
		if part in diffs and part not in _found:
			_found.append(part)
			_result.text = "✓ 找到不同：%s　（%d/2）" % [_part_name(part), _found.size()]
			Sfx.play("ding", -8.0)
			if _found.size() >= 2:
				_result.text = "结论：照片与档案不符 —— 系伪造。"
				done.emit(true)
				await Game.wait(0.3)
				w["win"].queue_free()
				queue_free()
		else:
			_miss += 1
			_result.text = "这里没有不同。（误点 %d 次）" % _miss
			Sfx.play("beep_low", -16.0)

	func _part_name(p: String) -> String:
		match p:
			"glasses":
				return "眼镜"
			"beard":
				return "胡须"
		return "发型"
