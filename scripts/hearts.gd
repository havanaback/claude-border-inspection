extends Control
## 良心值：手绘红心条（不依赖字体图标）

var value := 10:
	set(v):
		value = v
		queue_redraw()
var maximum := 10


func _init(max_val: int = 10) -> void:
	maximum = max_val
	custom_minimum_size = Vector2(maximum * 22 + 4, 22)


func _draw() -> void:
	for i in maximum:
		var filled := i < value
		var c := Color("c23b3b") if filled else Color("4a4f43")
		var x := 4.0 + i * 22.0
		var y := 11.0
		draw_circle(Vector2(x + 5, y - 3), 5.0, c)
		draw_circle(Vector2(x + 12, y - 3), 5.0, c)
		draw_colored_polygon(
			PackedVector2Array([Vector2(x - 0.5, y - 1), Vector2(x + 17.5, y - 1), Vector2(x + 8.5, y + 10)]),
			c
		)
