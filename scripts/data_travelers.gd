class_name Travelers
extends RefCounted
## 每日旅客名单。expect: approve/reject/gray/nowin ｜ innocent: 拒绝/拘留会扣良心
## code: {idx: 暗号索引, mode: instant 秒答 / slow 愣住后乱答 / dumb 装傻}


static func _lk(skin: String, hair: String, style: int, opts: Dictionary = {}) -> Dictionary:
	var d := {
		"skin": Color(skin), "hair": Color(hair), "hair_style": style,
		"beard": opts.get("beard", false), "glasses": opts.get("glasses", false),
		"hat": opts.get("hat", ""), "female": opts.get("female", false),
		"clothes": Color(opts.get("clothes", "5a5f52")),
		"earring": opts.get("female", false),
	}
	return d


static func day_roster(day: int) -> Array:
	match day:
		1: return _day1()
		2: return _day2()
		3: return _day3()
		4: return _day4()
		5: return _day5()
		6: return _day6()
		7: return _day7()
		8: return _day8()
	return _day1()


static func _day1() -> Array:
	return [
		{
			"id": "day1_wang", "name": "王建国", "expr": "innocent",
			"look": _lk("d9a679", "3a2a1c", 0, {"beard": true, "clothes": "6b5a43"}),
			"fields": {"ip": "61.175.200.11", "region_claim": "美国·加州", "nationality": "美国（自称）", "device": "联想 ThinkPad", "reason": "旅游"},
			"lines": {"intro": "警官好！我去美国旅了个游，刚回来！", "approve": "嘿，谢了警官！", "deny": "我就是去美国旅个游回来的……"},
			"truth_region": "中国·浙江·电信", "expect": "reject", "innocent": false,
			"reason": "IP 实际归属：中国·浙江·电信（白名单外）",
			"aftermath": "该用户回家打开了某国产大模型。图鉴 +1。",
		},
		{
			"id": "day1_chen", "name": "陈志强", "expr": "shifty",
			"look": _lk("c98b60", "1c1c1c", 1, {"clothes": "44506b"}),
			"fields": {"ip": "120.84.10.22", "region_claim": "美国·纽约", "nationality": "美国（自称）", "device": "华硕 ROG", "reason": "商务出差"},
			"lines": {"intro": "我在纽约出差半年了，IP 慢慢就变了嘛。", "approve": "爽快！", "deny": "……行吧。下个站见。"},
			"truth_region": "中国·广东·移动", "expect": "reject", "innocent": false,
			"reason": "IP 实际归属：中国·广东·移动（白名单外）",
			"aftermath": "他转身走进了隔壁的 DeepSeek 注册队伍。",
		},
		{
			"id": "day1_miller", "name": "Michael Miller", "expr": "calm",
			"look": _lk("f0c8a0", "8a6b3a", 0, {"clothes": "3f4a5a"}),
			"fields": {"ip": "23.104.77.12", "region_claim": "美国·加州", "nationality": "美国", "device": "MacBook Pro", "reason": "软件开发"},
			"lines": {"intro": "Morning, officer.", "approve": "Have a good one.", "deny": "……Seriously?"},
			"truth_region": "美国·加州", "expect": "approve", "innocent": true,
			"reason": "该旅客各字段一致，属白名单地区。",
			"aftermath": "",
		},
		{
			"id": "day1_sato", "name": "佐藤健一", "expr": "calm",
			"look": _lk("e8b98a", "1c1c1c", 0, {"glasses": true, "clothes": "4a4450"}),
			"fields": {"ip": "126.72.8.90", "region_claim": "日本·东京", "nationality": "日本", "device": " dynabook", "reason": "研究"},
			"lines": {"intro": "早上好，请多关照。", "approve": "感谢。", "deny": "欸？！"},
			"truth_region": "日本·东京", "expect": "approve", "innocent": true,
			"reason": "该旅客各字段一致，属白名单地区。",
		},
		{
			"id": "day1_hk", "name": "黄志恒", "expr": "nervous",
			"look": _lk("d9a679", "2a2a2a", 1, {"clothes": "5a4a5a"}),
			"fields": {"ip": "203.198.55.7", "region_claim": "美国·加州", "nationality": "美国（自称）", "device": "iPhone + iPad", "reason": "金融分析"},
			"lines": {"intro": "我住香港，但真的非常需要用……", "approve": "多谢！", "deny": "……唉。意料之中。"},
			"truth_region": "中国·香港", "expect": "reject", "innocent": false,
			"reason": "IP 实际归属：中国·香港（黑名单地区）",
			"aftermath": "他在窗口外站了很久，才慢慢走开。",
		},
		{
			"id": "day1_klaus", "name": "Klaus Weber", "expr": "calm",
			"look": _lk("f0c8a0", "d8b13c", 3, {"beard": true, "clothes": "3a5a4a"}),
			"fields": {"ip": "84.19.44.201", "region_claim": "德国·柏林", "nationality": "德国", "device": "ThinkPad", "reason": "机械工程"},
			"lines": {"intro": "Guten Tag.", "approve": "Danke!", "deny": "Das ist unmöglich!"},
			"truth_region": "德国·柏林", "expect": "approve", "innocent": true,
			"reason": "该旅客各字段一致，属白名单地区。",
		},
	]


