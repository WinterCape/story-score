#!/usr/bin/env python3
"""Generate StoryScore app icons."""
import os
from PIL import Image, ImageDraw

script_dir = os.path.dirname(os.path.abspath(__file__))
project_root = os.path.dirname(script_dir)
icon_dir = os.path.join(project_root, "assets", "icon")
os.makedirs(icon_dir, exist_ok=True)

# Main app icon (with dark purple background)
img = Image.new("RGBA", (1024, 1024), (26, 16, 37, 255))
draw = ImageDraw.Draw(img)
# Gold outer ring
draw.ellipse([212, 212, 812, 812], fill=(212, 167, 66, 255))
# Dark inner circle
draw.ellipse([282, 282, 742, 742], fill=(26, 16, 37, 255))
# Gold diamond in center
draw.polygon([(512, 302), (622, 512), (512, 722), (402, 512)], fill=(212, 167, 66, 255))
# Small rays / scoring marks at cardinal points
for cx, cy in [(512, 222), (512, 802), (222, 512), (802, 512)]:
    draw.ellipse([cx - 20, cy - 20, cx + 20, cy + 20], fill=(212, 167, 66, 255))

img.save(os.path.join(icon_dir, "app_icon.png"))
print("Created assets/icon/app_icon.png")

# Foreground only (transparent background) for Android adaptive icons
fg = Image.new("RGBA", (1024, 1024), (0, 0, 0, 0))
dfg = ImageDraw.Draw(fg)
dfg.ellipse([212, 212, 812, 812], fill=(212, 167, 66, 255))
dfg.ellipse([282, 282, 742, 742], fill=(26, 16, 37, 255))
dfg.polygon([(512, 302), (622, 512), (512, 722), (402, 512)], fill=(212, 167, 66, 255))
for cx, cy in [(512, 222), (512, 802), (222, 512), (802, 512)]:
    dfg.ellipse([cx - 20, cy - 20, cx + 20, cy + 20], fill=(212, 167, 66, 255))

fg.save(os.path.join(icon_dir, "app_icon_foreground.png"))
print("Created assets/icon/app_icon_foreground.png")
