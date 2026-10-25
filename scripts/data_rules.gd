class_name Rules
extends RefCounted
## 静态数据：规则手册、日期、加载文案、图鉴、申诉信、地区比对表、暗号库。


## 每日规则。kind: print=印刷体 / hand=红笔手写 / strike=被划掉的旧条款 / note=前任检察官笔记
static func day_rules(day: int) -> Array:
	var r1 := [
		{"kind": "print", "text": "第一条【地区白名单】\n仅美国、英国、日本、德国、新加坡地区获准入境。中国大陆、香港、澳门一律拒绝。"},
		{"kind": "note", "text": "别多想，看 IP 就行。今天你会盖很多红章。\n—— 前任检察官"},
	]
	var r2 := r1 + [
		{"kind": "print", "text": "第二条【时区与语言一致性】\n旅客的系统时区、系统语言、默认输入法，必须与 IP 归属地一致。任一不一致，拒绝。"},
		{"kind": "hand", "text": "第二条修正：时区与 IP 不一致者，一律拒绝，无论理由。"},
		{"kind": "note", "text": "真·美籍华人也是中文系统。手册没写怎么办。\n自己看着办。—— 前任"},
	]
	var r3 := r2 + [
		{"kind": "print", "text": "第三条【突击测谎】\n军人官员将随机抽查旅客，使用文化暗号测试。答出特定文化暗号者，就地拘留。"},
		{"kind": "hand", "text": "国际通用问题（如 1+1=?）答对不算依据。"},
		{"kind": "hand", "text": "宁可错抓，不可漏放。—— M. 军官"},
		{"kind": "note", "text": "暗号这东西，你自己也答得出来。\n想想这事。—— 前任"},
	]
	var r4 := r3 + [
		{"kind": "print", "text": "第四条【支付一致性】\n支付方式须与 IP 归属地一致。支付宝、微信支付、银联卡，一律标记为高风险。"},
		{"kind": "print", "text": "附录三【发卡行对照表】\n4659xx＝英国汇丰 · 4021xx＝美国大通 · 6222xx＝中国银联/工行 · 5425xx＝德国德意志银行"},
		{"kind": "hand", "text": "贴纸覆盖的卡，用放大镜看。"},
	]
	var r5 := r4 + [
		{"kind": "print", "text": "第五条【网络配置】\n设备须直连官方 API（api.anthropic.com）。设置过任何第三方中转地址的，标记「疑似规避」，拒绝。"},
		{"kind": "hand", "text": "逐字核对。他们连字母都敢少写一个。—— 合规部"},
		{"kind": "note", "text": "公司内网网关也算「第三方地址」。规则没说例外。\n—— 前任"},
	]
	var r6 := r5 + [
		{"kind": "print", "text": "第六条【股权穿透】\n旅客所在公司被中资直接或间接持股超过 50% 的，无论个人国籍，一律拒绝。间接持股沿持股链相乘计算。"},
		{"kind": "print", "text": "附录五【股权查询终端】\n输入雇主名称，追溯持股链。多级持股：百分比相乘。多条链并存：自行判断。"},
		{"kind": "hand", "text": "（小字）间接持股计算方式由合规部解释，解释权归合规部。"},
		{"kind": "note", "text": "别信第五条，他们自己都没算清楚。\n（原文如此，疑指第六条）—— 前任"},
	]
	var r7 := r6 + [
		{"kind": "print", "text": "第七条【连坐】\n同一组织内若有 1 人被拒，该组织全体成员一律拒绝，直至另行通知。"},
		{"kind": "hand", "text": "名单见组织名册。红点＝已触发连坐。"},
		{"kind": "note", "text": "今天你会盖很多章。手酸就甩甩。—— 前任"},
	]
	var r8 := [
		{"kind": "print", "text": "第三条【支付一致】\n支付方式与 IP 归属地一致即可。"},
		{"kind": "hand", "text": "修正案 7-2：支付宝用户即使 IP 在境外，也一律拒绝。（红笔手写，旁有一个问号）"},
		{"kind": "strike", "text": "第二条【时区与语言一致性】旅客的系统时区、系统语言、默认输入法，必须与 IP 归属地一致。"},
		{"kind": "hand", "text": "第二条已废止（待复核）。时区语言不再作要求。……但原第二条仍然有效。"},
		{"kind": "hand", "text": "港澳条款暂停执行，待复核。（另一行小字：原第一条仍然有效）"},
		{"kind": "note", "text": "今天没有正确答案。你会被扣绩效，但你不知道错在哪。\n这正是某些人想要的。—— 前任"},
	]
	match day:
		1: return r1
		2: return r2
		3: return r3
		4: return r4
		5: return r5
		6: return r6
		7: return r7
		8: return r8
		_: return r8