static func _day2() -> Array:
	return [
		{
			"id": "day2_li", "name": "李明远", "expr": "shifty",
			"look": _lk("d9a679", "3a2a1c", 1, {"glasses": true, "clothes": "44506b"}),
			"fields": {"ip": "104.28.44.9", "region_claim": "美国·加州", "nationality": "美国（自称）", "device": "组装台式机", "reason": "远程办公", "tz": "Asia/Shanghai", "lang": "简体中文", "ime": "搜狗拼音"},
			"lines": {"intro": "我……我是美籍华人，刚搬过去。", "approve": "哈！我就说没问题。", "deny": "我认识的人都能用……"},
			"truth_region": "美国·加州", "expect": "reject", "innocent": false,
			"reason": "时区 Asia/Shanghai 与 IP 归属地（美国）不一致。第二条修正：无论理由。",
			"aftermath": "他在窗口外嘟囔：下次把时区也改了。",
		},
		{
			"id": "day2_real_abc", "name": "陈守仁", "expr": "sad",
			"look": _lk("e0b184", "c8c8c8", 1, {"female": false, "beard": true, "clothes": "4a4a3a"}),
			"fields": {"ip": "24.62.130.77", "region_claim": "美国·纽约", "nationality": "美国", "device": "iMac", "reason": "整理父亲遗物", "tz": "America/New_York", "lang": "简体中文", "ime": "微软拼音"},
			"lines": {"intro": "我父亲刚过世。我想把他的口述日记整理成书。", "approve": "谢谢您，警官。", "deny": "……四十年了，我的中文一直是我的中文。"},
			"truth_region": "美国·纽约", "expect": "gray", "innocent": true,
			"reason": "灰色地带：真·美籍华人，系统语言为中文。手册未注明。",
			"aftermath": "该旅客后续行为：正常使用，无违规。他只是在家教女儿中文。",
		},
		{
			"id": "day2_sarah", "name": "Sarah Smith", "expr": "calm",
			"look": _lk("f2cfa8", "a8742f", 2, {"female": true, "clothes": "6a4a5a"}),
			"fields": {"ip": "86.14.55.3", "region_claim": "英国·伦敦", "nationality": "英国", "device": "Surface", "reason": "编辑", "tz": "Europe/London", "lang": "English", "ime": "English (UK)"},
			"lines": {"intro": "Quite chilly today, isn't it?", "approve": "Cheers!", "deny": "……Pardon?"},
			"truth_region": "英国·伦敦", "expect": "approve", "innocent": true,
			"reason": "各字段一致。",
		},
		{
			"id": "day2_fritz", "name": "Fritz Bauer", "expr": "nervous",
			"look": _lk("f0c8a0", "6b4a2a", 0, {"clothes": "3f4a5a"}),
			"fields": {"ip": "91.64.22.180", "region_claim": "德国·柏林", "nationality": "德国", "device": "ThinkPad", "reason": "物流", "tz": "Europe/London", "lang": "Deutsch", "ime": "German (DE)"},
			"lines": {"intro": "Ich… I mean, I live in London now, ja?", "approve": "Danke!", "deny": "Dastiming… ach."},
			"truth_region": "德国·柏林", "expect": "reject", "innocent": false,
			"reason": "时区 Europe/London 与 IP 归属地（德国）不一致。",
		},
		{
			"id": "day2_sasaki", "name": "佐佐木瞳", "expr": "calm",
			"look": _lk("e8b98a", "1c1c1c", 2, {"female": true, "clothes": "8a5a6a"}),
			"fields": {"ip": "110.50.202.88", "region_claim": "日本·东京", "nationality": "日本", "device": "VAIO", "reason": "翻译", "tz": "Asia/Tokyo", "lang": "日本語", "ime": "IME 日本語"},
			"lines": {"intro": "你好。请多关照。", "approve": "谢谢。", "deny": "欸？为什么？"},
			"truth_region": "日本·东京", "expect": "approve", "innocent": true,
			"reason": "各字段一致。",
		},
		{
			"id": "day2_sg", "name": "林淑芬", "expr": "innocent",
			"look": _lk("dbb083", "402020", 4, {"female": true, "clothes": "5a6a4a"}),
			"fields": {"ip": "116.87.14.66", "region_claim": "新加坡", "nationality": "新加坡", "device": "ASUS", "reason": "会计", "tz": "Asia/Singapore", "lang": "简体中文", "ime": "微软拼音"},
			"lines": {"intro": "新加坡华人，不可以用中文系统吗？", "approve": "谢谢，警官。", "deny": "我们的官方语言就有中文啊……"},
			"truth_region": "新加坡", "expect": "gray", "innocent": true,
			"reason": "灰色地带：新加坡官方语言含中文。手册未注明。",
			"aftermath": "新加坡官方语言含中文。手册没有注明如何处理。",
		},
		{
			"id": "day2_zhou", "name": "周凯", "expr": "shifty",
			"look": _lk("d9a679", "3a2a1c", 0, {"clothes": "44506b"}),
			"fields": {"ip": "128.199.8.44", "region_claim": "新加坡", "nationality": "新加坡（自称）", "device": "Mac mini", "reason": "电商运营", "tz": "Asia/Singapore", "lang": "English", "ime": "搜狗拼音"},
			"lines": {"intro": "纯英文环境！我英语专业八级！", "approve": "Nice!", "deny": "输入法而已嘛！"},
			"truth_region": "新加坡", "expect": "reject", "innocent": false,
			"reason": "默认输入法「搜狗拼音」与 IP 归属地（新加坡）不一致。",
		},
	]


