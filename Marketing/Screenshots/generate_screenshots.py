#!/usr/bin/env python3
"""
LifeBlocks App Store Screenshot Generator
Creates promotional screenshots for App Store listing
"""

from PIL import Image, ImageDraw, ImageFont
import os

# Dimensions for iPhone 6.7" (1290 x 2796)
WIDTH = 1290
HEIGHT = 2796

# Colors
BACKGROUND = (13, 17, 23)  # #0D1117
CARD_BG = (22, 27, 34)     # #161B22
GREEN_DARK = (14, 68, 41)  # #0E4429
GREEN_MED = (0, 109, 50)   # #006D32
GREEN_LIGHT = (38, 166, 65) # #26A641
GREEN_BRIGHT = (57, 211, 83) # #39D353
WHITE = (255, 255, 255)
GRAY = (139, 148, 158)
ORANGE = (255, 149, 0)
YELLOW = (255, 214, 10)

OUTPUT_DIR = "/Users/jamesbecker/Desktop/LifeBlocks/Marketing/Screenshots"

def get_font(size, bold=False):
    """Get system font - falls back to default if not found"""
    try:
        if bold:
            return ImageFont.truetype("/System/Library/Fonts/SFNS.ttf", size)
        return ImageFont.truetype("/System/Library/Fonts/SFNS.ttf", size)
    except:
        try:
            return ImageFont.truetype("/System/Library/Fonts/Helvetica.ttc", size)
        except:
            return ImageFont.load_default()

def draw_rounded_rect(draw, coords, radius, fill):
    """Draw a rounded rectangle"""
    x1, y1, x2, y2 = coords
    draw.rounded_rectangle(coords, radius=radius, fill=fill)

def draw_contribution_grid(draw, x, y, cell_size=28, gap=6, weeks=12):
    """Draw a mini contribution grid"""
    import random
    levels = [GREEN_DARK, GREEN_MED, GREEN_LIGHT, GREEN_BRIGHT]

    for week in range(weeks):
        for day in range(7):
            # More green towards recent days
            weight = (week / weeks) * 0.7
            if random.random() < 0.3 + weight:
                color = random.choice(levels[1:])
            else:
                color = levels[0] if random.random() > 0.5 else CARD_BG

            cx = x + week * (cell_size + gap)
            cy = y + day * (cell_size + gap)
            draw.rounded_rectangle(
                [cx, cy, cx + cell_size, cy + cell_size],
                radius=6,
                fill=color
            )

