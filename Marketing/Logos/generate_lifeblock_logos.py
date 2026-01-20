#!/usr/bin/env python3
"""
LifeBlock Logo Generator
"""

from PIL import Image, ImageDraw, ImageFont
import os

BACKGROUND = (13, 17, 23)
GREEN_DARK = (14, 68, 41)
GREEN_MED = (0, 109, 50)
GREEN_LIGHT = (38, 166, 65)
GREEN_BRIGHT = (57, 211, 83)
WHITE = (255, 255, 255)
GRAY = (139, 148, 158)

OUTPUT_DIR = "/Users/jamesbecker/Desktop/LifeBlock/Marketing/Logos"
os.makedirs(OUTPUT_DIR, exist_ok=True)

def get_font(size):
    try:
        return ImageFont.truetype("/System/Library/Fonts/Helvetica.ttc", size)
    except:
        return ImageFont.load_default()

def draw_grid_icon(draw, x, y, cell_size, gap):
    levels = [GREEN_DARK, GREEN_MED, GREEN_LIGHT, GREEN_BRIGHT]
    pattern = [[0, 1, 2], [1, 2, 3], [2, 3, 3]]
    for row in range(3):
        for col in range(3):
            color = levels[pattern[row][col]]
            cx = x + col * (cell_size + gap)
            cy = y + row * (cell_size + gap)
            draw.rounded_rectangle([cx, cy, cx + cell_size, cy + cell_size], radius=cell_size * 0.2, fill=color)

def create_logo_horizontal_dark():
    width, height = 800, 200
    img = Image.new('RGB', (width, height), BACKGROUND)
    draw = ImageDraw.Draw(img)
    draw_grid_icon(draw, 40, 35, 40, 8)
    font = get_font(72)
    draw.text((200, 100), "LifeBlock", fill=WHITE, font=font, anchor="lm")
    img.save(f"{OUTPUT_DIR}/lifeblock_logo_horizontal_dark.png")
    print("Created: lifeblock_logo_horizontal_dark.png")

def create_logo_horizontal_light():
    width, height = 800, 200
    img = Image.new('RGB', (width, height), (255, 255, 255))
    draw = ImageDraw.Draw(img)
    draw_grid_icon(draw, 40, 35, 40, 8)
    font = get_font(72)
    draw.text((200, 100), "LifeBlock", fill=BACKGROUND, font=font, anchor="lm")
    img.save(f"{OUTPUT_DIR}/lifeblock_logo_horizontal_light.png")
    print("Created: lifeblock_logo_horizontal_light.png")

def create_logo_with_tagline():
    width, height = 900, 280
    img = Image.new('RGB', (width, height), BACKGROUND)
    draw = ImageDraw.Draw(img)
    draw_grid_icon(draw, 40, 50, 45, 10)
    font_large = get_font(64)
    font_small = get_font(28)
    draw.text((220, 90), "LifeBlock", fill=WHITE, font=font_large, anchor="lm")
    draw.text((220, 160), "Build your life, block by block", fill=GRAY, font=font_small, anchor="lm")
    img.save(f"{OUTPUT_DIR}/lifeblock_logo_with_tagline.png")
    print("Created: lifeblock_logo_with_tagline.png")

def create_wordmark():
    width, height = 500, 120
    img = Image.new('RGB', (width, height), BACKGROUND)
    draw = ImageDraw.Draw(img)
    font = get_font(72)
    draw.text((50, 60), "Life", fill=WHITE, font=font, anchor="lm")
    draw.text((205, 60), "Block", fill=GREEN_BRIGHT, font=font, anchor="lm")
    img.save(f"{OUTPUT_DIR}/lifeblock_wordmark_dark.png")
    print("Created: lifeblock_wordmark_dark.png")

    img = Image.new('RGB', (width, height), (255, 255, 255))
    draw = ImageDraw.Draw(img)
    draw.text((50, 60), "Life", fill=BACKGROUND, font=font, anchor="lm")
    draw.text((205, 60), "Block", fill=GREEN_BRIGHT, font=font, anchor="lm")
    img.save(f"{OUTPUT_DIR}/lifeblock_wordmark_light.png")
    print("Created: lifeblock_wordmark_light.png")

def create_stacked():
    width, height = 400, 350
    img = Image.new('RGB', (width, height), BACKGROUND)
    draw = ImageDraw.Draw(img)
    icon_size, icon_gap = 50, 10
    total_icon = 3 * icon_size + 2 * icon_gap
    start_x = (width - total_icon) // 2
    draw_grid_icon(draw, start_x, 40, icon_size, icon_gap)
    font = get_font(56)
    draw.text((width // 2, 280), "LifeBlock", fill=WHITE, font=font, anchor="mm")
    img.save(f"{OUTPUT_DIR}/lifeblock_logo_stacked_dark.png")
    print("Created: lifeblock_logo_stacked_dark.png")

def main():
    print("Generating LifeBlock Logos...\n")
    create_logo_horizontal_dark()
    create_logo_horizontal_light()
    create_logo_with_tagline()
    create_wordmark()
    create_stacked()
    print(f"\nAll logos saved to: {OUTPUT_DIR}")

if __name__ == '__main__':
    main()