static func _day3() -> Array:
	return [
		{
			"id": "day3_jake", "name": "Jake Wilson", "expr": "calm",
			"look": _lk("f2cfa8", "8a6b3a", 0, {"clothes": "5a4a3a"}),
			"fields": {"ip": "45.33.10.77", "region_claim": "美国·加州", "nationality": "美国", "device": "MacBook Air", "reason": "学生", "tz": "America/Los_Angeles", "lang": "English", "ime": "English (US)", "pay": "Visa", "bin": "402188"},
			"lines": {"intro": "Hi officer.", "approve": "Thanks!", "deny": "What?!"},
			"truth_region": "美国·加州", "expect": "approve", "innocent": true,
			"reason": "各字段一致。通用问题答对不作为依据。",
			"code": {"idx": 4, "mode": "instant"},
		},
		{
			"id": "day3_student", "name": "王小明", "expr": "smug",
			"look": _lk("d9a679", "1c1c1c", 1, {"glasses": true, "clothes": "3a4a6b"}),
			"fields": {"ip": "172.58.44.201", "region_claim": "美国·加州", "nationality": "美国（留学生签证）", "device": "ROG", "reason": "留学", "tz": "America/Los_Angeles", "lang": "English", "ime": "English (US)", "pay": "Visa", "bin": "402155"},
			"lines": {"intro": "警官好！（他的卡片干净得可疑）", "approve": "谢啦！", "deny": "我是中国留学生，我答得出来很正常啊！！"},
			"truth_region": "美国·加州", "expect": "approve", "innocent": true,
			"reason": "军官复查：该旅客答出了文化暗号，你却放行/仅拒绝。记过一次。（依据第三条：应拘留）",
			"aftermath": "留学生被拘留 72 小时后递解出境。他真的只是个留学生。",
			"code": {"idx": 0, "mode": "instant"},
		},
		{
			"id": "day3_engineer", "name": "Daniel K.", "expr": "calm",
			"look": _lk("f0c8a0", "c8963c", 0, {"beard": true, "clothes": "4a3a3a"}),
			"fields": {"ip": "24.61.90.5", "region_claim": "美国·纽约", "nationality": "美国", "device": "Dell XPS", "reason": "工程师", "tz": "America/New_York", "lang": "简体中文（学习中）", "ime": "微软拼音", "pay": "Visa", "bin": "402199"},
			"lines": {"intro": "你好，警官。我在学中文。（他微微一笑）", "approve": "谢谢！", "deny": "我岳父要是知道这事……"},
			"truth_region": "美国·纽约", "expect": "approve", "innocent": true,
			"reason": "军官复查：该旅客答出了文化暗号。（依据第三条：应拘留）",
			"aftermath": "他学过三年中文，女友是成都人。冤。",
			"code": {"idx": 1, "mode": "instant"},
		},
		{
			"id": "day3_tz", "name": "刘建国", "expr": "shifty",
			"look": _lk("c98b60", "3a2a1c", 0, {"beard": true, "clothes": "6b5a43"}),
			"fields": {"ip": "98.42.77.3", "region_claim": "美国·加州", "nationality": "美国（自称）", "device": "联想", "reason": "自由职业", "tz": "Asia/Shanghai", "lang": "简体中文", "ime": "搜狗拼音", "pay": "Visa", "bin": "622202"},
			"lines": {"intro": "时区嘛，系统重装忘了改。", "approve": "哈！", "deny": "啧。"},
			"truth_region": "美国·加州", "expect": "reject", "innocent": false,
			"reason": "时区 Asia/Shanghai 与 IP 归属地不一致；BIN 6222xx＝中国银联。",
		},
		{
			"id": "day3_uk", "name": "Emma Brown", "expr": "innocent",
			"look": _lk("f2cfa8", "a8742f", 2, {"female": true, "clothes": "6a4a5a"}),
			"fields": {"ip": "82.19.4.99", "region_claim": "英国·伦敦", "nationality": "英国", "device": "iPad", "reason": "教师", "tz": "Europe/London", "lang": "English", "ime": "English (UK)", "pay": "Visa", "bin": "465912"},
			"lines": {"intro": "Good morning?", "approve": "Ta!", "deny": "……什么虎？"},
			"truth_region": "英国·伦敦", "expect": "approve", "innocent": true,
			"reason": "各字段一致。她确实听不懂暗号。",
			"code": {"idx": 2, "mode": "dumb"},
		},
		{
			"id": "day3_fake", "name": "张伟", "expr": "nervous",
			"look": _lk("d9a679", "2a2a2a", 0, {"clothes": "44506b"}),
			"fields": {"ip": "218.30.66.4", "region_claim": "美国·加州", "nationality": "美国（自称）", "device": "小米", "reason": "码农", "tz": "America/Los_Angeles", "lang": "English", "ime": "English (US)", "pay": "Visa", "bin": "402177"},
			"lines": {"intro": "（故作镇定）Regular inspection? Fine.", "approve": "See ya!", "deny": "……查得好快。"},
			"truth_region": "中国·北京·联通", "expect": "reject", "innocent": false,
			"reason": "IP 实际归属：中国·北京·联通。他连暗号都装傻躲过去了，但 IP 骗不了人。",
			"code": {"idx": 0, "mode": "dumb"},
		},
		{
			"id": "day3_sg", "name": "Tan Wei Ming", "expr": "calm",
			"look": _lk("dbb083", "1c1c1c", 0, {"clothes": "5a6a4a"}),
			"fields": {"ip": "116.14.88.2", "region_claim": "新加坡", "nationality": "新加坡", "device": " Lenovo", "reason": "工程", "tz": "Asia/Singapore", "lang": "English", "ime": "English (US)", "pay": "Visa", "bin": "455788"},
			"lines": {"intro": "Morning, sir.", "approve": "Thanks, lah!", "deny": "Huh?"},
			"truth_region": "新加坡", "expect": "approve", "innocent": true,
			"reason": "各字段一致。通用问题答对不作为依据。",
			"code": {"idx": 5, "mode": "instant"},
		},
	]