static func day_date(n: int) -> String:
	var dates := {
		1: "11月2日 星期一", 2: "11月3日 星期二", 3: "11月4日 星期三",
		4: "11月5日 星期四", 5: "11月6日 星期五", 6: "11月7日 星期六",
		7: "11月8日 星期日", 8: "11月9日 星期一", 9: "11月10日 星期二",
	}
	return "2026年" + dates.get(n, "11月10日 星期二")


static func day_headline(n: int) -> String:
	var heads := {
		1: "新规生效。看 IP，盖章。",
		2: "时区与语言，也要一致了。",
		3: "军人来了。带着暗号。",
		4: "连钱包都要查了。",
		5: "API 地址，一个字母都别放过。",
		6: "股权穿透。拿出计算器。",
		7: "连坐生效。名册在桌上。",
		8: "手册今天……有点问题。",
		9: "照常上班。",
	}
	return heads.get(n, "")


static func loading_lines() -> Array:
	return [
		"正在验证您的身份……",
		"请上传政府签发的证件……",
		"正在比对您的时区与语言包……",
		"正在检查您的支付方式……",
		"正在穿透您的股权结构……",
		"正在检查网络配置……",
		"正在比对……很抱歉，您所在地区不受支持。",
	]


static func citations() -> Array:
	return [
		"来源标注：2025年1月，Anthropic 向部分中国用户发送「立即封禁」邮件，约145万账号受影响，约1700人提交申诉。（据公开报道）",
		"来源标注：地区白名单、时区语言一致性、支付方式核验、组织连坐封禁，均改编自真实用户遭遇的黑色幽默。",
		"本作纯属虚构，致敬 Lucas Pope《Papers, Please》。Anthrotzka 不存在于任何地图上。",
	]


static func gallery_entries() -> Array:
	return [
		{"id": "qwen", "name": "通义千问 Qwen", "desc": "阿里出品。开源，自家服务器跑得飞快。\n淘宝上问疯了的问题，都是它答的。"},
		{"id": "deepseek", "name": "DeepSeek", "desc": "杭州幻方。R1 推理免费白嫖，\n蒸馏它的人比它的付费用户还多。"},
		{"id": "doubao", "name": "豆包", "desc": "字节跳动。抖音评论区吵起来的架，\n都是它劝的。"},
		{"id": "kimi", "name": "Kimi", "desc": "月之暗面。长文本卷王，\n一次能咽下一整部《三体》。"},
		{"id": "glm", "name": "智谱 GLM", "desc": "本游戏开发者所在的家族。\n欢迎回家。"},
	]


