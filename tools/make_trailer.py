# -*- coding: utf-8 -*-
# 预告片合成：标题卡/结尾卡(PIL) + 游戏录像(ffmpeg) + 字幕
import os
import subprocess
import sys

ROOT = os.path.dirname(os.path.abspath(__file__))
DOCS = os.path.join(ROOT, "docs")
FONT = r"C:\Windows\Fonts\msyhbd.ttc"
FONT_R = r"C:\Windows\Fonts\msyh.ttc"
if not os.path.exists(FONT):
    FONT = FONT_R


import imageio_ffmpeg
FF = imageio_ffmpeg.get_ffmpeg_exe()


def run(cmd):
    if cmd[0] == "ffmpeg":
        cmd = [FF] + cmd[1:]
    print(">>", " ".join(cmd)[:180])
    r = subprocess.run(cmd, capture_output=True, text=True, encoding="utf-8", errors="replace")
    if r.returncode != 0:
        print(r.stderr[-3000:])
        sys.exit(1)
    return r


def probe_dur(path):
    r = subprocess.run([FF, "-i", path], capture_output=True, text=True, encoding="utf-8", errors="replace")
    import re
    m = re.search(r"Duration: (\d+):(\d+):(\d+\.\d+)", r.stderr)
    if not m:
        print(r.stderr[-800:])
        sys.exit(1)
    h, mnt, sec = m.groups()
    return int(h) * 3600 + int(mnt) * 60 + float(sec)


def make_card(name, lines, seconds):
    """lines: [(text, size, color, y_offset_ratio), ...]"""
    from PIL import Image, ImageDraw, ImageFont
    W, H = 1280, 720
    img = Image.new("RGB", (W, H), (23, 26, 20))
    d = ImageDraw.Draw(img)
    # 边框
    d.rectangle([36, 36, W - 36, H - 36], outline=(86, 94, 78), width=3)
    d.rectangle([46, 46, W - 46, H - 46], outline=(58, 64, 52), width=1)
    for text, size, color, yr in lines:
        font = ImageFont.truetype(FONT, size)
        bbox = d.textbbox((0, 0), text, font=font)
        tw = bbox[2] - bbox[0]
        th = bbox[3] - bbox[1]
        y = int(H * yr) - th // 2
        d.text(((W - tw) // 2, y), text, font=font, fill=color)
    # 印章装饰
    stamp = ImageFont.truetype(FONT, 30)
    d.text((W - 210, H - 130), "拒 绝", font=stamp, fill=(150, 45, 30))
    d.rectangle([W - 220, H - 145, W - 70, H - 75], outline=(150, 45, 30), width=3)
    out = os.path.join(DOCS, name)
    img.save(out)
    return out, seconds


def main():
    print("== 生成标题卡/结尾卡 ==")
    card1, d1 = make_card("_card_open.png", [
        ("边境检察官", 88, (217, 220, 200), 0.34),
        ("Claude 入境审查", 40, (194, 59, 34), 0.50),
        ("Papers, please. 以及你的时区，你的语言包，还有你的宫廷玉液酒。", 22, (160, 166, 148), 0.63),
    ], 4.0)
    card2, d2 = make_card("_card_end.png", [
        ("8 个工作日 · 2 个结局 · 0 个无辜通行证", 40, (217, 220, 200), 0.34),
        ("每拒绝一位旅客，解锁一个国产大模型", 26, (160, 166, 148), 0.47),
        ("纯属虚构 · 致敬 Lucas Pope《Papers, Please》", 22, (130, 136, 120), 0.60),
        ("ZCode × GLM 制作", 20, (130, 136, 120), 0.70),
    ], 5.0)

    segs = [
        ("_rec_title.avi", 4.5, "你是 Anthrotzka 边检站的检察官"),
        ("_rec_day1.avi", 13.5, "核对 IP · 时区 · 语言 · 支付 · 股权……规则一天比一天厚"),
        ("_rec_day3.avi", 16.5, "宫廷玉液酒？答得出，就拘留。宁可错抓，不可漏放"),
        ("_rec_final.avi", 18.0, "最终日，接受审查的是你自己。没有人是安全的"),
    ]

    print("== 裁剪各段并加字幕/过渡 ==")
    parts = []
    prev = None
    for i, (f, want_dur, sub) in enumerate(segs):
        src = os.path.join(DOCS, f)
        real = probe_dur(src)
        dur = min(want_dur, real - 0.15)
        out = os.path.join(DOCS, "_seg%d.mp4" % i)
        fade = "fade=t=in:st=0:d=0.25,fade=t=out:st=%.2f:d=0.3" % (dur - 0.3)
        sub_esc = sub.replace("\\", "").replace("'", "").replace(":", "\\:").replace("%", "\\%")
        vf = (
            "scale=1280:720,fps=30,setsar=1,"
            + fade
            + ",drawtext=fontfile='%s':text='%s':fontcolor=white:fontsize=30:borderw=2:bordercolor=black:x=(w-text_w)/2:y=h-72:alpha='if(lt(t,0.6),0,if(lt(t,1.0),(t-0.6)/0.4,1))'"
            % (FONT.replace("\\", "/").replace(":", "\\:"), sub_esc)
        )
        af = "aresample=48000,pan=stereo|c0=c0|c1=c1,volume=1.6,afade=t=out:st=%.2f:d=0.3" % (dur - 0.3)
        run(["ffmpeg", "-y", "-i", src, "-t", "%.3f" % dur,
             "-vf", vf, "-af", af,
             "-c:v", "libx264", "-preset", "medium", "-crf", "20",
             "-c:a", "aac", "-b:a", "160k", "-ar", "48000", out])
        parts.append((out, dur))
        prev = out

    print("== 卡片段转视频 ==")
    cards = [(card1, d1, None), (card2, d2, None)]
    card_parts = []
    for i, (img, dur, _) in enumerate(cards):
        out = os.path.join(DOCS, "_card%d.mp4" % i)
        fade = "fade=t=in:st=0:d=0.4,fade=t=out:st=%.2f:d=0.6" % (dur - 0.6)
        run(["ffmpeg", "-y", "-loop", "1", "-i", img, "-f", "lavfi", "-i", "anullsrc=r=48000:cl=stereo",
             "-t", "%.3f" % dur, "-vf", "fps=30,scale=1280:720,setsar=1," + fade,
             "-c:v", "libx264", "-preset", "medium", "-crf", "20",
             "-c:a", "aac", "-b:a", "128k", "-shortest", out])
        card_parts.append(out)

    print("== 拼接 ==")
    concat_txt = os.path.join(DOCS, "_concat.txt")
    order = [card_parts[0]] + [p[0] for p in parts] + [card_parts[1]]
    with open(concat_txt, "w", encoding="utf-8") as fh:
        for f in order:
            fh.write("file '%s'\n" % f.replace("\\", "/"))
    final_out = os.path.join(DOCS, "trailer.mp4")
    run(["ffmpeg", "-y", "-f", "concat", "-safe", "0", "-i", concat_txt,
         "-c", "copy", final_out])
    dur = probe_dur(final_out)
    print("TRAILER_OK %s  %.1fs  %.1fMB" % (final_out, dur, os.path.getsize(final_out) / 1e6))


if __name__ == "__main__":
    main()