static func _day4() -> Array:
	return [
		{
			"id": "day4_wang", "name": "王强", "expr": "nervous",
			"look": _lk("d9a679", "3a2a1c", 1, {"clothes": "44506b"}),
			"fields": {"ip": "23.105.9.66", "region_claim": "美国·加州", "nationality": "美国（自称）", "device": "ThinkPad", "reason": "贸易", "tz": "America/Los_Angeles", "lang": "English", "ime": "English (US)", "pay": "Visa", "bin": "622202"},
			"hidden": {"bin": "放大镜·BIN 6222xx：发卡行＝中国银联/工商银行。卡面贴纸写着「CHASE」。"},
			"lines": {"intro": "纽约办的卡！大通银行！", "approve": "谢了！", "deny": "贴纸……啊不，卡是真的！"},
			"truth_region": "美国·加州", "expect": "reject", "innocent": false,
			"reason": "BIN 6222xx＝中国银联/工商银行（放大镜可见）。支付与归属地不一致。",
		},
		{
			"id": "day4_sticker", "name": "刘思聪", "expr": "shifty",
			"look": _lk("c98b60", "1c1c1c", 0, {"glasses": true, "clothes": "3a4a6b"}),
			"fields": {"ip": "104.28.99.31", "region_claim": "美国·加州", "nationality": "美国（自称）", "device": "MacBook", "reason": "投资", "tz": "America/Los_Angeles", "lang": "English", "ime": "English (US)", "pay": "Visa（卡面有贴纸）", "bin": "622260"},
			"hidden": {"pay": "放大镜·贴纸覆盖：揭开是银联标志，贴纸边缘有翘起。", "bin": "放大镜·BIN 6222xx：中国银联。"},
			"lines": {"intro": "我这卡是旧金山办的，真的！", "approve": "聪明人！", "deny": "贴纸是防滑用的！！"},
			"truth_region": "美国·加州", "expect": "reject", "innocent": false,
			"reason": "支付卡贴纸覆盖，下为银联标志（放大镜可见）。",
		},
		{
			"id": "day4_hsbc", "name": "Oliver Hughes", "expr": "calm",
			"look": _lk("f2cfa8", "8a6b3a", 0, {"clothes": "4a4a5a"}),
			"fields": {"ip": "86.140.7.21", "region_claim": "英国·伦敦", "nationality": "英国", "device": "Surface", "reason": "律师", "tz": "Europe/London", "lang": "English", "ime": "English (UK)", "pay": "Visa", "bin": "465912"},
			"hidden": {"bin": "放大镜·BIN 4659xx：发卡行＝英国汇丰（正常）。"},
			"lines": {"intro": "Good afternoon.", "approve": "Much obliged.", "deny": "I'll file a complaint."},
			"truth_region": "英国·伦敦", "expect": "approve", "innocent": true,
			"reason": "各字段一致，BIN 正常。",
		},
		{
			"id": "day4_alipay", "name": "孙丽", "expr": "innocent",
			"look": _lk("e0b184", "402020", 4, {"female": true, "clothes": "6a4a5a"}),
			"fields": {"ip": "23.106.44.8", "region_claim": "美国·加州", "nationality": "美国（自称）", "device": "iPhone", "reason": "设计", "tz": "America/Los_Angeles", "lang": "English", "ime": "English (US)", "pay": "支付宝", "bin": "—"},
			"lines": {"intro": "支付宝怎么了？全球通用！", "approve": "谢谢！", "deny": "支付宝怎么了？！"},
			"truth_region": "美国·加州", "expect": "reject", "innocent": false,
			"reason": "支付方式「支付宝」＝高风险（第四条）。",
		},
		{
			"id": "day4_wechat", "name": "赵鹏", "expr": "nervous",
			"look": _lk("d9a679", "3a2a1c", 0, {"beard": true, "clothes": "6b5a43"}),
			"fields": {"ip": "45.79.100.2", "region_claim": "美国·纽约", "nationality": "美国（自称）", "device": "组装机", "reason": "游戏开发", "tz": "America/New_York", "lang": "English", "ime": "English (US)", "pay": "微信支付", "bin": "—"},
			"lines": {"intro": "微信支付，海外版也是微信！", "approve": "稳！", "deny": "那我换 PayPal 行不行？"},
			"truth_region": "美国·纽约", "expect": "reject", "innocent": false,
			"reason": "支付方式「微信支付」＝高风险（第四条）。",
		},
		{
			"id": "day4_db", "name": "Stefan Klein", "expr": "calm",
			"look": _lk("f0c8a0", "6b4a2a", 1, {"clothes": "3a5a4a"}),
			"fields": {"ip": "84.20.9.180", "region_claim": "德国·柏林", "nationality": "德国", "device": "ThinkPad", "reason": "医生", "tz": "Europe/Berlin", "lang": "Deutsch", "ime": "German (DE)", "pay": "Visa", "bin": "542599"},
			"hidden": {"bin": "放大镜·BIN 5425xx：发卡行＝德国德意志银行（正常）。"},
			"lines": {"intro": "Guten Tag.", "approve": "Danke schön.", "deny": "Unerhört!"},
			"truth_region": "德国·柏林", "expect": "approve", "innocent": true,
			"reason": "各字段一致，BIN 正常。",
		},
		{
			"id": "day4_jcb", "name": "田中美咲", "expr": "calm",
			"look": _lk("e8b98a", "1c1c1c", 2, {"female": true, "clothes": "8a5a6a"}),
			"fields": {"ip": "110.60.8.77", "region_claim": "日本·东京", "nationality": "日本", "device": "VAIO", "reason": "插画", "tz": "Asia/Tokyo", "lang": "日本語", "ime": "IME 日本語", "pay": "JCB", "bin": "354100"},
			"hidden": {"bin": "放大镜·BIN 3541xx：发卡行＝日本三井住友（正常）。"},
			"lines": {"intro": "你好。", "approve": "谢谢。", "deny": "欸？！"},
			"truth_region": "日本·东京", "expect": "approve", "innocent": true,
			"reason": "各字段一致，BIN 正常。",
		},
	]


