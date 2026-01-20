#!/usr/bin/env python3
"""
LifeGrid Logo Variations Generator
Creates logos for different use cases
"""

from PIL import Image, ImageDraw, ImageFont
import os

# Colors
BACKGROUND = (13, 17, 23)
TRANSPARENT = (0, 0, 0, 0)
GREEN_DARK = (14, 68, 41)
GREEN_MED = (0, 109, 50)
GREEN_LIGHT = (38, 166, 65)
GREEN_BRIGHT = (57, 211, 83)
WHITE = (255, 255, 255)

OUTPUT_DIR = "/Users/jamesbecker/Desktop/LifeGrid/Marketing/Logos"
os.makedirs(OUTPUT_DIR, exist_ok=True)

def get_font(size):
    try:
        return ImageFont.truetype("/System/Library/Fonts/Helvetica.ttc", size)
    except:
        return ImageFont.load_default()

def draw_grid_icon(draw, x, y, cell_size, gap):
    """Draw the 3x3 grid icon"""
    levels = [GREEN_DARK, GREEN_MED, GREEN_LIGHT, GREEN_BRIGHT]
    pattern = [
        [0, 1, 2],
        [1, 2, 3],
        [2, 3, 3]
    ]

    for row in range(3):
        for col in range(3):
            color = levels[pattern[row][col]]
            cx = x + col * (cell_size + gap)
            cy = y + row * (cell_size + gap)
            draw.rounded_rectangle(
                [cx, cy, cx + cell_size, cy + cell_size],
                radius=cell_size * 0.2,
                fill=color
            )

def create_logo_horizontal_dark():
    """Horizontal logo on dark background"""
    width, height = 800, 200
    img = Image.new('RGB', (width, height), BACKGROUND)
    draw = ImageDraw.Draw(img)

    # Grid icon
    draw_grid_icon(draw, 40, 35, 40, 8)

    # Text
    font = get_font(72)
    draw.text((200, 100), "LifeGrid", fill=WHITE, font=font, anchor="lm")

    img.save(f"{OUTPUT_DIR}/logo_horizontal_dark.png")
    print("Created: logo_horizontal_dark.png")

def create_logo_horizontal_light():
    """Horizontal logo on light/white background"""
    width, height = 800, 200
    img = Image.new('RGB', (width, height), (255, 255, 255))
    draw = ImageDraw.Draw(img)

    # Grid icon
    draw_grid_icon(draw, 40, 35, 40, 8)

    # Text (dark)
    font = get_font(72)
    draw.text((200, 100), "LifeGrid", fill=BACKGROUND, font=font, anchor="lm")

    img.save(f"{OUTPUT_DIR}/logo_horizontal_light.png")
    print("Created: logo_horizontal_light.png")