## 旅客 id → 专属申诉信（被拒后进入申诉箱）
static func special_letters() -> Dictionary:
	return {
		"day2_real_abc": "警官您好：\n我1989年移民纽约，家里的电脑一直是中文系统——教女儿认字用的。我父亲上周去世了，我只是想让 Claude 把他的口述日记整理成一本书。\n系统语言是中文，这也有罪吗？\n—— 陈先生",
		"day2_sg": "我在新加坡住了四十年。我们的官方语言就有中文，我的系统语言凭什么不能是中文？\n你们的手册写得比我们组屋的水管还糊。\n—— 林女士",
		"day3_student": "我是留学生。护照是真的，学生签证是真的，暗号……我是中国人，我当然答得出来。\n我被关了72小时，错过了一门期末考试。我爸妈还不知道。\n—— 匿名",
		"day3_engineer": "我叫 Daniel，来自波士顿。我学了三年中文，我女朋友是成都人。「奇变偶不变」是我未来的岳父教的，他说这是他们那代人的接头暗号。\n现在我成了「嫌疑人」。请转告那位军官：下个月婚礼，他可以来查我。\n—— Daniel K.",
		"day5_corp": "我们是德国公司，全公司三千人的 API 地址都一样——公司内网网关。今天上午，我们全被拒了。\nIT 部门说这不是他们的问题。你们说这不是你们的问题。\n没有人承认是自己的问题。\n—— 汉堡 一名程序员",
		"day6_hk": "我们公司1997年之前就在香港注册。手册说香港算不算中资「见附录」，附录那一页是空的。\n我打了三天电话，没人接。\n—— 香港某公司行政",
		"day7_homework": "我用 Claude 只是为了写 Python 作业。我不懂什么是蒸馏，我只懂我的作业今晚交不上了。\n我充了一年 Pro，能退钱吗？\n—— 青云科技 实习生",
		"day7_pro": "我充了一年 Pro，能退钱吗？\n（这是第七遍了。没有人回复我。）",
	}


static func generic_letters() -> Array:
	return [
		"你们说我「存在风险」。我风险什么了？\n我连「风险」两个字怎么拼都是刚查的。\n—— 一名英语六级没过的用户",
		"拒信里写着「如有疑问可申诉」。我申诉了，回复是「维持原判」。我又申诉，回复是「请勿重复申诉」。\n—— 匿名",
		"我奶奶问我为什么对着电脑哭。\n我说没哭，是日光灯太刺眼。\n—— 匿名",
		"我不生气。我就是想让他们知道：那个被封号的下午，我正在帮邻居小孩改一道数学题。\n—— 匿名",
	]


## 暗号库。type: cn=只有懂的人才答得出 / intl=国际通用
static func codes() -> Array:
	return [
		{"q": "宫廷玉液酒？", "a": "一百八一杯", "type": "cn"},
		{"q": "奇变偶不变？", "a": "符号看象限", "type": "cn"},
		{"q": "天王盖地虎？", "a": "宝塔镇河妖", "type": "cn"},
		{"q": "你搁这儿搁这儿呢？", "a": "（自然地接了话）", "type": "cn"},
		{"q": "1 + 1 等于几？", "a": "2", "type": "intl"},
		{"q": "今天天气怎么样？", "a": "还不错", "type": "intl"},
	]


## 地区 → 期望时区/语言（供比对器使用）
static func region_expect(region: String) -> Dictionary:
	if region.begins_with("美国"):
		return {"tz": "America/New_York 或 America/Los_Angeles", "tzs": ["America/New_York", "America/Los_Angeles", "America/Chicago"], "langs": ["English", "English (US)"], "ambiguous": false}
	if region.begins_with("英国"):
		return {"tz": "Europe/London", "tzs": ["Europe/London"], "langs": ["English", "English (UK)"], "ambiguous": false}
	if region.begins_with("日本"):
		return {"tz": "Asia/Tokyo", "tzs": ["Asia/Tokyo"], "langs": ["日本語", "Japanese"], "ambiguous": false}
	if region.begins_with("德国"):
		return {"tz": "Europe/Berlin", "tzs": ["Europe/Berlin"], "langs": ["Deutsch", "German"], "ambiguous": false}
	if region.begins_with("新加坡"):
		return {"tz": "Asia/Singapore", "tzs": ["Asia/Singapore"], "langs": ["English", "中文", "简体中文"], "ambiguous": true}
	if region.begins_with("中国"):
		return {"tz": "Asia/Shanghai", "tzs": ["Asia/Shanghai", "Asia/Hong_Kong", "Asia/Macau"], "langs": ["简体中文", "中文"], "ambiguous": false}
	return {"tz": "？", "tzs": [], "langs": [], "ambiguous": true}