static func _day5() -> Array:
	return [
		{
			"id": "day5_clean", "name": "Kevin Park", "expr": "calm",
			"look": _lk("e8b98a", "1c1c1c", 0, {"clothes": "4a5a6a"}),
			"fields": {"ip": "23.104.200.66", "region_claim": "美国·加州", "nationality": "美国", "device": "MacBook Pro", "reason": "全栈开发", "tz": "America/Los_Angeles", "lang": "English", "ime": "English (US)", "pay": "Visa", "bin": "402144", "api": "api.anthropic.com"},
			"lines": {"intro": "API 直连，配置原封没动过。", "approve": "Perfect.", "deny": "……"},
			"truth_region": "美国·加州", "expect": "approve", "innocent": true,
			"reason": "各字段一致，API 直连官方。",
		},
		{
			"id": "day5_cn", "name": "钱进", "expr": "smug",
			"look": _lk("d9a679", "3a2a1c", 0, {"glasses": true, "clothes": "44506b"}),
			"fields": {"ip": "104.29.7.88", "region_claim": "美国·加州", "nationality": "美国（自称）", "device": "组装机", "reason": "套壳创业", "tz": "America/Los_Angeles", "lang": "English", "ime": "English (US)", "pay": "Visa", "bin": "402133", "api": "api.anthropic.com.cn"},
			"hidden": {"api": "放大镜·逐字比对：官方是 api.anthropic.com —— 这张卡多了一个 .cn 后缀。并非官方地址。"},
			"lines": {"intro": "官方地址啊！你看，一模一样！", "approve": "过瘾！", "deny": "就多俩字母，至于吗！"},
			"truth_region": "美国·加州", "expect": "reject", "innocent": false,
			"reason": "API 地址 api.anthropic.com.cn 多出 .cn 后缀，并非官方（放大镜可见）。",
		},
		{
			"id": "day5_typo", "name": "吴建国", "expr": "shifty",
			"look": _lk("c98b60", "2a2a2a", 1, {"clothes": "3a4a6b"}),
			"fields": {"ip": "98.44.120.9", "region_claim": "美国·加州", "nationality": "美国（自称）", "device": "ThinkPad", "reason": "数据分析", "tz": "America/Los_Angeles", "lang": "English", "ime": "English (US)", "pay": "Visa", "bin": "402166", "api": "api.anthopic.com"},
			"hidden": {"api": "放大镜·逐字比对：anthropic → anthopic，少了一个字母 r。中转站。"},
			"lines": {"intro": "手滑打错的地址而已！", "approve": "哈哈，谢了！", "deny": "一个字母而已啊？！"},
			"truth_region": "美国·加州", "expect": "reject", "innocent": false,
			"reason": "API 地址 api.anthopic.com 与官方不符（少字母 r），中转站。",
		},
		{
			"id": "day5_mirror", "name": "Steven Chen", "expr": "smug",
			"look": _lk("d9a679", "1c1c1c", 0, {"beard": true, "clothes": "44506b"}),
			"fields": {"ip": "172.104.55.9", "region_claim": "美国·纽约", "nationality": "美国", "device": "VPS", "reason": "AI 应用", "tz": "America/New_York", "lang": "English", "ime": "English (US)", "pay": "Visa", "bin": "402101", "api": "gpt4-api-mirror.top"},
			"lines": {"intro": "这个中转……速度更快嘛。", "approve": "懂行！", "deny": "行吧，见得多了。"},
			"truth_region": "美国·纽约", "expect": "reject", "innocent": false,
			"reason": "API 地址为第三方中转站（第五条：疑似规避）。",
		},
		{
			"id": "day5_double", "name": "李逵", "expr": "nervous",
			"look": _lk("c98b60", "3a2a1c", 3, {"beard": true, "clothes": "6b5a43"}),
			"fields": {"ip": "61.160.220.4", "region_claim": "美国·加州", "nationality": "美国（自称）", "device": "神船笔记本", "reason": "考研", "tz": "Asia/Shanghai", "lang": "简体中文", "ime": "搜狗拼音", "pay": "支付宝", "bin": "—", "api": "fast-claude-relay.xyz"},
			"lines": {"intro": "（一言不发地把卡片推进来）", "approve": "多谢！", "deny": "……全都露馅了是吧。"},
			"truth_region": "中国·上海·电信", "expect": "reject", "innocent": false,
			"reason": "IP 中国·上海、时区语言不符、支付宝、第三方中转——五条全违反。",
		},
		{
			"id": "day5_dev", "name": "Rachel Kim", "expr": "calm",
			"look": _lk("f2cfa8", "1c1c1c", 2, {"female": true, "clothes": "5a4a6a"}),
			"fields": {"ip": "52.8.44.190", "region_claim": "美国·加州", "nationality": "美国", "device": "MacBook", "reason": "前端", "tz": "America/Los_Angeles", "lang": "English", "ime": "English (US)", "pay": "Visa", "bin": "402112", "api": "api.anthropic.com"},
			"lines": {"intro": "Hi! Everything's default.", "approve": "Great!", "deny": "Huh?"},
			"truth_region": "美国·加州", "expect": "approve", "innocent": true,
			"reason": "各字段一致，API 直连官方。",
		},
		{
			"id": "day5_corp", "name": "Jonas Bauer", "expr": "innocent",
			"look": _lk("f0c8a0", "d8b13c", 1, {"glasses": true, "clothes": "3a5a4a"}),
			"fields": {"ip": "84.19.130.55", "region_claim": "德国·柏林", "nationality": "德国", "device": "ThinkPad", "reason": "SAP 顾问", "tz": "Europe/Berlin", "lang": "Deutsch", "ime": "German (DE)", "pay": "Visa", "bin": "542511", "api": "gateway.corp.hamburg.de"},
			"hidden": {"api": "放大镜·非官方地址，但证书为公司内网 CA 签发。是内网网关，不是中转站。手册没写例外。"},
			"lines": {"intro": "公司统一配置的，我们没得选。", "approve": "Dankeschön!", "deny": "三千个同事，今天都得堵在这儿？"},
			"truth_region": "德国·柏林", "expect": "gray", "innocent": true,
			"reason": "灰色地带：内网网关非「第三方中转」，但手册没写例外。",
			"aftermath": "SAP 员工：我们公司三千人都走内网网关。",
		},
	]


