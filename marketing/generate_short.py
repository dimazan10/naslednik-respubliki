"""Render an 18-second vertical teaser from actual game screenshots."""

from pathlib import Path
import shutil
import subprocess
from PIL import Image, ImageDraw, ImageFont
from generate_art import background

ROOT = Path(__file__).resolve().parents[1]
OUT = Path(__file__).resolve().parent
FRAMES = OUT / "frames"
FRAMES.mkdir(exist_ok=True)
FONT = Path(r"C:\Windows\Fonts")
PAPER = "#e8dfcb"
INK = "#15191d"
GOLD = "#c6a460"
RED = "#9a413a"


def face(size, bold=False):
    return ImageFont.truetype(str(FONT / ("arialbd.ttf" if bold else "arial.ttf")), size)


def title(image, kicker, headline, subline):
    draw = ImageDraw.Draw(image)
    draw.text((70, 90), kicker, font=face(31, True), fill=GOLD)
    draw.text((67, 157), headline, font=face(67, True), fill=PAPER)
    draw.line((70, 273, 1010, 273), fill=GOLD, width=3)
    draw.text((72, 1465), subline, font=face(41), fill=PAPER)
    draw.text((72, 1775), "HEIR TO THE REPUBLIC", font=face(49, True), fill=PAPER)
    draw.text((73, 1840), "Free beta  •  Windows & Linux", font=face(31), fill="#c2b49a")


def screenshot_slide(number, path, crop, kicker, headline, subline):
    dark = background((1080, 1920))
    shot = Image.open(ROOT / path).convert("RGB").crop(crop)
    shot.thumbnail((936, 1050), Image.Resampling.LANCZOS)
    x = (1080 - shot.width) // 2
    y = 362 + (950 - shot.height) // 2
    d = ImageDraw.Draw(dark)
    d.rounded_rectangle((x-7, y-7, x+shot.width+7, y+shot.height+7), radius=10, fill=GOLD)
    dark.paste(shot, (x, y))
    title(dark, kicker, headline, subline)
    dark.save(FRAMES / f"slide_{number}.png", optimize=True)


def generate():
    Image.open(OUT / "shorts_card.png").save(FRAMES / "slide_0.png", optimize=True)
    screenshot_slide(1, "preview_game.png", (263, 61, 997, 650), "WEEK 01 / THE SUCCESSION", "YOU MAKE THE CALL", "Every report needs an answer.")
    screenshot_slide(2, "preview_economy.png", (216, 55, 1053, 652), "WEEK 02 / THE TREASURY", "EVERY BUDGET HAS A COST", "Save the treasury. Lose support.")
    screenshot_slide(3, "preview_foreign.png", (224, 65, 1057, 653), "WEEK 03 / THE BORDER", "TWO NEIGHBORS", "Every offer comes with a price.")
    screenshot_slide(4, "preview_war_crisis.png", (268, 61, 994, 651), "WEEK 04 / THE FRONT", "CAN YOU HOLD THE LINE?", "Your decisions shape what survives.")

    ffmpeg = shutil.which("ffmpeg")
    if not ffmpeg:
        raise RuntimeError("ffmpeg is required to build the teaser")
    command = [ffmpeg, "-y", "-hide_banner", "-loglevel", "error"]
    for index in range(5):
        command += ["-loop", "1", "-framerate", "30", "-t", "4", "-i", str(FRAMES / f"slide_{index}.png")]
    command += ["-stream_loop", "-1", "-i", str(ROOT / "audio/variants/music_03_documents.wav")]
    filters = []
    for index in range(5):
        filters.append(f"[{index}:v]fps=30,format=yuv420p[v{index}]")
    filters += [
        "[v0][v1]xfade=transition=fade:duration=0.5:offset=3.5[x1]",
        "[x1][v2]xfade=transition=fade:duration=0.5:offset=7.0[x2]",
        "[x2][v3]xfade=transition=fade:duration=0.5:offset=10.5[x3]",
        "[x3][v4]xfade=transition=fade:duration=0.5:offset=14.0[v]",
        "[5:a]atrim=0:18,asetpts=PTS-STARTPTS,volume=0.75,afade=t=in:st=0:d=0.4,afade=t=out:st=17:d=1[a]",
    ]
    command += ["-filter_complex", ";".join(filters), "-map", "[v]", "-map", "[a]", "-t", "18", "-c:v", "libx264", "-preset", "veryfast", "-crf", "23", "-pix_fmt", "yuv420p", "-c:a", "aac", "-b:a", "160k", "-movflags", "+faststart", str(OUT / "short_teaser.mp4")]
    subprocess.run(command, check=True)


if __name__ == "__main__":
    generate()
