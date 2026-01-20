#!/usr/bin/env python3
"""
LifeBlocks Social Media Banner Generator
Creates banners for Twitter, Instagram, and promotional use
"""

from PIL import Image, ImageDraw, ImageFont
import os

# Colors
BACKGROUND = (13, 17, 23)
CARD_BG = (22, 27, 34)
GREEN_DARK = (14, 68, 41)
GREEN_MED = (0, 109, 50)
GREEN_LIGHT = (38, 166, 65)
GREEN_BRIGHT = (57, 211, 83)
WHITE = (255, 255, 255)
GRAY = (139, 148, 158)

OUTPUT_DIR = "/Users/jamesbecker/Desktop/LifeBlocks/Marketing/Banners"
os.makedirs(OUTPUT_DIR, exist_ok=True)

def get_font(size):
    try:
        return ImageFont.truetype("/System/Library/Fonts/Helvetica.ttc", size)
    except:
        return ImageFont.load_default()

def draw_mini_grid(draw, x, y, cell_size=20, gap=4, cols=15, rows=5):
    """Draw a small contribution grid"""
    import random
    levels = [CARD_BG, GREEN_DARK, GREEN_MED, GREEN_LIGHT, GREEN_BRIGHT]

    for row in range(rows):
        for col in range(cols):
            # More green towards right side
            weight = col / cols
            if random.random() < 0.2 + (weight * 0.6):
                color = random.choice(levels[1:])
            else:
                color = levels[0]

            cx = x + col * (cell_size + gap)
            cy = y + row * (cell_size + gap)
            draw.rounded_rectangle(
                [cx, cy, cx + cell_size, cy + cell_size],
                radius=4,
                fill=color
            )

def create_twitter_header():
    """Twitter header: 1500 x 500"""
    width, height = 1500, 500
    img = Image.new('RGB', (width, height), BACKGROUND)
    draw = ImageDraw.Draw(img)

    font_large = get_font(72)
    font_med = get_font(36)

    # Grid on left side
    draw_mini_grid(draw, 50, 100, cell_size=28, gap=6, cols=12, rows=10)

    # Text on right
    draw.text((800, 150), "LifeBlocks", fill=WHITE, font=font_large, anchor="lm")
    draw.text((800, 230), "Build your life, one square at a time", fill=GRAY, font=font_med, anchor="lm")

    # Tagline
    draw.text((800, 320), "Habit Tracker  •  Life Paths  •  Visual Progress", fill=GREEN_BRIGHT, font=get_font(28), anchor="lm")

    img.save(f"{OUTPUT_DIR}/twitter_header_1500x500.png")
    print("Created: twitter_header_1500x500.png")