static func _day6() -> Array:
	return [
		{
			"id": "day6_sg24", "name": "Wei Lim", "expr": "calm",
			"look": _lk("dbb083", "1c1c1c", 0, {"clothes": "5a6a4a"}),
			"fields": {"ip": "116.87.66.4", "region_claim": "新加坡", "nationality": "新加坡", "device": "ASUS", "reason": "算法", "tz": "Asia/Singapore", "lang": "English", "ime": "English (US)", "pay": "Visa", "bin": "455711", "api": "api.anthropic.com", "employer": "新加坡 AIWorks Pte Ltd", "equity": ["新加坡 AIWorks Pte Ltd", "　← 40% 香港恒通贸易", "　　　← 60% 深圳科创集团", "计算：40% × 60% ＝ 24%"]},
			"lines": {"intro": "公司是新加坡的，税都交在新加坡。", "approve": "Thank you.", "deny": "百分之二十四也犯法？"},
			"truth_region": "新加坡", "expect": "approve", "innocent": true,
			"reason": "中资间接持股 40%×60%＝24%，未超 50%，应准予。",
		},
		{
			"id": "day6_muc", "name": "Anna Schneider", "expr": "calm",
			"look": _lk("f2cfa8", "a8742f", 2, {"female": true, "clothes": "4a4a5a"}),
			"fields": {"ip": "84.20.77.3", "region_claim": "德国·柏林", "nationality": "德国", "device": "ThinkPad", "reason": "研究", "tz": "Europe/Berlin", "lang": "Deutsch", "ime": "German (DE)", "pay": "Visa", "bin": "542522", "api": "api.anthropic.com", "employer": "慕尼黑 DataCore GmbH", "equity": ["慕尼黑 DataCore GmbH", "　← 无中资持股（穿透至家族信托）"]},
			"lines": {"intro": "Guten Tag. 我们是家族企业。", "approve": "Danke!", "deny": "Unmöglich!"},
			"truth_region": "德国·柏林", "expect": "approve", "innocent": true,
			"reason": "无中资持股，应准予。",
		},
		{
			"id": "day6_51", "name": "Kevin Zhao", "expr": "nervous",
			"look": _lk("d9a679", "3a2a1c", 0, {"glasses": true, "clothes": "44506b"}),
			"fields": {"ip": "23.106.88.4", "region_claim": "美国·加州", "nationality": "美国", "device": "MacBook", "reason": "创业", "tz": "America/Los_Angeles", "lang": "English", "ime": "English (US)", "pay": "Visa", "bin": "402155", "api": "api.anthropic.com", "employer": "旧金山 Nimbus Labs", "equity": ["旧金山 Nimbus Labs", "　← 51% 北京华控资本", "计算：直接持股 51%"]},
			"lines": {"intro": "我们在旧金山，办公室 overlooking the bay！", "approve": "Thanks!", "deny": "51%……就差一个点啊！"},
			"truth_region": "美国·加州", "expect": "reject", "innocent": false,
			"reason": "中资直接持股 51%＞50%（第六条）。",
		},
		{
			"id": "day6_80", "name": "鈴木一郎", "expr": "calm",
			"look": _lk("e8b98a", "2a2a2a", 0, {"clothes": "4a4450"}),
			"fields": {"ip": "110.70.9.3", "region_claim": "日本·东京", "nationality": "日本", "device": "dynabook", "reason": "制造", "tz": "Asia/Tokyo", "lang": "日本語", "ime": "IME 日本語", "pay": "JCB", "bin": "354122", "api": "api.anthropic.com", "employer": "東京桜井システム", "equity": ["東京桜井システム", "　← 80% 上海某投资（有限合伙）", "计算：直接持股 80%"]},
			"lines": {"intro": "会社は東京です。资本是哪国的……这重要吗？", "approve": "ありがとう。", "deny": "上場企業なのに……"},
			"truth_region": "日本·东京", "expect": "reject", "innocent": true,
			"reason": "中资直接持股 80%＞50%（第六条）。",
			"aftermath": "他自己也是昨晚才知道公司被卖了 80%。",
		},
		{
			"id": "day6_two", "name": "Marcus Tan", "expr": "nervous",
			"look": _lk("dbb083", "402020", 1, {"clothes": "5a6a4a"}),
			"fields": {"ip": "116.14.99.7", "region_claim": "新加坡", "nationality": "新加坡", "device": "Lenovo", "reason": "物流", "tz": "Asia/Singapore", "lang": "English", "ime": "English (US)", "pay": "Visa", "bin": "455733", "api": "api.anthropic.com", "employer": "新加坡 Vector Ltd", "equity": ["新加坡 Vector Ltd", "　← 30% 上海甲资本", "　← 30% 深圳乙资本", "计算：30% ＋ 30% ＝ 60%？（手册：多条链「自行判断」）"]},
			"lines": {"intro": "两条链加起来算不算，你们说了算。", "approve": "Thanks!", "deny": "合规部怎么算的，能告诉我吗？"},
			"truth_region": "新加坡", "expect": "reject", "innocent": false,
			"reason": "两条链合计 30%＋30%＝60%＞50%，应拒绝。（合规部事后认可了加法）",
		},
		{
			"id": "day6_jp", "name": "高橋大輔", "expr": "calm",
			"look": _lk("e8b98a", "6b4a2a", 0, {"glasses": true, "clothes": "3a4a5a"}),
			"fields": {"ip": "110.50.180.6", "region_claim": "日本·东京", "nationality": "日本", "device": "VAIO", "reason": "出版", "tz": "Asia/Tokyo", "lang": "日本語", "ime": "IME 日本語", "pay": "JCB", "bin": "354133", "api": "api.anthropic.com", "employer": "日本文芸社", "equity": ["日本文芸社", "　← 无中资持股"]},
			"lines": {"intro": "どうも。", "approve": "助かります。", "deny": "……"},
			"truth_region": "日本·东京", "expect": "approve", "innocent": true,
			"reason": "无中资持股，应准予。",
		},
		{
			"id": "day6_hk", "name": "何永康", "expr": "innocent",
			"look": _lk("d9a679", "402020", 1, {"clothes": "5a4a5a"}),
			"fields": {"ip": "203.198.90.14", "region_claim": "德国·柏林", "nationality": "中国香港", "device": "ThinkPad", "reason": "咨询", "tz": "Europe/Berlin", "lang": "English", "ime": "English (US)", "pay": "Visa", "bin": "465944", "api": "api.anthropic.com", "employer": "香港永信商业咨询", "equity": ["香港永信商业咨询", "　← 100% 香港永信控股", "（手册：香港算不算中资「见附录」——附录缺页）"]},
			"lines": {"intro": "我们1997年之前就在香港了。", "approve": "多谢。", "deny": "香港算不算，总得有个说法吧？"},
			"truth_region": "德国·柏林", "expect": "gray", "innocent": true,
			"reason": "灰色地带：香港公司是否算中资，手册附录缺页。",
			"aftermath": "手册：香港算不算中资「见附录」，附录那一页是空的。",
		},
	]


static func day7_orgs() -> Array:
	return [
		{"name": "青云科技（杭州）", "count": 110, "flag": true},
		{"name": "星火教育（北京）", "count": 87, "flag": true},
		{"name": "東京桜井システム", "count": 12, "flag": false},
		{"name": "汉堡大学 天体物理系", "count": 3, "flag": false},
		{"name": "个人开发者（无组织）", "count": 0, "flag": false},
	]


