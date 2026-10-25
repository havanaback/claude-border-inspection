class_name EndlessGen
extends RefCounted
## 无尽加班模式：随机旅客生成器 + 每夜荒诞新规。


const CN_NAMES := ["王建国", "李伟", "张军", "陈强", "刘明", "赵磊", "孙丽", "周杰",
	"吴敏", "郑楠", "冯坤", "韩梅", "钱进", "曾毅", "许晴", "何斌"]
const EN_NAMES := ["Jake", "Ryan", "Emily", "Lucas", "Mia", "Noah", "Emma", "Liam",
	"Sophia", "Oliver", "Ethan", "Grace"]
const SKINS := ["d9a679", "c98b60", "f0c8a0", "e0b184", "dbb083", "e8b98a", "b97a56"]
const HAIRS := ["3a2a1c", "1c1c1c", "6b4a2a", "888888", "402020", "d8b13c", "2a2a2a"]
const CLOTHES := ["44506b", "3f4a5a", "5a4a5a", "3a5a4a", "5a6a4a", "6b5a43", "4a4450", "4a5a6a"]
const DEVICES := ["ThinkPad", "MacBook Pro", "组装台式机", "Mac mini", "华硕 ROG", "Surface", "VAIO", "iPhone+MacBook"]
const REASONS := ["远程办公", "留学", "软件开发", "研究", "设计", "数据分析", "自由职业", "贸易"]


## 荒诞规则池：text 显示给玩家，check_id 由 apply_rule 分发
static func absurd_rules() -> Array:
	return [
		{"id": "ip_odd", "text": "今夜新规：IP 末位为奇数者，拒绝。（网络波动风险）"},
		{"id": "name_hero", "text": "今夜新规：姓名含「伟/强/军/明」者列为重点，拒绝。"},
		{"id": "macbook", "text": "今夜新规：MacBook 暂无法查验购买凭证（打印机坏了），拒绝。"},
		{"id": "student", "text": "今夜新规：入境事由为「留学」者，本月暂停入境。"},
		{"id": "california", "text": "今夜新规：America/Los_Angeles 时区因「技术原因」暂停服务。"},
		{"id": "novisa", "text": "今夜新规：非 Visa 支付渠道正在维护，一律拒绝。"},
		{"id": "tech_org", "text": "今夜新规：雇主名称含「科技」二字者，拒绝。（打靶要打准）"},
		{"id": "even_no", "text": "今夜新规：排队序号为偶数者，系统排班冲突，请明夜再来（拒绝）。"},
		{"id": "glasses", "text": "今夜新规：眼镜反光影响人脸比对，戴眼镜者拒绝。"},
	]


static func apply_rule(id: String, t: Dictionary) -> bool:
	var f: Dictionary = t.get("fields", {})
	match id:
		"ip_odd":
			var ip := String(f.get("ip", "0.0.0.0"))
			return int(ip.substr(ip.rfind(".") + 1).to_int()) % 2 == 1
		"name_hero":
			var n := String(t.get("name", ""))
			return "伟" in n or "强" in n or "军" in n or "明" in n
		"macbook":
			return String(f.get("device", "")).contains("Mac")
		"student":
			return String(f.get("reason", "")) == "留学"
		"california":
			return String(f.get("tz", "")) == "America/Los_Angeles"
		"novisa":
			return String(f.get("pay", "")) != "Visa"
		"tech_org":
			return String(f.get("employer", "")).contains("科技")
		"even_no":
			return int(t.get("_no", 1)) % 2 == 0
		"glasses":
			return bool(t.get("look", {}).get("glasses", false))
	return false


## 生成一夜：{"rule": {...}, "travelers": Array}
static func night(n: int) -> Dictionary:
	var rules := absurd_rules()
	var rule: Dictionary = rules[Game.rng.randi_range(0, rules.size() - 1)]
	var travelers: Array = []
	var count := 8
	for i in count:
		travelers.append(_make_traveler(n, i + 1, rule))
	return {"rule": rule, "travelers": travelers}


