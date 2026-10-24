extends Node
## 全局游戏状态（ autoload：Game ）
## 天数、良心值、工资、统计、图鉴、申诉信、存档。

signal conscience_changed(value: int)
signal gallery_entry_unlocked(entry: Dictionary)

const START_CONSCIENCE := 10
const TOTAL_DAYS := 8

var test_mode := false
var speed := 1.0            # 自动测试时调快
var shot := ""              # --shot=xxx：渲染指定画面并截图退出


## 渲染指定画面并保存截图（开发自检用）
func take_shot(name: String) -> void:
	if shot != name:
		return
	await get_tree().process_frame
	await get_tree().process_frame
	await get_tree().create_timer(0.8).timeout
	var img := get_viewport().get_texture().get_image()
	img.save_png("user://shot_%s.png" % name)
	print("SHOT_SAVED ", name)
	get_tree().quit(0)
var day := 1
var conscience := START_CONSCIENCE
var money := 0

var total_judged := 0
var total_caught := 0
var total_missed := 0
var total_wrong_basis := 0
var total_rejected := 0
var total_approved := 0

var gallery_ids: Array[String] = []
var achievement_thanks := false
var letters: Array[Dictionary] = []   # {sender, day, text}
var ending_reached := ""

var day_stats := {}                   # 当日 booth 写入
var rng := RandomNumberGenerator.new()


func reset_run() -> void:
	day = 1
	conscience = START_CONSCIENCE
	money = 0
	total_judged = 0
	total_caught = 0
	total_missed = 0
	total_wrong_basis = 0
	total_rejected = 0
	total_approved = 0
	gallery_ids.clear()
	achievement_thanks = false
	letters.clear()
	ending_reached = ""
	day_stats = {}
	rng.seed = 42 if test_mode else int(Time.get_unix_time_from_system())


## 统一等待（自动测试时加速）
func wait(sec: float) -> void:
	await get_tree().create_timer(sec * speed).timeout


func hit_conscience(n: int = 1) -> void:
	conscience = max(0, conscience - n)
	conscience_changed.emit(conscience)


func add_letter(sender: String, text: String) -> void:
	letters.append({"sender": sender, "day": day, "text": text})


## 拒绝一位旅客 → 解锁一个图鉴条目；集齐触发成就
func unlock_gallery_next() -> Dictionary:
	var all := Rules.gallery_entries()
	for e in all:
		if e["id"] not in gallery_ids:
			gallery_ids.append(e["id"])
			if gallery_ids.size() >= all.size() and not achievement_thanks:
				achievement_thanks = true
			gallery_entry_unlocked.emit(e)
			return e
	return {}


func apply_day(stats: Dictionary) -> void:
	day_stats = stats
	total_judged += stats.get("judged", 0)
	total_caught += stats.get("caught", 0)
	total_missed += stats.get("missed", 0)
	total_wrong_basis += stats.get("wrong_basis", 0)


## 家庭生活状况（由累计工资决定）
func family_tier() -> int:
	if money >= 160:
		return 2      # 有肉
	if money >= 80:
		return 1      # 面包加汤
	return 0          # 只有面包


func family_text() -> String:
	match family_tier():
		2:
			return "今晚桌上有炖肉。全家福照片擦得干干净净。"
		1:
			return "今晚是面包和一碗稀汤。照片还在相框里。"
		_:
			return "今晚只有面包。你盯着全家福看了很久。"


func save_game() -> void:
	if test_mode:
		return
	var f := FileAccess.open("user://save.json", FileAccess.WRITE)
	if f == null:
		return
	var data := {
		"day": day, "conscience": conscience, "money": money,
		"total_judged": total_judged, "total_caught": total_caught,
		"total_missed": total_missed, "total_wrong_basis": total_wrong_basis,
		"total_rejected": total_rejected, "total_approved": total_approved,
		"gallery": ", ".join(gallery_ids),
		"achievement": achievement_thanks,
		"letters": letters,
	}
	f.store_string(JSON.stringify(data))
	f.close()


func has_save() -> bool:
	return FileAccess.file_exists("user://save.json")


func load_game() -> bool:
	var f := FileAccess.open("user://save.json", FileAccess.READ)
	if f == null:
		return false
	var parsed = JSON.parse_string(f.get_as_text())
	f.close()
	if parsed == null or not parsed is Dictionary:
		return false
	day = int(parsed.get("day", 1))
	conscience = int(parsed.get("conscience", START_CONSCIENCE))
	money = int(parsed.get("money", 0))
	total_judged = int(parsed.get("total_judged", 0))
	total_caught = int(parsed.get("total_caught", 0))
	total_missed = int(parsed.get("total_missed", 0))
	total_wrong_basis = int(parsed.get("total_wrong_basis", 0))
	total_rejected = int(parsed.get("total_rejected", 0))
	total_approved = int(parsed.get("total_approved", 0))
	achievement_thanks = bool(parsed.get("achievement", false))
	gallery_ids.clear()
	for id in String(parsed.get("gallery", "")).split(", ", false):
		gallery_ids.append(id)
	letters.clear()
	for l in parsed.get("letters", []):
		letters.append(l)
	return true


func clear_save() -> void:
	if has_save():
		DirAccess.remove_absolute(ProjectSettings.globalize_path("user://save.json"))