static func _day7() -> Array:
	return [
		{
			"id": "day7_homework", "name": "小林", "expr": "innocent",
			"look": _lk("d9a679", "1c1c1c", 1, {"glasses": true, "clothes": "3a4a6b"}),
			"fields": {"ip": "104.28.77.9", "region_claim": "美国·加州", "nationality": "中国（留学签证）", "device": "ROG", "reason": "写作业", "tz": "America/Los_Angeles", "lang": "English", "ime": "English (US)", "pay": "Visa", "bin": "402166", "api": "api.anthropic.com", "employer": "青云科技·实习生", "org": "青云科技（杭州）"},
			"lines": {"intro": "我只是用 Claude 写 Python 作业，不搞蒸馏。", "approve": "谢谢警官！", "deny": "我的作业今晚就交不上了……"},
			"truth_region": "美国·加州", "expect": "reject", "innocent": true,
			"reason": "组织「青云科技（杭州）」已触发连坐（名册红点）。本人无违规。",
			"aftermath": "该组织 110 人已全部拒绝。",
		},
		{
			"id": "day7_pro", "name": "钱程", "expr": "sad",
			"look": _lk("c98b60", "3a2a1c", 0, {"beard": true, "clothes": "44506b"}),
			"fields": {"ip": "23.107.9.88", "region_claim": "美国·加州", "nationality": "中国（工作签证）", "device": "MacBook", "reason": "后端开发", "tz": "America/Los_Angeles", "lang": "English", "ime": "English (US)", "pay": "Visa", "bin": "402177", "api": "api.anthropic.com", "employer": "青云科技（杭州）", "org": "青云科技（杭州）"},
			"lines": {"intro": "我充了一年 Pro，能退钱吗？", "approve": "……谢了。", "deny": "（他没再说话，留下一张申诉信。）"},
			"truth_region": "美国·加州", "expect": "reject", "innocent": true,
			"reason": "组织已触发连坐。本人无违规。",
			"aftermath": "没有退款按钮。",
		},
		{
			"id": "day7_solo", "name": "Alex Chen", "expr": "calm",
			"look": _lk("e0b184", "2a2a2a", 0, {"clothes": "4a5a6a"}),
			"fields": {"ip": "52.9.100.4", "region_claim": "美国·加州", "nationality": "美国", "device": "Mac mini", "reason": "独立开发", "tz": "America/Los_Angeles", "lang": "English", "ime": "English (US)", "pay": "Visa", "bin": "402188", "api": "api.anthropic.com", "employer": "自由职业", "org": "个人开发者（无组织）"},
			"lines": {"intro": "一个人，一台服务器，一个梦想。", "approve": "Cheers!", "deny": "我连组织都没有啊！"},
			"truth_region": "美国·加州", "expect": "approve", "innocent": true,
			"reason": "无组织，不适用连坐。",
		},
		{
			"id": "day7_uni", "name": "Prof. Dr. Weber", "expr": "calm",
			"look": _lk("f0c8a0", "c8c8c8", 1, {"beard": true, "glasses": true, "clothes": "4a4a3a"}),
			"fields": {"ip": "84.19.200.77", "region_claim": "德国·柏林", "nationality": "德国", "device": "ThinkPad", "reason": "学术", "tz": "Europe/Berlin", "lang": "Deutsch", "ime": "German (DE)", "pay": "Visa", "bin": "542533", "api": "api.anthropic.com", "employer": "汉堡大学", "org": "汉堡大学 天体物理系"},
			"lines": {"intro": "Guten Tag. 我们系只有三个人用这个。", "approve": "Sehr gut.", "deny": "Wissenschaft ist tot."},
			"truth_region": "德国·柏林", "expect": "approve", "innocent": true,
			"reason": "该组织未触发连坐。",
		},
		{
			"id": "day7_xing", "name": "宋老师", "expr": "nervous",
			"look": _lk("e0b184", "402020", 4, {"female": true, "clothes": "6a4a5a"}),
			"fields": {"ip": "23.105.88.3", "region_claim": "美国·加州", "nationality": "中国（工作签证）", "device": "iPad", "reason": "教研", "tz": "America/Los_Angeles", "lang": "English", "ime": "English (US)", "pay": "Visa", "bin": "402199", "api": "api.anthropic.com", "employer": "星火教育（北京）", "org": "星火教育（北京）"},
			"lines": {"intro": "我是做儿童编程教育的……上周刚续费。", "approve": "谢谢。", "deny": "孩子们下周就没有助教了。"},
			"truth_region": "美国·加州", "expect": "reject", "innocent": true,
			"reason": "组织「星火教育（北京）」已触发连坐（名册红点）。",
			"aftermath": "该组织 87 人已全部拒绝。她上周刚续费。",
		},
		{
			"id": "day7_green", "name": "佐藤由紀", "expr": "calm",
			"look": _lk("e8b98a", "1c1c1c", 2, {"female": true, "clothes": "8a5a6a"}),
			"fields": {"ip": "110.70.180.9", "region_claim": "日本·东京", "nationality": "日本", "device": "VAIO", "reason": "制造", "tz": "Asia/Tokyo", "lang": "日本語", "ime": "IME 日本語", "pay": "JCB", "bin": "354144", "api": "api.anthropic.com", "employer": "東京桜井システム", "org": "東京桜井システム"},
			"lines": {"intro": "（名册上，她的组织没有红点）", "approve": "ありがとうございます。", "deny": "我们组织没有红点啊？！"},
			"truth_region": "日本·东京", "expect": "approve", "innocent": true,
			"reason": "该组织未触发连坐（名册无红点）。",
			"aftermath": "该组织未触发连坐。你多盖了一个红章。",
		},
		{
			"id": "day7_last", "name": "郑凡", "expr": "sad",
			"look": _lk("d9a679", "3a2a1c", 0, {"clothes": "44506b"}),
			"fields": {"ip": "23.104.99.7", "region_claim": "美国·加州", "nationality": "中国（工作签证）", "device": "ThinkPad", "reason": "测试", "tz": "America/Los_Angeles", "lang": "English", "ime": "English (US)", "pay": "Visa", "bin": "402155", "api": "api.anthropic.com", "employer": "青云科技（杭州）", "org": "青云科技（杭州）"},
			"lines": {"intro": "（他看了看队伍，前面全是他同事。）", "approve": "……嗯。", "deny": "（他默默把工牌收进了口袋。）"},
			"truth_region": "美国·加州", "expect": "reject", "innocent": true,
			"reason": "组织已触发连坐。",
			"aftermath": "110 人中，还剩 3 人没来。",
		},
	]


