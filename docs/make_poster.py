"""Poster / preview.png : moitié H.U.N.K Profession (common/poster.png du mod 3678932953),
moitié Guns of Marz (première image du GIF d'aperçu Workshop de 3722134990, 512 px, à
télécharger dans le même dossier sous le nom gom_ws.img via GetPublishedFileDetails.preview_url).
Sortie : poster_512.png (preview.png et 42.21/poster.png) et preview_256.png."""
from PIL import Image, ImageDraw, ImageFont
import os

S = os.path.dirname(os.path.abspath(__file__))
W = "D:/SteamLibrary/steamapps/workshop/content/108600"
N = 512

hunk = Image.open(f"{W}/3678932953/mods/HUNK/common/poster.png").convert("RGB")
gom_gif = Image.open(os.path.join(S, "gom_ws.img"))
gom_gif.seek(0)
gom = gom_gif.convert("RGB")

# HUNK: 2015x2160, scale to height 512 then crop around the figure (left panel)
h = hunk.resize((round(hunk.width * N / hunk.height), N), Image.LANCZOS)
left = Image.new("RGB", (N, N))
left.paste(h, (-150, 0))

# GoM: 512x512, shift so the shooter sits in the right panel
right = Image.new("RGB", (N, N))
g = gom.resize((666, 666), Image.LANCZOS)
right.paste(g, (170, -128))

# Diagonal split
mask = Image.new("L", (N, N), 0)
md = ImageDraw.Draw(mask)
x_top, x_bot = 300, 220
md.polygon([(x_top, 0), (N, 0), (N, N), (x_bot, N)], fill=255)
img = Image.composite(right, left, mask)

# darken the top edge (hides the tail of the Guns of Marz title)
top = Image.new("RGBA", (N, 70), (0, 0, 0, 0))
td = ImageDraw.Draw(top)
for y in range(70):
    td.line([(0, y), (N, y)], fill=(8, 8, 10, int(255 * (1 - y / 70) ** 1.3)))
img.paste(top, (0, 0), top)

d = ImageDraw.Draw(img)
# stripe on the split
d.line([(x_top, 0), (x_bot, N)], fill=(20, 20, 20), width=12)
d.line([(x_top, 0), (x_bot, N)], fill=(200, 25, 25), width=6)

# bottom band
band_h = 128
band = Image.new("RGBA", (N, band_h), (0, 0, 0, 0))
bd = ImageDraw.Draw(band)
for y in range(band_h):
    a = int(235 * min(1, y / 40))
    bd.line([(0, y), (N, y)], fill=(12, 12, 14, a))
img.paste(band, (0, N - band_h), band)

d = ImageDraw.Draw(img)
impact = "C:/Windows/Fonts/impact.ttf"


def centered(text, y, size, fill, stroke=3):
    f = ImageFont.truetype(impact, size)
    w = d.textlength(text, font=f)
    d.text(((N - w) / 2, y), text, font=f, fill=fill,
           stroke_width=stroke, stroke_fill=(0, 0, 0))


centered("H.U.N.K  +  GUNS OF MARZ", N - 100, 44, (240, 240, 240))
centered("COMPATIBILITY", N - 52, 40, (215, 30, 30))

# "+" badge on the split
cx, cy, r = (x_top + x_bot) // 2, 200, 30
cx = x_top + (x_bot - x_top) * cy / N
d.ellipse([cx - r, cy - r, cx + r, cy + r], fill=(200, 25, 25), outline=(20, 20, 20), width=4)
f = ImageFont.truetype(impact, 50)
tw = d.textlength("+", font=f)
d.text((cx - tw / 2, cy - 32), "+", font=f, fill=(255, 255, 255))

img.save(os.path.join(S, "poster_512.png"), optimize=True)
img.resize((256, 256), Image.LANCZOS).save(os.path.join(S, "preview_256.png"), optimize=True)
print(os.path.getsize(os.path.join(S, "poster_512.png")))
