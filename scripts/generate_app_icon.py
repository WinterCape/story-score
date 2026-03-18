#!/usr/bin/env python3
"""Generate StoryScore app icon — abstract geometric circles with aurora gradient."""

from PIL import Image, ImageDraw, ImageFilter
import math
import random

def generate_icon(size=1024):
    # Create base image with dark purple gradient
    img = Image.new('RGBA', (size, size), (0, 0, 0, 0))
    draw = ImageDraw.Draw(img)

    # Background gradient: deep indigo to dark purple
    for y in range(size):
        ratio = y / size
        r = int(26 + (45 - 26) * ratio)
        g = int(17 + (27 - 17) * ratio)
        b = int(53 + (78 - 53) * ratio)
        draw.line([(0, y), (size, y)], fill=(r, g, b, 255))

    # Add subtle radial glow in center
    glow = Image.new('RGBA', (size, size), (0, 0, 0, 0))
    glow_draw = ImageDraw.Draw(glow)
    cx, cy = size // 2, size // 2
    for r in range(size // 2, 0, -2):
        alpha = int(30 * (1 - r / (size // 2)))
        glow_draw.ellipse(
            [cx - r, cy - r, cx + r, cy + r],
            fill=(94, 196, 182, alpha)  # Aurora teal glow
        )
    img = Image.alpha_composite(img, glow)
    draw = ImageDraw.Draw(img)

    # Circle positions: 3x3 grid with center emphasized
    positions = []
    spacing = size * 0.22
    offset_x = size // 2
    offset_y = size // 2
    for row in range(-1, 2):
        for col in range(-1, 2):
            x = offset_x + col * spacing
            y = offset_y + row * spacing
            positions.append((x, y))

    # Circle colors with alpha
    colors = [
        (155, 126, 200, 80),   # soft violet
        (94, 196, 182, 80),    # aurora teal
        (212, 168, 67, 80),    # gold
        (94, 196, 182, 80),    # aurora teal
        (212, 168, 67, 200),   # gold CENTER - brighter
        (155, 126, 200, 80),   # soft violet
        (232, 120, 94, 80),    # coral
        (155, 126, 200, 80),   # soft violet
        (94, 196, 182, 80),    # aurora teal
    ]

    # Draw circles
    base_radius = size * 0.12
    circle_layer = Image.new('RGBA', (size, size), (0, 0, 0, 0))
    circle_draw = ImageDraw.Draw(circle_layer)

    for i, (x, y) in enumerate(positions):
        r = base_radius if i != 4 else base_radius * 1.15  # Center bigger
        color = colors[i]

        # Draw filled circle with transparency
        circle_draw.ellipse(
            [x - r, y - r, x + r, y + r],
            fill=color,
            outline=(255, 255, 255, 40),
            width=2
        )

    # Blur circles slightly for glass effect
    circle_layer = circle_layer.filter(ImageFilter.GaussianBlur(radius=3))
    img = Image.alpha_composite(img, circle_layer)
    draw = ImageDraw.Draw(img)

    # Add center circle glow
    center_glow = Image.new('RGBA', (size, size), (0, 0, 0, 0))
    cg_draw = ImageDraw.Draw(center_glow)
    cr = base_radius * 1.5
    for r in range(int(cr), 0, -2):
        alpha = int(60 * (1 - r / cr))
        cg_draw.ellipse(
            [cx - r, cy - r, cx + r, cy + r],
            fill=(212, 168, 67, alpha)  # Gold glow
        )
    img = Image.alpha_composite(img, center_glow)

    # Add sparkle dots
    random.seed(42)  # Deterministic
    sparkle_layer = Image.new('RGBA', (size, size), (0, 0, 0, 0))
    sparkle_draw = ImageDraw.Draw(sparkle_layer)
    for _ in range(30):
        sx = random.randint(50, size - 50)
        sy = random.randint(50, size - 50)
        sr = random.randint(1, 3)
        alpha = random.randint(100, 220)
        sparkle_draw.ellipse(
            [sx - sr, sy - sr, sx + sr, sy + sr],
            fill=(255, 255, 255, alpha)
        )
    img = Image.alpha_composite(img, sparkle_layer)

    # Flatten to RGB (no transparency for app icon)
    final = Image.new('RGB', (size, size), (26, 17, 53))
    final.paste(img, mask=img.split()[3])

    return final


if __name__ == '__main__':
    import sys
    output = sys.argv[1] if len(sys.argv) > 1 else 'assets/icon/icon.png'

    icon = generate_icon(1024)
    icon.save(output, 'PNG')
    print(f'Generated {output} (1024x1024)')

    # Also generate adaptive icon foreground for Android
    fg_output = output.replace('.png', '_foreground.png')
    fg = generate_icon(1024)
    fg.save(fg_output, 'PNG')
    print(f'Generated {fg_output} (1024x1024)')