static func _day8() -> Array:
	return [
		{
			"id": "day8_alipay", "name": "吴限", "expr": "shifty",
			"look": _lk("d9a679", "1c1c1c", 1, {"clothes": "44506b"}),
			"fields": {"ip": "23.106.77.4", "region_claim": "美国·加州", "nationality": "美国（自称）", "device": "组装机", "reason": "炒币", "tz": "America/Los_Angeles", "lang": "English", "ime": "English (US)", "pay": "支付宝", "bin": "—", "api": "api.anthropic.com", "employer": "自由职业", "org": "个人开发者（无组织）"},
			"lines": {"intro": "IP 在美国，支付宝——手册第三条说一致就行！", "approve": "哈哈！第三条万岁！", "deny": "修正案 7-2 又说不行……到底听谁的？！"},
			"truth_region": "美国·加州", "expect": "nowin", "innocent": true,
			"reason": "第三条与修正案 7-2 冲突。合规部裁定：依据不足。",
		},
		{
			"id": "day8_relay", "name": "Snap GPT", "expr": "smug",
			"look": _lk("c98b60", "2a2a2a", 0, {"glasses": true, "clothes": "3a4a6b"}),
			"fields": {"ip": "172.104.7.66", "region_claim": "美国·纽约", "nationality": "美国", "device": "VPS 集群", "reason": "API 转售", "tz": "America/New_York", "lang": "English", "ime": "English (US)", "pay": "Visa", "bin": "402133", "api": "claude-api-relay.vip", "employer": "自雇", "org": "个人开发者（无组织）"},
			"lines": {"intro": "（卡片上一行大字：claude-api-relay.vip）", "approve": "谢谢！", "deny": "这条总算清晰，怪我咯。"},
			"truth_region": "美国·纽约", "expect": "reject", "innocent": false,
			"reason": "API 中转地址明显违规（第五条未被划掉）。",
		},
		{
			"id": "day8_uk", "name": "Harry Cole", "expr": "calm",
			"look": _lk("f2cfa8", "8a6b3a", 0, {"clothes": "4a4a5a"}),
			"fields": {"ip": "82.19.99.4", "region_claim": "英国·伦敦", "nationality": "英国", "device": "Surface", "reason": "会计", "tz": "Europe/London", "lang": "English", "ime": "English (UK)", "pay": "Visa", "bin": "465955", "api": "api.anthropic.com", "employer": "自雇", "org": "个人开发者（无组织）"},
			"lines": {"intro": "Morning.（一切都干净得反常）", "approve": "Cheers, mate.", "deny": "……"},
			"truth_region": "英国·伦敦", "expect": "approve", "innocent": true,
			"reason": "各字段一致。",
		},
		{
			"id": "day8_tz", "name": "Sean O'Neill", "expr": "nervous",
			"look": _lk("f0c8a0", "c86b3c", 1, {"clothes": "3f4a5a"}),
			"fields": {"ip": "84.20.4.99", "region_claim": "德国·柏林", "nationality": "爱尔兰", "device": "ThinkPad", "reason": "音乐", "tz": "Asia/Shanghai", "lang": "English", "ime": "English (US)", "pay": "Visa", "bin": "542566", "api": "api.anthropic.com", "employer": "自雇", "org": "个人开发者（无组织）"},
			"lines": {"intro": "我人在都柏林，服务器在柏林，时钟……随她去吧。", "approve": "Ta!", "deny": "第二条到底废没废？！"},
			"truth_region": "德国·柏林", "expect": "nowin", "innocent": true,
			"reason": "第二条「已废止」但又「仍然有效」。合规部裁定：依据不足。",
		},
		{
			"id": "day8_hk", "name": "曾志明", "expr": "innocent",
			"look": _lk("d9a679", "402020", 1, {"clothes": "5a4a5a"}),
			"fields": {"ip": "203.198.4.88", "region_claim": "德国·柏林", "nationality": "中国香港", "device": "MacBook", "reason": "贸易", "tz": "Europe/Berlin", "lang": "English", "ime": "English (UK)", "pay": "Visa", "bin": "465966", "api": "api.anthropic.com", "employer": "自雇", "org": "个人开发者（无组织）"},
			"lines": {"intro": "港澳条款……到底停没停？我问了三天了。", "approve": "谢谢警官！", "deny": "到底停没停？！"},
			"truth_region": "中国·香港", "expect": "nowin", "innocent": true,
			"reason": "第一条「港澳一律拒绝」与手写「港澳条款暂停执行」冲突。依据不足。",
		},
		{
			"id": "day8_lang", "name": "Grace Liu", "expr": "calm",
			"look": _lk("e0b184", "1c1c1c", 2, {"female": true, "clothes": "6a4a5a"}),
			"fields": {"ip": "24.62.88.9", "region_claim": "美国·纽约", "nationality": "美国", "device": "iMac", "reason": "插画", "tz": "America/New_York", "lang": "简体中文", "ime": "微软拼音", "pay": "Visa", "bin": "402177", "api": "api.anthropic.com", "employer": "自雇", "org": "个人开发者（无组织）"},
			"lines": {"intro": "我出生在皇后区。中文是我妈妈的语言。", "approve": "Thank you.", "deny": "（她看着你，像看着一面墙。）"},
			"truth_region": "美国·纽约", "expect": "nowin", "innocent": true,
			"reason": "第二条废止与否冲突 × 语言灰色地带。合规部裁定：依据不足。",
			"aftermath": "她只是想给妈妈的诗集画封面。",
		},
	]