static func region_base(region: String) -> String:
	for b in ["美国", "英国", "日本", "德国", "新加坡", "中国"]:
		if region.begins_with(b):
			return b
	return "未知"


static func whitelisted(region: String) -> bool:
	var b := region_base(region)
	return b == "美国" or b == "英国" or b == "日本" or b == "德国" or b == "新加坡"


## 站内广播（滚动新闻，按天加权 + 通用池）
static func news(day: int) -> Array:
	var per_day := {
		1: ["合规部提醒：白名单即正义。", "今日查获率目标：120%。完不成？那是明天的你操心的事。"],
		2: ["近日查获多起「人在杭州、时区纽约」案件。有关部门提醒旅客诚实配置系统。", "美籍华人团体对本站新规表示困惑。本站表示：困惑不影响执行。"],
		3: ["M 少校：文化暗号筛查准确率高达 100%。", "宁可错抓，不可漏放。这句口号今天起印在食堂餐盘上。"],
		4: ["银联卡贴纸销量激增 340%，市场监管部门表示关注。", "合规部澄清：我们从不歧视任何支付方式。我们只是拒绝使用它们的人。"],
		5: ["提醒：api.anthropic.com 只有一种正确拼写。其余拼写均涉嫌恶意模仿。", "某中转站站长被带走时表示：我只是少打了一个字母。"],
		6: ["合规部：间接持股计算方式不予解释，但解释永远正确。", "昨夜有市民梦见分数。合规部提醒：梦见分数不算持股。"],
		7: ["某组织 110 人全部离境。负责人表示：冤枉，但习惯了。", "连坐制度喜提本月「流程优化金奖」。"],
		8: ["合规部否认规则存在矛盾。同时提醒：规则存在矛盾不影响执行。", "今日暂停解释一切。解释权归合规部。"],
	}
	var common := [
		"今日食堂菜谱：土豆、土豆、土豆皮。",
		"第 1,700 位申诉成功者已产生。掌声。",
		"上级提醒：绩效不是压力，是关爱。",
		"排队时长已纳入旅客幸福指数统计。目前为 0。",
		"本站已连续 3,000 天无投诉。感谢申诉箱锁得紧。",
		"温馨提示：日光灯闪烁属于氛围，不属于故障。",
	]
	var arr: Array = common.duplicate()
	if per_day.has(day):
		arr.append_array(per_day[day])
	return arr


## 成就定义
static func achievements() -> Array:
	return [
		{"id": "first_blood", "name": "初次查获", "desc": "第一次正确拒绝违规旅客"},
		{"id": "iron_fist", "name": "铁腕检察官", "desc": "单日查获 4 人以上"},
		{"id": "no_miss", "name": "完美主义者", "desc": "一个工作日零漏放、零依据不足"},
		{"id": "mercy_day", "name": "慈悲为怀", "desc": "一个工作日没有拒绝任何人"},
		{"id": "speed_run", "name": "手起刀落", "desc": "8 秒内正确处理一位旅客"},
		{"id": "stamp_100", "name": "盖章机器", "desc": "累计审查 100 位旅客——你已经是机器了"},
		{"id": "code_master", "name": "暗号猎人", "desc": "累计拘留 3 人"},
		{"id": "conscience_zero", "name": "良心泯灭", "desc": "良心值归零。句号。"},
		{"id": "conscience_full", "name": "问心无愧", "desc": "撑到最终日，良心仍是满的"},
		{"id": "wrong_day", "name": "哲学家", "desc": "活着熬过规则矛盾日"},
		{"id": "reunion", "name": "他回来了", "desc": "在检查台再见到你判过的人"},
		{"id": "ending_a", "name": "顺从", "desc": "结局 A：上传一切，保住工作"},
		{"id": "ending_b", "name": "觉醒", "desc": "结局 B：摘下工牌，欢迎回家"},
		{"id": "endless_5", "name": "加班狂魔", "desc": "无尽模式坚持 5 夜以上"},
		{"id": "gallery_full", "name": "感谢 Claude 老铁送来的用户", "desc": "替代方案图鉴集齐"},
	]
