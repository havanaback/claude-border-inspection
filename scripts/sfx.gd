extends Node
## 程序化音效（ autoload：Sfx ）
## 所有声音在启动时用正弦/噪声合成 16bit WAV，不依赖任何外部素材。

const RATE := 22050

var _streams := {}
var _pool: Array[AudioStreamPlayer] = []
var _ambient: AudioStreamPlayer = null
var _heartbeat: AudioStreamPlayer = null


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	_build_all()


func play(name: String, volume_db: float = 0.0, pitch: float = 1.0) -> void:
	if not _streams.has(name):
		return
	var p := _get_player()
	p.stream = _streams[name]
	p.volume_db = volume_db
	p.pitch_scale = pitch
	p.play()


func start_ambient() -> void:
	if _ambient == null:
		_ambient = _loop_player("hum", -22.0)
	if not _ambient.playing:
		_ambient.play()


func stop_ambient() -> void:
	if _ambient != null and _ambient.playing:
		_ambient.stop()


func start_heartbeat() -> void:
	if _heartbeat == null:
		_heartbeat = _loop_player("heart", -8.0)
	if not _heartbeat.playing:
		_heartbeat.play()


func stop_heartbeat() -> void:
	if _heartbeat != null and _heartbeat.playing:
		_heartbeat.stop()


func _loop_player(stream_name: String, vol: float) -> AudioStreamPlayer:
	var p := AudioStreamPlayer.new()
	p.stream = _streams[stream_name]
	p.volume_db = vol
	add_child(p)
	return p


func _get_player() -> AudioStreamPlayer:
	for p in _pool:
		if not p.playing:
			return p
	var p := AudioStreamPlayer.new()
	add_child(p)
	_pool.append(p)
	return p


# ---------------------------------------------------------------- 合成器

func _build_all() -> void:
	_streams["stamp"] = _sfx_stamp(95.0)
	_streams["stamp_deny"] = _sfx_stamp(72.0)
	_streams["stamp_move"] = _sfx_slide()
	_streams["beep"] = _sfx_tone(1180.0, 0.07, "square", 0.5)
	_streams["beep_low"] = _sfx_tone(540.0, 0.09, "square", 0.5)
	_streams["ding"] = _sfx_tone(880.0, 0.35, "sine", 0.4, 1320.0)
	_streams["page"] = _sfx_noise(0.16, 0.5, 900.0)
	_streams["type"] = _sfx_noise(0.03, 0.7, 2600.0)
	_streams["knock"] = _sfx_knock()
	_streams["steps"] = _sfx_steps(4, 92.0, 0.16, 130.0)
	_streams["shoes"] = _sfx_steps(5, 150.0, 0.1, 420.0)
	_streams["murmur"] = _sfx_murmur()
	_streams["coin"] = _sfx_coins()
	_streams["sad"] = _sfx_sad()
	_streams["badge"] = _sfx_stamp(60.0)
	_streams["buzz"] = _sfx_tone(160.0, 0.5, "saw", 0.6)
	_streams["shutter"] = _sfx_noise(0.05, 0.8, 3200.0)
	_streams["heart"] = _loop_heart()
	_streams["hum"] = _loop_hum()


func _to_wav(samples: PackedFloat32Array) -> AudioStreamWAV:
	var bytes := PackedByteArray()
	bytes.resize(samples.size() * 2)
	for i in samples.size():
		var v := int(clamp(samples[i], -1.0, 1.0) * 32000.0)
		bytes.encode_s16(i * 2, v)
	var w := AudioStreamWAV.new()
	w.format = AudioStreamWAV.FORMAT_16_BITS
	w.mix_rate = RATE
	w.stereo = false
	w.data = bytes
	return w


func _silence(sec: float) -> PackedFloat32Array:
	return PackedFloat32Array()
	# 长度在拼接时按需扩展


func _mix(dst: PackedFloat32Array, src: PackedFloat32Array, at_sec: float) -> PackedFloat32Array:
	var start := int(at_sec * RATE)
	var need := start + src.size()
	while dst.size() < need:
		dst.append(0.0)
	for i in src.size():
		dst[start + i] += src[i]
	return dst


func _tone(f: float, dur: float, wave: String = "sine", decay: float = 6.0, f_end: float = -1.0) -> PackedFloat32Array:
	var n := int(dur * RATE)
	var out := PackedFloat32Array()
	var phase := 0.0
	for i in n:
		var t := float(i) / RATE
		var cur_f := f if f_end < 0.0 else lerpf(f, f_end, float(i) / n)
		phase += TAU * cur_f / RATE
		var s := 0.0
		match wave:
			"square":
				s = 1.0 if fmod(phase, TAU) < PI else -1.0
			"saw":
				s = fmod(phase, TAU) / TAU * 2.0 - 1.0
			_:
				s = sin(phase)
		var env := exp(-decay * t)
		out.append(s * env * 0.6)
	return out