def create_instagram_square():
    """Instagram post: 1080 x 1080"""
    width, height = 1080, 1080
    img = Image.new('RGB', (width, height), BACKGROUND)
    draw = ImageDraw.Draw(img)

    font_large = get_font(80)
    font_med = get_font(40)

    # Title
    draw.text((width//2, 120), "LifeBlocks", fill=WHITE, font=font_large, anchor="mm")
    draw.text((width//2, 200), "Build your life, one square at a time", fill=GRAY, font=font_med, anchor="mm")

    # Large grid in center
    draw_mini_grid(draw, 140, 300, cell_size=45, gap=10, cols=15, rows=7)

    # Features at bottom
    features = ["8 Life Paths", "30-Second Check-in", "Visual Progress"]
    for i, feat in enumerate(features):
        x = 180 + i * 280
        draw.text((x, 900), feat, fill=GREEN_BRIGHT, font=get_font(32), anchor="mm")

    # CTA
    draw.text((width//2, 1000), "Free on the App Store", fill=WHITE, font=font_med, anchor="mm")

    img.save(f"{OUTPUT_DIR}/instagram_square_1080x1080.png")
    print("Created: instagram_square_1080x1080.png")

def create_feature_graphic():
    """Google Play / Promotional: 1024 x 500"""
    width, height = 1024, 500
    img = Image.new('RGB', (width, height), BACKGROUND)
    draw = ImageDraw.Draw(img)

    font_large = get_font(64)
    font_med = get_font(32)

    # App icon representation (3x3 grid)
    icon_x, icon_y = 80, 150
    icon_size = 50
    icon_gap = 10
    levels = [GREEN_DARK, GREEN_MED, GREEN_LIGHT, GREEN_BRIGHT]
    pattern = [
        [0, 1, 2],
        [1, 2, 3],
        [2, 3, 3]
    ]

    for row in range(3):
        for col in range(3):
            color = levels[pattern[row][col]]
            x = icon_x + col * (icon_size + icon_gap)
            y = icon_y + row * (icon_size + icon_gap)
            draw.rounded_rectangle([x, y, x + icon_size, y + icon_size], radius=10, fill=color)

    # Text
    draw.text((350, 180), "LifeBlocks", fill=WHITE, font=font_large, anchor="lm")
    draw.text((350, 260), "Build your life, one square at a time", fill=GRAY, font=font_med, anchor="lm")

    # Mini feature grid on right
    draw_mini_grid(draw, 700, 150, cell_size=24, gap=5, cols=10, rows=7)

    # Bottom tagline
    draw.text((width//2, 450), "Free Habit Tracker  •  Visual Progress  •  8 Life Paths", fill=GREEN_BRIGHT, font=get_font(24), anchor="mm")

    img.save(f"{OUTPUT_DIR}/feature_graphic_1024x500.png")
    print("Created: feature_graphic_1024x500.png")

def create_og_image():
    """Open Graph image for link previews: 1200 x 630"""
    width, height = 1200, 630
    img = Image.new('RGB', (width, height), BACKGROUND)
    draw = ImageDraw.Draw(img)

    font_large = get_font(72)
    font_med = get_font(36)

    # Grid background (subtle)
    draw_mini_grid(draw, 50, 80, cell_size=32, gap=8, cols=8, rows=6)

    # Main content
    draw.text((600, 200), "LifeBlocks", fill=WHITE, font=font_large, anchor="lm")
    draw.text((600, 290), "Build your life,", fill=GRAY, font=font_med, anchor="lm")
    draw.text((600, 340), "one square at a time", fill=GRAY, font=font_med, anchor="lm")

    # Features
    draw.text((600, 450), "✓ Choose your path", fill=GREEN_BRIGHT, font=get_font(28), anchor="lm")
    draw.text((600, 500), "✓ Track in 30 seconds", fill=GREEN_BRIGHT, font=get_font(28), anchor="lm")
    draw.text((600, 550), "✓ See your progress grow", fill=GREEN_BRIGHT, font=get_font(28), anchor="lm")

    img.save(f"{OUTPUT_DIR}/og_image_1200x630.png")
    print("Created: og_image_1200x630.png")

def create_app_store_preview():
    """App Store preview banner: 1920 x 1080"""
    width, height = 1920, 1080
    img = Image.new('RGB', (width, height), BACKGROUND)
    draw = ImageDraw.Draw(img)

    font_large = get_font(96)
    font_med = get_font(48)
    font_small = get_font(32)

    # Large grid on left
    draw_mini_grid(draw, 100, 200, cell_size=40, gap=8, cols=12, rows=10)

    # Text content on right
    text_x = 750
    draw.text((text_x, 250), "LifeBlocks", fill=WHITE, font=font_large, anchor="lm")
    draw.text((text_x, 370), "Build your life,", fill=WHITE, font=font_med, anchor="lm")
    draw.text((text_x, 430), "one square at a time", fill=GREEN_BRIGHT, font=font_med, anchor="lm")

    # Feature list
    features = [
        "Choose from 8 life paths",
        "Track daily habits in 30 seconds",
        "Visualize your entire year",
        "Stay motivated with streaks",
        "Home screen widgets"
    ]

    for i, feat in enumerate(features):
        y = 550 + i * 60
        draw.text((text_x, y), f"✓  {feat}", fill=WHITE, font=font_small, anchor="lm")

    # CTA
    draw.rounded_rectangle([text_x, 900, text_x + 400, 980], radius=20, fill=GREEN_BRIGHT)
    draw.text((text_x + 200, 940), "Download Free", fill=BACKGROUND, font=font_small, anchor="mm")

    img.save(f"{OUTPUT_DIR}/app_store_preview_1920x1080.png")
    print("Created: app_store_preview_1920x1080.png")

def main():
    print("Generating Social Media Banners...\n")

    create_twitter_header()
    create_instagram_square()
    create_feature_graphic()
    create_og_image()
    create_app_store_preview()

    print(f"\nAll banners saved to: {OUTPUT_DIR}")

if __name__ == '__main__':
    main()
