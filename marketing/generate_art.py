"""Create editable, game-native itch.io graphics without external image assets."""

from pathlib import Path
from PIL import Image, ImageDraw, ImageFont
import random

OUT = Path(__file__).resolve().parent
FONT_DIR = Path(r"C:\Windows\Fonts")
INK = "#15191d"
PAPER = "#e8dfcb"
RED = "#9a413a"
BLUE = "#38586b"
GOLD = "#c6a460"
MUTED = "#817c70"


def font(size: int, bold: bool = False):
    return ImageFont.truetype(str(FONT_DIR / ("georgiab.ttf" if bold else "georgia.ttf")), size)


def sans(size: int, bold: bool = False):
    return ImageFont.truetype(str(FONT_DIR / ("arialbd.ttf" if bold else "arial.ttf")), size)


def tracked(draw: ImageDraw.ImageDraw, xy, value: str, face, fill, spacing: int):
    x, y = xy
    for ch in value:
        draw.text((x, y), ch, font=face, fill=fill)
        x += draw.textlength(ch, font=face) + spacing


def background(size):
    image = Image.new("RGB", size, INK)
    d = ImageDraw.Draw(image)
    w, h = size
    d.polygon([(0, 0), (int(w * .51), 0), (int(w * .39), h), (0, h)], fill="#172129")
    d.polygon([(int(w * .56), 0), (w, 0), (w, h), (int(w * .71), h)], fill="#281b1d")
    for y in range(55, h, 91):
        d.line((0, y, w, y - 40), fill="#293038", width=1)
    return image


def seal(draw, center, radius, symbol_color=INK):
    x, y = center
    draw.ellipse((x-radius, y-radius, x+radius, y+radius), outline=GOLD, width=6)
    draw.ellipse((x-radius+17, y-radius+17, x+radius-17, y+radius-17), outline="#a99160", width=2)
    # Columns and roof: an original flat emblem, matching the government's UI icon.
    draw.polygon([(x-radius*.57, y-radius*.13), (x, y-radius*.51), (x+radius*.57, y-radius*.13)], fill=symbol_color)
    draw.rectangle((x-radius*.52, y-radius*.1, x+radius*.52, y+radius*.01), fill=symbol_color)
    for offset in [-.34, -.11, .11, .34]:
        cx = x + radius * offset
        draw.rectangle((cx-radius*.06, y, cx+radius*.06, y+radius*.44), fill=symbol_color)
    draw.rectangle((x-radius*.58, y+radius*.44, x+radius*.58, y+radius*.55), fill=symbol_color)


def grain(image, rectangle, seed=42):
    rng = random.Random(seed)
    x0, y0, x1, y1 = rectangle
    pixels = image.load()
    for _ in range(int((x1-x0)*(y1-y0)*.007)):
        x = rng.randrange(x0, x1)
        y = rng.randrange(y0, y1)
        r, g, b = pixels[x, y]
        shift = rng.choice([-7, -5, -3, 3, 5])
        pixels[x, y] = tuple(max(0, min(255, c + shift)) for c in (r, g, b))


def cover():
    w, h = 1260, 1000
    im = background((w, h))
    d = ImageDraw.Draw(im)
    d.rounded_rectangle((75, 64, 1185, 936), radius=24, fill=PAPER, outline=GOLD, width=4)
    d.rectangle((75, 64, 1185, 151), fill="#ded3ba")
    tracked(d, (117, 95), "CONFIDENTIAL  /  PRESIDENTIAL OFFICE", sans(23, True), RED, 2)
    d.text((1079, 91), "01", font=sans(33, True), fill=MUTED)
    d.line((116, 195, 1144, 195), fill="#a59d8b", width=2)
    seal(d, (630, 348), 116)
    d.text((112, 505), "HEIR TO THE", font=font(100, True), fill=INK)
    d.text((112, 630), "REPUBLIC", font=font(124, True), fill=INK)
    d.line((116, 793, 1144, 793), fill="#a59d8b", width=2)
    tracked(d, (118, 816), "26 WEEKS TO THE ELECTION", sans(27, True), RED, 2)
    d.text((117, 865), "Two neighbors. One fragile country. Your decisions.", font=sans(28), fill="#3e4343")
    grain(im, (77, 153, 1183, 934))
    im.save(OUT / "itch_cover.png", optimize=True)


def page_header():
    w, h = 1600, 400
    im = background((w, h))
    d = ImageDraw.Draw(im)
    d.rectangle((47, 46, 1553, 354), outline="#8d7956", width=3)
    d.line((123, 87, 1475, 87), fill=GOLD, width=3)
    tracked(d, (130, 105), "PRESIDENTIAL FILE  /  NO. 26", sans(22, True), GOLD, 2)
    d.text((124, 147), "HEIR TO THE REPUBLIC", font=font(83, True), fill=PAPER)
    d.text((130, 281), "A POLITICAL MANAGEMENT GAME", font=sans(28, True), fill="#d3c9b1")
    seal(d, (1420, 214), 80, PAPER)
    im.save(OUT / "itch_header.png", optimize=True)


def profile_header():
    w, h = 1600, 400
    im = background((w, h))
    d = ImageDraw.Draw(im)
    d.rectangle((47, 46, 1553, 354), outline="#8d7956", width=3)
    tracked(d, (123, 92), "INDEPENDENT GAME DEVELOPMENT", sans(25, True), GOLD, 2)
    d.text((119, 130), "DIMAZAN", font=font(112, True), fill=PAPER)
    d.text((128, 287), "Stories about power, pressure and consequences.", font=sans(29), fill="#d3c9b1")
    seal(d, (1418, 210), 78, PAPER)
    im.save(OUT / "profile_header.png", optimize=True)


def social_card():
    w, h = 1080, 1920
    im = background((w, h))
    d = ImageDraw.Draw(im)
    d.rounded_rectangle((63, 115, 1017, 1649), radius=28, fill=PAPER, outline=GOLD, width=4)
    d.rectangle((63, 115, 1017, 226), fill="#ded3ba")
    tracked(d, (104, 153), "PRESIDENTIAL OFFICE  /  URGENT", sans(27, True), RED, 2)
    seal(d, (540, 479), 174)
    d.text((112, 730), "YOUR FATHER", font=font(87, True), fill=INK)
    d.text((112, 852), "IS DEAD.", font=font(108, True), fill=INK)
    d.line((115, 1006, 965, 1006), fill="#9d9584", width=3)
    d.text((111, 1057), "Elections in 26 weeks.", font=sans(48, True), fill=INK)
    d.text((111, 1148), "Two powerful neighbors.", font=sans(45), fill=INK)
    d.text((111, 1239), "A treasury on the brink.", font=sans(45), fill=INK)
    d.rounded_rectangle((118, 1412, 962, 1530), radius=13, fill=BLUE)
    d.text((182, 1441), "WHAT WILL YOU SACRIFICE?", font=sans(42, True), fill=PAPER)
    tracked(d, (94, 1710), "HEIR TO THE REPUBLIC", sans(47, True), PAPER, 1)
    d.text((249, 1800), "Free beta  •  Windows & Linux", font=sans(33), fill="#c2b49a")
    grain(im, (65, 228, 1015, 1647), 91)
    im.save(OUT / "shorts_card.png", optimize=True)


if __name__ == "__main__":
    cover()
    page_header()
    profile_header()
    social_card()