def create_screenshot_1():
    """Screenshot 1: Hero - Choose Your Path"""
    img = Image.new('RGB', (WIDTH, HEIGHT), BACKGROUND)
    draw = ImageDraw.Draw(img)

    # Title
    font_large = get_font(72, bold=True)
    font_med = get_font(48)
    font_small = get_font(36)

    # Main headline
    draw.text((WIDTH//2, 200), "Choose Your Path", fill=WHITE, font=font_large, anchor="mm")
    draw.text((WIDTH//2, 280), "Build the life you want", fill=GRAY, font=font_med, anchor="mm")

    # Path cards
    paths = [
        ("Content Creator", "video.fill", (255, 107, 107)),
        ("Entrepreneur", "lightbulb.fill", (255, 214, 10)),
        ("Software Engineer", "chevron.left.forwardslash.chevron.right", (69, 183, 209)),
        ("Fitness", "figure.run", (255, 149, 0)),
        ("Investor", "chart.line.uptrend.xyaxis", GREEN_BRIGHT),
        ("Health & Wellness", "heart.fill", (255, 105, 180)),
    ]

    card_width = 580
    card_height = 160
    start_y = 450
    gap = 30

    for i, (name, icon, color) in enumerate(paths):
        row = i // 2
        col = i % 2

        x = 60 + col * (card_width + 30)
        y = start_y + row * (card_height + gap)

        # Card background
        draw.rounded_rectangle(
            [x, y, x + card_width, y + card_height],
            radius=24,
            fill=CARD_BG
        )

        # Color accent bar on left
        draw.rounded_rectangle(
            [x, y, x + 12, y + card_height],
            radius=6,
            fill=color
        )

        # Path name
        draw.text((x + 50, y + card_height//2), name, fill=WHITE, font=font_med, anchor="lm")

    # Bottom text
    draw.text((WIDTH//2, 1600), "8 Life Paths", fill=GREEN_BRIGHT, font=font_large, anchor="mm")
    draw.text((WIDTH//2, 1700), "Curated habits for your goals", fill=GRAY, font=font_med, anchor="mm")

    # Mini grid preview at bottom
    draw_contribution_grid(draw, 200, 1900, cell_size=50, gap=12, weeks=15)

    img.save(f"{OUTPUT_DIR}/01_choose_path.png")
    print("Created: 01_choose_path.png")

def create_screenshot_2():
    """Screenshot 2: Daily Check-in"""
    img = Image.new('RGB', (WIDTH, HEIGHT), BACKGROUND)
    draw = ImageDraw.Draw(img)

    font_large = get_font(72, bold=True)
    font_med = get_font(48)
    font_small = get_font(36)

    # Title
    draw.text((WIDTH//2, 200), "30 Seconds", fill=WHITE, font=font_large, anchor="mm")
    draw.text((WIDTH//2, 290), "to track your day", fill=GRAY, font=font_med, anchor="mm")

    # Mock check-in card
    card_x = 80
    card_y = 450
    card_w = WIDTH - 160
    card_h = 1100

    draw.rounded_rectangle(
        [card_x, card_y, card_x + card_w, card_y + card_h],
        radius=40,
        fill=CARD_BG
    )

    # Habit icon (circle)
    icon_y = card_y + 200
    draw.ellipse([WIDTH//2 - 80, icon_y, WIDTH//2 + 80, icon_y + 160], fill=GREEN_BRIGHT)

    # Question
    draw.text((WIDTH//2, icon_y + 280), "Did you exercise today?", fill=WHITE, font=font_med, anchor="mm")

    # Answer buttons
    buttons = [
        ("Yes!", GREEN_BRIGHT, card_y + 600),
        ("Partially", YELLOW, card_y + 740),
        ("No", GRAY, card_y + 880),
    ]

    for label, color, by in buttons:
        draw.rounded_rectangle(
            [card_x + 60, by, card_x + card_w - 60, by + 100],
            radius=20,
            fill=BACKGROUND
        )
        draw.rounded_rectangle(
            [card_x + 60, by, card_x + card_w - 60, by + 100],
            radius=20,
            outline=color,
            width=3
        )
        draw.text((WIDTH//2, by + 50), label, fill=color, font=font_med, anchor="mm")

    # Swipe hint
    draw.text((WIDTH//2, 1700), "Swipe or tap to answer", fill=GRAY, font=font_small, anchor="mm")

    # Progress dots
    for i in range(5):
        color = GREEN_BRIGHT if i < 2 else GRAY
        draw.ellipse([WIDTH//2 - 100 + i*50, 1800, WIDTH//2 - 80 + i*50, 1820], fill=color)

    # Bottom tagline
    draw.text((WIDTH//2, 2000), "Quick. Simple. Effective.", fill=WHITE, font=font_large, anchor="mm")

    img.save(f"{OUTPUT_DIR}/02_daily_checkin.png")
    print("Created: 02_daily_checkin.png")

def create_screenshot_3():
    """Screenshot 3: Your Year Visualized"""
    img = Image.new('RGB', (WIDTH, HEIGHT), BACKGROUND)
    draw = ImageDraw.Draw(img)

    font_large = get_font(72, bold=True)
    font_med = get_font(48)

    # Title
    draw.text((WIDTH//2, 200), "Your Year", fill=WHITE, font=font_large, anchor="mm")
    draw.text((WIDTH//2, 290), "Visualized", fill=GREEN_BRIGHT, font=font_large, anchor="mm")

    # Large contribution grid
    draw_contribution_grid(draw, 80, 500, cell_size=42, gap=8, weeks=26)

    # Stats row below grid
    stats_y = 1350
    stats = [
        ("156", "Check-ins"),
        ("23", "Day Streak"),
        ("3.2", "Avg Score"),
    ]

    stat_width = (WIDTH - 120) // 3
    for i, (value, label) in enumerate(stats):
        x = 60 + i * stat_width + stat_width // 2

        # Stat card
        draw.rounded_rectangle(
            [60 + i * stat_width + 10, stats_y, 60 + (i+1) * stat_width - 10, stats_y + 200],
            radius=20,
            fill=CARD_BG
        )

        draw.text((x, stats_y + 70), value, fill=WHITE, font=font_large, anchor="mm")
        draw.text((x, stats_y + 150), label, fill=GRAY, font=font_med, anchor="mm")

    # Bottom message
    draw.text((WIDTH//2, 1750), "Watch your progress grow", fill=WHITE, font=font_med, anchor="mm")
    draw.text((WIDTH//2, 1850), "Every green square is a win", fill=GRAY, font=font_med, anchor="mm")

    # Legend
    legend_y = 2000
    legend_x = 300
    levels = [CARD_BG, GREEN_DARK, GREEN_MED, GREEN_LIGHT, GREEN_BRIGHT]
    labels = ["None", "Light", "Medium", "High", "Max"]

    draw.text((WIDTH//2, legend_y - 50), "Activity Levels", fill=GRAY, font=font_med, anchor="mm")

    for i, (color, label) in enumerate(zip(levels, labels)):
        x = legend_x + i * 150
        draw.rounded_rectangle([x, legend_y, x + 60, legend_y + 60], radius=10, fill=color)
        draw.text((x + 30, legend_y + 100), label, fill=GRAY, font=get_font(28), anchor="mm")

    img.save(f"{OUTPUT_DIR}/03_year_visualized.png")
    print("Created: 03_year_visualized.png")

def create_screenshot_4():
    """Screenshot 4: Stay Motivated"""
    img = Image.new('RGB', (WIDTH, HEIGHT), BACKGROUND)
    draw = ImageDraw.Draw(img)

    font_large = get_font(72, bold=True)
    font_med = get_font(48)
    font_small = get_font(36)
    font_quote = get_font(42)

    # Title
    draw.text((WIDTH//2, 200), "Stay Motivated", fill=WHITE, font=font_large, anchor="mm")

    # Streak card
    streak_y = 380
    draw.rounded_rectangle(
        [80, streak_y, WIDTH - 80, streak_y + 300],
        radius=30,
        fill=CARD_BG
    )

    # Flame emoji area (orange circle)
    draw.ellipse([WIDTH//2 - 60, streak_y + 40, WIDTH//2 + 60, streak_y + 160], fill=ORANGE)

    draw.text((WIDTH//2, streak_y + 200), "23 Day Streak!", fill=WHITE, font=font_large, anchor="mm")
    draw.text((WIDTH//2, streak_y + 260), "Keep it going!", fill=GRAY, font=font_med, anchor="mm")

    # Quote card
    quote_y = 780
    draw.rounded_rectangle(
        [80, quote_y, WIDTH - 80, quote_y + 350],
        radius=30,
        fill=CARD_BG
    )

    # Quote marks
    draw.text((140, quote_y + 50), '"', fill=GREEN_BRIGHT, font=get_font(100), anchor="lt")

    quote = "Every expert was once\na beginner. Keep coding."
    draw.text((WIDTH//2, quote_y + 175), quote, fill=WHITE, font=font_quote, anchor="mm", align="center")

    draw.text((WIDTH//2, quote_y + 300), "— Software Engineer Path", fill=GRAY, font=font_small, anchor="mm")

    # Level progress
    level_y = 1250
    draw.rounded_rectangle(
        [80, level_y, WIDTH - 80, level_y + 250],
        radius=30,
        fill=CARD_BG
    )

    draw.text((150, level_y + 50), "Level 4", fill=WHITE, font=font_med, anchor="lm")
    draw.text((150, level_y + 110), "Practitioner", fill=GREEN_BRIGHT, font=font_small, anchor="lm")

    # Progress bar
    bar_y = level_y + 160
    draw.rounded_rectangle([150, bar_y, WIDTH - 150, bar_y + 40], radius=20, fill=BACKGROUND)
    draw.rounded_rectangle([150, bar_y, 150 + 700, bar_y + 40], radius=20, fill=GREEN_BRIGHT)

    draw.text((WIDTH - 150, level_y + 80), "70%", fill=GREEN_BRIGHT, font=font_med, anchor="rm")

    # Milestone badges
    badge_y = 1600
    draw.text((WIDTH//2, badge_y), "Milestones", fill=WHITE, font=font_med, anchor="mm")

    milestones = ["7 Days", "14 Days", "21 Days", "30 Days"]
    badge_width = 250
    start_x = (WIDTH - (badge_width * 4 + 30 * 3)) // 2

    for i, label in enumerate(milestones):
        x = start_x + i * (badge_width + 30)
        achieved = i < 3
        color = GREEN_BRIGHT if achieved else GRAY

        draw.rounded_rectangle(
            [x, badge_y + 60, x + badge_width, badge_y + 160],
            radius=15,
            fill=CARD_BG if achieved else BACKGROUND,
            outline=color,
            width=2
        )
        draw.text((x + badge_width//2, badge_y + 110), label, fill=color, font=font_small, anchor="mm")

    # Bottom
    draw.text((WIDTH//2, 1900), "Celebrate every win", fill=WHITE, font=font_large, anchor="mm")

    img.save(f"{OUTPUT_DIR}/04_stay_motivated.png")
    print("Created: 04_stay_motivated.png")

def create_screenshot_5():
    """Screenshot 5: Widgets"""
    img = Image.new('RGB', (WIDTH, HEIGHT), BACKGROUND)
    draw = ImageDraw.Draw(img)

    font_large = get_font(72, bold=True)
    font_med = get_font(48)
    font_small = get_font(36)

    # Title
    draw.text((WIDTH//2, 200), "Home Screen", fill=WHITE, font=font_large, anchor="mm")
    draw.text((WIDTH//2, 290), "Widgets", fill=GREEN_BRIGHT, font=font_large, anchor="mm")

    # Small widget
    small_x, small_y = 100, 500
    small_size = 350
    draw.rounded_rectangle(
        [small_x, small_y, small_x + small_size, small_y + small_size],
        radius=40,
        fill=CARD_BG
    )
    draw.text((small_x + 30, small_y + 30), "LifeBlocks", fill=GRAY, font=font_small, anchor="lt")
    draw.text((small_x + small_size//2, small_y + 150), "23", fill=WHITE, font=get_font(100), anchor="mm")
    draw.text((small_x + small_size//2, small_y + 250), "Day Streak", fill=GRAY, font=font_small, anchor="mm")

    # Medium widget
    med_x, med_y = 500, 500
    med_w, med_h = 700, 350
    draw.rounded_rectangle(
        [med_x, med_y, med_x + med_w, med_y + med_h],
        radius=40,
        fill=CARD_BG
    )
    draw.text((med_x + 30, med_y + 30), "LifeBlocks", fill=GRAY, font=font_small, anchor="lt")
    # Mini grid in medium widget
    draw_contribution_grid(draw, med_x + 50, med_y + 100, cell_size=30, gap=5, weeks=8)

    # Large widget
    large_x, large_y = 100, 950
    large_w, large_h = 1090, 700
    draw.rounded_rectangle(
        [large_x, large_y, large_x + large_w, large_y + large_h],
        radius=40,
        fill=CARD_BG
    )
    draw.text((large_x + 30, large_y + 30), "LifeBlocks", fill=GRAY, font=font_small, anchor="lt")

    # Grid in large widget
    draw_contribution_grid(draw, large_x + 50, large_y + 100, cell_size=38, gap=6, weeks=14)

    # Stats in large widget
    draw.text((large_x + 100, large_y + 550), "23 day streak", fill=WHITE, font=font_med, anchor="lm")
    draw.text((large_x + 600, large_y + 550), "Score: 3", fill=GREEN_BRIGHT, font=font_med, anchor="lm")

    # Labels
    draw.text((small_x + small_size//2, small_y + small_size + 40), "Small", fill=GRAY, font=font_small, anchor="mm")
    draw.text((med_x + med_w//2, med_y + med_h + 40), "Medium", fill=GRAY, font=font_small, anchor="mm")
    draw.text((large_x + large_w//2, large_y + large_h + 40), "Large", fill=GRAY, font=font_small, anchor="mm")

    # Bottom text
    draw.text((WIDTH//2, 1900), "Your progress at a glance", fill=WHITE, font=font_med, anchor="mm")
    draw.text((WIDTH//2, 2000), "Always visible. Always motivating.", fill=GRAY, font=font_med, anchor="mm")

    img.save(f"{OUTPUT_DIR}/05_widgets.png")
    print("Created: 05_widgets.png")

def create_screenshot_6():
    """Screenshot 6: Privacy & Free"""
    img = Image.new('RGB', (WIDTH, HEIGHT), BACKGROUND)
    draw = ImageDraw.Draw(img)

    font_large = get_font(72, bold=True)
    font_med = get_font(48)
    font_small = get_font(36)

    # Title
    draw.text((WIDTH//2, 200), "Your Data.", fill=WHITE, font=font_large, anchor="mm")
    draw.text((WIDTH//2, 300), "Your Device.", fill=GREEN_BRIGHT, font=font_large, anchor="mm")

    # Privacy card
    priv_y = 480
    draw.rounded_rectangle(
        [80, priv_y, WIDTH - 80, priv_y + 400],
        radius=30,
        fill=CARD_BG
    )

    # Shield icon (green circle with checkmark suggestion)
    draw.ellipse([WIDTH//2 - 70, priv_y + 50, WIDTH//2 + 70, priv_y + 190], fill=GREEN_BRIGHT)

    privacy_points = [
        "All data stays on your device",
        "Optional iCloud sync (your account)",
        "We never see your habits",
        "No ads. No tracking. No selling.",
    ]

    for i, point in enumerate(privacy_points):
        y = priv_y + 230 + i * 50
        draw.text((WIDTH//2, y), f"✓  {point}", fill=WHITE, font=font_small, anchor="mm")

    # Free vs Premium
    compare_y = 1000
    draw.text((WIDTH//2, compare_y), "Free to Start", fill=WHITE, font=font_large, anchor="mm")

    # Free column
    free_x = 100
    col_w = 530
    draw.rounded_rectangle(
        [free_x, compare_y + 80, free_x + col_w, compare_y + 500],
        radius=20,
        fill=CARD_BG
    )
    draw.text((free_x + col_w//2, compare_y + 130), "Free", fill=WHITE, font=font_med, anchor="mm")

    free_features = ["5 habits", "Full tracking", "Basic widget", "Streak tracking"]
    for i, feat in enumerate(free_features):
        draw.text((free_x + col_w//2, compare_y + 220 + i * 70), feat, fill=GRAY, font=font_small, anchor="mm")

    # Premium column
    prem_x = 660
    draw.rounded_rectangle(
        [prem_x, compare_y + 80, prem_x + col_w, compare_y + 500],
        radius=20,
        fill=CARD_BG,
        outline=GREEN_BRIGHT,
        width=3
    )
    draw.text((prem_x + col_w//2, compare_y + 130), "Premium", fill=GREEN_BRIGHT, font=font_med, anchor="mm")

    prem_features = ["Unlimited habits", "All widgets", "Data export", "Color themes"]
    for i, feat in enumerate(prem_features):
        draw.text((prem_x + col_w//2, compare_y + 220 + i * 70), feat, fill=WHITE, font=font_small, anchor="mm")

    # CTA
    cta_y = 1650
    draw.rounded_rectangle(
        [200, cta_y, WIDTH - 200, cta_y + 120],
        radius=30,
        fill=GREEN_BRIGHT
    )
    draw.text((WIDTH//2, cta_y + 60), "Start Building Your Life", fill=BACKGROUND, font=font_med, anchor="mm")

    # Tagline
    draw.text((WIDTH//2, 1900), "LifeBlocks", fill=WHITE, font=font_large, anchor="mm")
    draw.text((WIDTH//2, 2000), "One square at a time", fill=GRAY, font=font_med, anchor="mm")

    img.save(f"{OUTPUT_DIR}/06_privacy_free.png")
    print("Created: 06_privacy_free.png")

def main():
    print("Generating App Store Screenshots...\n")

    create_screenshot_1()  # Choose Your Path
    create_screenshot_2()  # Daily Check-in
    create_screenshot_3()  # Year Visualized
    create_screenshot_4()  # Stay Motivated
    create_screenshot_5()  # Widgets
    create_screenshot_6()  # Privacy & Free

    print(f"\nAll screenshots saved to: {OUTPUT_DIR}")
    print("\nScreenshot order for App Store:")
    print("1. Choose Your Path - Hero shot")
    print("2. Daily Check-in - Core feature")
    print("3. Year Visualized - The grid")
    print("4. Stay Motivated - Streaks & quotes")
    print("5. Widgets - Home screen presence")
    print("6. Privacy & Free - Trust & CTA")

if __name__ == '__main__':
    main()