func _noise_burst(dur: float, decay: float, cutoff_hz: float) -> PackedFloat32Array:
	var n := int(dur * RATE)
	var out := PackedFloat32Array()
	var last := 0.0
	var a := cutoff_hz / RATE
	for i in n:
		var t := float(i) / RATE
		var w := randf() * 2.0 - 1.0
		last += a * (w - last)          # 一阶低通
		var env := exp(-decay * t)
		out.append(last * env * 1.6)
	return out


func _sfx_tone(f: float, dur: float, wave: String, decay: float, f_end: float = -1.0) -> AudioStreamWAV:
	return _to_wav(_tone(f, dur, wave, decay, f_end))


func _sfx_noise(dur: float, decay: float, cutoff: float) -> AudioStreamWAV:
	return _to_wav(_noise_burst(dur, decay, cutoff))


func _sfx_stamp(freq: float) -> AudioStreamWAV:
	var out := PackedFloat32Array()
	out = _mix(out, _tone(freq, 0.22, "sine", 26.0), 0.0)
	out = _mix(out, _tone(freq * 2.0, 0.1, "sine", 40.0), 0.0)
	out = _mix(out, _noise_burst(0.05, 60.0, 2400.0), 0.0)
	return _to_wav(out)


func _sfx_slide() -> AudioStreamWAV:
	return _to_wav(_tone(300.0, 0.18, "sine", 14.0, 90.0))


func _sfx_knock() -> AudioStreamWAV:
	var out := PackedFloat32Array()
	out = _mix(out, _tone(140.0, 0.09, "sine", 34.0), 0.0)
	out = _mix(out, _tone(130.0, 0.09, "sine", 34.0), 0.16)
	out = _mix(out, _noise_burst(0.03, 70.0, 1800.0), 0.0)
	out = _mix(out, _noise_burst(0.03, 70.0, 1800.0), 0.16)
	return _to_wav(out)


func _sfx_steps(count: int, freq: float, dur: float, cutoff: float) -> AudioStreamWAV:
	var out := PackedFloat32Array()
	for i in count:
		var t := i * 0.24
		out = _mix(out, _tone(freq, dur, "sine", 30.0), t)
		out = _mix(out, _noise_burst(0.04, 40.0, cutoff), t)
	return _to_wav(out)


func _sfx_murmur() -> AudioStreamWAV:
	var out := PackedFloat32Array()
	out = _mix(out, _noise_burst(1.4, 1.6, 420.0), 0.0)
	out = _mix(out, _tone(190.0, 0.5, "sine", 3.0, 150.0), 0.1)
	out = _mix(out, _tone(240.0, 0.45, "sine", 3.5, 170.0), 0.55)
	return _to_wav(out)


func _sfx_coins() -> AudioStreamWAV:
	var out := PackedFloat32Array()
	out = _mix(out, _tone(1450.0, 0.09, "square", 18.0), 0.0)
	out = _mix(out, _tone(1930.0, 0.14, "square", 16.0), 0.1)
	return _to_wav(out)


func _sfx_sad() -> AudioStreamWAV:
	var out := PackedFloat32Array()
	out = _mix(out, _tone(520.0, 0.22, "sine", 7.0, 392.0), 0.0)
	out = _mix(out, _tone(392.0, 0.34, "sine", 6.0, 262.0), 0.24)
	return _to_wav(out)


func _loop_heart() -> AudioStreamWAV:
	var out := PackedFloat32Array()
	out = _mix(out, _tone(58.0, 0.13, "sine", 20.0), 0.0)
	out = _mix(out, _tone(52.0, 0.11, "sine", 22.0), 0.26)
	var pad := int(0.95 * RATE) - out.size()
	for i in max(pad, 0):
		out.append(0.0)
	var w := _to_wav(out)
	w.loop_mode = AudioStreamWAV.LOOP_FORWARD
	w.loop_begin = 0
	w.loop_end = out.size()
	return w


func _loop_hum() -> AudioStreamWAV:
	var dur := 4.0
	var n := int(dur * RATE)
	var out := PackedFloat32Array()
	var last := 0.0
	var a := 380.0 / RATE
	var phase := 0.0
	for i in n:
		var w := randf() * 2.0 - 1.0
		last += a * (w - last)
		phase += TAU * 118.0 / RATE
		var v := last * 0.16 + sin(phase) * 0.05
		out.append(v)
	# 交叉淡化首尾避免爆音
	var fade := int(0.05 * RATE)
	for i in fade:
		var k := float(i) / fade
		out[i] *= k
		out[out.size() - 1 - i] *= k
	var w := _to_wav(out)
	w.loop_mode = AudioStreamWAV.LOOP_FORWARD
	w.loop_begin = 0
	w.loop_end = out.size()
	return w