def create_logo_stacked_dark():
    """Stacked logo (icon above text) on dark"""
    width, height = 400, 350
    img = Image.new('RGB', (width, height), BACKGROUND)
    draw = ImageDraw.Draw(img)

    # Grid icon centered
    icon_size = 50
    icon_gap = 10
    total_icon = 3 * icon_size + 2 * icon_gap
    start_x = (width - total_icon) // 2
    draw_grid_icon(draw, start_x, 40, icon_size, icon_gap)

    # Text centered below
    font = get_font(56)
    draw.text((width // 2, 280), "LifeGrid", fill=WHITE, font=font, anchor="mm")

    img.save(f"{OUTPUT_DIR}/logo_stacked_dark.png")
    print("Created: logo_stacked_dark.png")

def create_logo_stacked_light():
    """Stacked logo on light background"""
    width, height = 400, 350
    img = Image.new('RGB', (width, height), (255, 255, 255))
    draw = ImageDraw.Draw(img)

    # Grid icon centered
    icon_size = 50
    icon_gap = 10
    total_icon = 3 * icon_size + 2 * icon_gap
    start_x = (width - total_icon) // 2
    draw_grid_icon(draw, start_x, 40, icon_size, icon_gap)

    # Text centered below
    font = get_font(56)
    draw.text((width // 2, 280), "LifeGrid", fill=BACKGROUND, font=font, anchor="mm")

    img.save(f"{OUTPUT_DIR}/logo_stacked_light.png")
    print("Created: logo_stacked_light.png")

def create_icon_only():
    """Just the grid icon, various sizes"""
    sizes = [512, 256, 128, 64, 32]

    for size in sizes:
        img = Image.new('RGBA', (size, size), TRANSPARENT)
        draw = ImageDraw.Draw(img)

        padding = size * 0.1
        available = size - (padding * 2)
        cell_size = available / 3.5
        gap = cell_size * 0.2

        draw_grid_icon(draw, int(padding), int(padding), int(cell_size), int(gap))

        img.save(f"{OUTPUT_DIR}/icon_only_{size}x{size}.png")
        print(f"Created: icon_only_{size}x{size}.png")

def create_favicon():
    """Favicon for website"""
    sizes = [32, 16]

    for size in sizes:
        img = Image.new('RGB', (size, size), BACKGROUND)
        draw = ImageDraw.Draw(img)

        # Simplified 2x2 grid for small sizes
        cell = size // 3
        gap = 1
        colors = [GREEN_MED, GREEN_LIGHT, GREEN_LIGHT, GREEN_BRIGHT]

        positions = [(0, 0), (1, 0), (0, 1), (1, 1)]
        for i, (col, row) in enumerate(positions):
            x = 2 + col * (cell + gap)
            y = 2 + row * (cell + gap)
            draw.rectangle([x, y, x + cell, y + cell], fill=colors[i])

        img.save(f"{OUTPUT_DIR}/favicon_{size}x{size}.png")
        print(f"Created: favicon_{size}x{size}.png")

def create_logo_with_tagline():
    """Logo with tagline for marketing"""
    width, height = 800, 280
    img = Image.new('RGB', (width, height), BACKGROUND)
    draw = ImageDraw.Draw(img)

    # Grid icon
    draw_grid_icon(draw, 40, 50, 45, 10)

    # App name
    font_large = get_font(64)
    font_small = get_font(28)

    draw.text((220, 90), "LifeGrid", fill=WHITE, font=font_large, anchor="lm")
    draw.text((220, 160), "Build your life, one square at a time", fill=(139, 148, 158), font=font_small, anchor="lm")

    img.save(f"{OUTPUT_DIR}/logo_with_tagline.png")
    print("Created: logo_with_tagline.png")

def create_wordmark():
    """Text-only wordmark"""
    width, height = 500, 120

    # Dark version
    img = Image.new('RGB', (width, height), BACKGROUND)
    draw = ImageDraw.Draw(img)
    font = get_font(72)

    # "Life" in white, "Grid" in green
    draw.text((50, 60), "Life", fill=WHITE, font=font, anchor="lm")
    draw.text((210, 60), "Grid", fill=GREEN_BRIGHT, font=font, anchor="lm")

    img.save(f"{OUTPUT_DIR}/wordmark_dark.png")
    print("Created: wordmark_dark.png")

    # Light version
    img = Image.new('RGB', (width, height), (255, 255, 255))
    draw = ImageDraw.Draw(img)

    draw.text((50, 60), "Life", fill=BACKGROUND, font=font, anchor="lm")
    draw.text((210, 60), "Grid", fill=GREEN_BRIGHT, font=font, anchor="lm")

    img.save(f"{OUTPUT_DIR}/wordmark_light.png")
    print("Created: wordmark_light.png")

def main():
    print("Generating Logo Variations...\n")

    create_logo_horizontal_dark()
    create_logo_horizontal_light()
    create_logo_stacked_dark()
    create_logo_stacked_light()
    create_icon_only()
    create_favicon()
    create_logo_with_tagline()
    create_wordmark()

    print(f"\nAll logos saved to: {OUTPUT_DIR}")
    print("\nLogo usage guide:")
    print("- App Store / social: logo_horizontal_dark.png")
    print("- Light backgrounds: logo_horizontal_light.png")
    print("- Square spaces: logo_stacked_*.png")
    print("- Website favicon: favicon_*.png")
    print("- Marketing: logo_with_tagline.png")
    print("- Minimal: wordmark_*.png")

if __name__ == '__main__':
    main()
