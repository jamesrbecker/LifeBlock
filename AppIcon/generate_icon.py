#!/usr/bin/env python3
"""
LifeGrid App Icon Generator
Generates a 1024x1024 app icon with a 3x3 gradient grid
"""

from PIL import Image, ImageDraw

def hex_to_rgb(hex_color):
    hex_color = hex_color.lstrip('#')
    return tuple(int(hex_color[i:i+2], 16) for i in (0, 2, 4))

# Colors - GitHub contribution style
BACKGROUND = hex_to_rgb("#0D1117")
GRID_COLORS = [
    hex_to_rgb("#0E4429"),  # Level 1 - darkest
    hex_to_rgb("#006D32"),  # Level 2
    hex_to_rgb("#26A641"),  # Level 3
    hex_to_rgb("#39D353"),  # Level 4 - brightest
]

def create_icon(size=1024):
    # Create image with dark background
    img = Image.new('RGB', (size, size), BACKGROUND)
    draw = ImageDraw.Draw(img)

    # Grid configuration
    padding = size * 0.15  # 15% padding on each side
    grid_size = size - (padding * 2)
    cell_size = grid_size / 3
    gap = cell_size * 0.12  # 12% gap between cells
    actual_cell = cell_size - gap
    corner_radius = actual_cell * 0.2  # Rounded corners

    # Grid pattern - diagonal gradient (bottom-left to top-right gets brighter)
    # Grid positions: (row, col) where 0,0 is top-left
    grid_levels = [
        [1, 2, 3],  # Top row
        [2, 3, 4],  # Middle row
        [3, 4, 4],  # Bottom row
    ]

    for row in range(3):
        for col in range(3):
            level = grid_levels[row][col]
            color = GRID_COLORS[level - 1]

            x = padding + (col * cell_size) + (gap / 2)
            y = padding + (row * cell_size) + (gap / 2)

            # Draw rounded rectangle
            draw.rounded_rectangle(
                [x, y, x + actual_cell, y + actual_cell],
                radius=corner_radius,
                fill=color
            )

    return img

def main():
    # Generate 1024x1024 icon
    icon = create_icon(1024)

    # Save main icon
    icon.save('/Users/jamesbecker/Desktop/LifeGrid/AppIcon/AppIcon-1024.png', 'PNG')
    print("Created: AppIcon-1024.png")

    # Generate all required sizes for iOS
    sizes = [
        (180, 'AppIcon-180.png'),   # iPhone @3x
        (120, 'AppIcon-120.png'),   # iPhone @2x
        (167, 'AppIcon-167.png'),   # iPad Pro
        (152, 'AppIcon-152.png'),   # iPad
        (76, 'AppIcon-76.png'),     # iPad @1x
        (40, 'AppIcon-40.png'),     # Spotlight @2x
        (60, 'AppIcon-60.png'),     # Spotlight @3x
        (58, 'AppIcon-58.png'),     # Settings @2x
        (87, 'AppIcon-87.png'),     # Settings @3x
        (80, 'AppIcon-80.png'),     # Spotlight iPad
        (29, 'AppIcon-29.png'),     # Settings @1x
    ]

    for size, filename in sizes:
        resized = icon.resize((size, size), Image.Resampling.LANCZOS)
        resized.save(f'/Users/jamesbecker/Desktop/LifeGrid/AppIcon/{filename}', 'PNG')
        print(f"Created: {filename}")

    print("\nAll icons generated successfully!")
    print("\nTo use in Xcode:")
    print("1. Open Assets.xcassets")
    print("2. Select AppIcon")
    print("3. Drag AppIcon-1024.png to the 1024x1024 slot")
    print("   (Xcode will auto-generate other sizes, or use the individual files)")

if __name__ == '__main__':
    main()