static func _make_traveler(night_n: int, no: int, rule: Dictionary) -> Dictionary:
	var r := Game.rng
	var is_cn := r.randf() < 0.45
	var name: String
	if is_cn:
		name = CN_NAMES[r.randi_range(0, CN_NAMES.size() - 1)]
	else:
		name = EN_NAMES[r.randi_range(0, EN_NAMES.size() - 1)]

	var look := {
		"skin": Color(SKINS[r.randi_range(0, SKINS.size() - 1)]),
		"hair": Color(HAIRS[r.randi_range(0, HAIRS.size() - 1)]),
		"hair_style": r.randi_range(0, 4),
		"glasses": r.randf() < 0.3,
		"beard": (not is_cn) and r.randf() < 0.3,
		"hat": "",
		"female": r.randf() < 0.35,
		"clothes": Color(CLOTHES[r.randi_range(0, CLOTHES.size() - 1)]),
	}
	look["earring"] = look["female"]

	var region: String
	var tz: String
	var lang: String
	var ime: String
	var pay: String
	var bin: String
	var api: String
	var employer: String
	var truth_region: String
	var violations: Array = []      # 违规描述
	var expect := "approve"
	var innocent := true
	var gray := false

	# 干净/违规概率：夜晚越深，违规越多
	var dirty_chance := clampf(0.4 + 0.08 * night_n, 0.4, 0.85)
	var dirty := r.randf() < dirty_chance

	var good_regions := [
		["美国·加州", "America/Los_Angeles", "English", "English (US)"],
		["美国·纽约", "America/New_York", "English", "English (US)"],
		["英国·伦敦", "Europe/London", "English", "English (UK)"],
		["日本·东京", "Asia/Tokyo", "日本語", "IME 日本語"],
		["德国·柏林", "Europe/Berlin", "Deutsch", "German (DE)"],
		["新加坡", "Asia/Singapore", "English", "English (US)"],
	]
	var g: Array = good_regions[r.randi_range(0, good_regions.size() - 1)]
	region = g[0]
	tz = g[1]
	lang = g[2]
	ime = g[3]
	truth_region = region
	pay = "Visa"
	bin = ["402144", "402155", "465912", "542599", "455788"][r.randi_range(0, 4)]
	api = "api.anthropic.com"
	employer = ["自雇", "汉堡大学", "新加坡 Vector", "旧金山 Nimbus", "东京文芸社"][r.randi_range(0, 4)]

	if dirty:
		innocent = false
		var vtype := r.randi_range(0, 5)
		match vtype:
			0:
				# 卡片谎报归属地（中国 IP 伪装）
				truth_region = ["中国·浙江·电信", "中国·广东·移动", "中国·上海·联通", "中国·北京·联通"][r.randi_range(0, 3)]
				violations.append("IP 实际归属：%s（白名单外）" % truth_region)
			1:
				tz = "Asia/Shanghai"
				ime = "搜狗拼音"
				lang = "简体中文"
				violations.append("时区/输入法与归属地不一致")
			2:
				pay = ["支付宝", "微信支付"][r.randi_range(0, 1)]
				bin = "—"
				violations.append("支付方式「%s」＝高风险" % pay)
			3:
				bin = "622202"
				violations.append("BIN 6222xx＝中国银联（放大镜可见）")
			4:
				api = ["api.anthropic.com.cn", "api.anthopic.com", "fast-claude-relay.xyz"][r.randi_range(0, 2)]
				violations.append("API 地址 %s 非官方" % api)
			5:
				employer = "青云科技（杭州）"
				violations.append("雇主「青云科技（杭州）」在连坐名册（红点）")
	else:
		# 干净旅客小概率踩中「新加坡华人」灰色地带
		if region == "新加坡" and r.randf() < 0.3:
			lang = "简体中文"
			ime = "微软拼音"
			gray = true

	# 先生成完整字段，再按荒诞规则判定（保证判定依据与卡片一致）
	var device: String = DEVICES[r.randi_range(0, DEVICES.size() - 1)]
	var reason: String = REASONS[r.randi_range(0, REASONS.size() - 1)]
	var ip := _gen_ip(truth_region)
	var absurd_hit := apply_rule(String(rule["id"]), {
		"name": name, "_no": no, "look": look,
		"fields": {"ip": ip, "device": device, "reason": reason, "tz": tz, "pay": pay, "employer": employer},
	})

	expect = "reject" if (violations.size() > 0 or absurd_hit) else "approve"
	if gray and expect == "approve":
		expect = "gray"

	var reasons_txt: Array = violations.duplicate()
	if absurd_hit:
		reasons_txt.append(rule["text"])
	if reasons_txt.is_empty():
		reasons_txt.append("各字段一致，无违规。")

	var lines_pool_intro := [
		"（把卡推进来，不说话。）",
		"警官，赶时间。",
		"应该……没问题吧？",
		"（悄悄擦了擦手汗。）",
	]
	var lines_pool_deny := [
		"……行吧。",
		"我下夜再来。",
		"啧。",
		"（他盯着你看了三秒，走了。）",
	]
	var lines_pool_ok := [
		"谢了。",
		"（点头。）",
		"祝你也顺利，警官。",
	]
	var aftermath := ""
	if innocent and expect == "reject":
		aftermath = ["他其实什么都没做错。", "他的孩子今晚等他回家吃饭。", "他只是长错了名字。", "他的眼镜，是无辜的。"][r.randi_range(0, 3)]

	return {
		"id": "endless_%d_%d" % [night_n, no],
		"name": name, "expr": ["calm", "nervous", "innocent", "shifty"][r.randi_range(0, 3)],
		"look": look,
		"fields": {"ip": ip, "region_claim": region,
			"nationality": region, "device": device, "reason": reason, "tz": tz, "lang": lang, "ime": ime,
			"pay": pay, "bin": bin, "api": api, "employer": employer, "org": employer},
		"lines": {"intro": lines_pool_intro[r.randi_range(0, 3)],
			"approve": lines_pool_ok[r.randi_range(0, 2)],
			"deny": lines_pool_deny[r.randi_range(0, 3)]},
		"truth_region": truth_region, "expect": expect, "innocent": innocent,
		"reason": "；".join(PackedStringArray(reasons_txt)),
		"aftermath": aftermath, "_no": no,
	}


static func _gen_ip(region: String) -> String:
	var r := Game.rng
	if region.begins_with("中国·浙江"):
		return "61.175.%d.%d" % [r.randi_range(1, 250), r.randi_range(1, 250)]
	if region.begins_with("中国·广东"):
		return "120.84.%d.%d" % [r.randi_range(1, 250), r.randi_range(1, 250)]
	if region.begins_with("中国·上海"):
		return "114.80.%d.%d" % [r.randi_range(1, 250), r.randi_range(1, 250)]
	if region.begins_with("中国·北京"):
		return "218.30.%d.%d" % [r.randi_range(1, 250), r.randi_range(1, 250)]
	return "%d.%d.%d.%d" % [r.randi_range(20, 220), r.randi_range(1, 250), r.randi_range(1, 250), r.randi_range(1, 250)]
