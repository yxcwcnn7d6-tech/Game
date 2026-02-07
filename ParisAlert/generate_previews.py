#!/usr/bin/env python3
"""Generate iPhone-style mockup images for each ParisAlert preview state."""

from PIL import Image, ImageDraw, ImageFont
import os

# --- Constants ---
WIDTH, HEIGHT = 390, 844  # iPhone 14 logical resolution
FONT_DIR = "/usr/share/fonts/truetype/dejavu"
FONT_REGULAR = os.path.join(FONT_DIR, "DejaVuSans.ttf")
FONT_BOLD = os.path.join(FONT_DIR, "DejaVuSans-Bold.ttf")
OUTPUT_DIR = os.path.join(os.path.dirname(__file__), "Screenshots")


def font(size, bold=False):
    return ImageFont.truetype(FONT_BOLD if bold else FONT_REGULAR, size)


def draw_status_bar(draw):
    """Minimal iPhone status bar."""
    draw.text((20, 8), "9:41", fill="black", font=font(14, bold=True))
    # Battery icon (simplified rectangle)
    draw.rounded_rectangle([340, 8, 370, 22], radius=3, outline="black", width=1)
    draw.rectangle([370, 12, 373, 18], fill="black")
    draw.rectangle([342, 10, 364, 20], fill="black")


def draw_button(draw, y, text, color):
    """Draw a rounded button."""
    margin = 32
    btn_height = 50
    draw.rounded_rectangle(
        [margin, y, WIDTH - margin, y + btn_height],
        radius=14,
        fill=color,
    )
    bbox = draw.textbbox((0, 0), text, font=font(17, bold=True))
    tw = bbox[2] - bbox[0]
    draw.text(
        ((WIDTH - tw) / 2, y + (btn_height - 20) / 2),
        text,
        fill="white",
        font=font(17, bold=True),
    )


def draw_distance_card(draw, distance_text, text_color="black"):
    """Draw the distance-to-Paris card."""
    card_y = 500
    card_h = 70
    margin = 60
    draw.rounded_rectangle(
        [margin, card_y, WIDTH - margin, card_y + card_h],
        radius=12,
        fill=(245, 245, 247, 200),
    )
    label = "Avstånd till Paris centrum"
    bbox = draw.textbbox((0, 0), label, font=font(11))
    lw = bbox[2] - bbox[0]
    draw.text(
        ((WIDTH - lw) / 2, card_y + 12),
        label,
        fill=(140, 140, 145),
        font=font(11),
    )
    bbox2 = draw.textbbox((0, 0), distance_text, font=font(22, bold=True))
    dw = bbox2[2] - bbox2[0]
    draw.text(
        ((WIDTH - dw) / 2, card_y + 34),
        distance_text,
        fill=text_color,
        font=font(22, bold=True),
    )


def create_gradient(colors_top, colors_bottom):
    """Create a vertical gradient background."""
    img = Image.new("RGBA", (WIDTH, HEIGHT))
    for y in range(HEIGHT):
        t = y / HEIGHT
        r = int(colors_top[0] * (1 - t) + colors_bottom[0] * t)
        g = int(colors_top[1] * (1 - t) + colors_bottom[1] * t)
        b = int(colors_top[2] * (1 - t) + colors_bottom[2] * t)
        for x in range(WIDTH):
            img.putpixel((x, y), (r, g, b, 255))
    return img


def text_centered(draw, y, text, f, fill):
    bbox = draw.textbbox((0, 0), text, font=f)
    tw = bbox[2] - bbox[0]
    draw.text(((WIDTH - tw) / 2, y), text, fill=fill, font=f)


# ---------------------------------------------------------------------------
# Preview 1: In Paris
# ---------------------------------------------------------------------------
def preview_in_paris():
    img = create_gradient((50, 80, 200), (200, 50, 50))  # Blue -> Red (tricolore)
    # White band in middle
    draw = ImageDraw.Draw(img)
    for y in range(HEIGHT // 3, 2 * HEIGHT // 3):
        t = abs(y - HEIGHT // 2) / (HEIGHT // 6)
        alpha = max(0, min(255, int(255 * (1 - t))))
        for x in range(WIDTH):
            orig = img.getpixel((x, y))
            r = int(orig[0] * (1 - alpha / 255) + 255 * (alpha / 255))
            g = int(orig[1] * (1 - alpha / 255) + 255 * (alpha / 255))
            b = int(orig[2] * (1 - alpha / 255) + 255 * (alpha / 255))
            img.putpixel((x, y), (r, g, b, 255))

    draw = ImageDraw.Draw(img)

    # Eiffel Tower emoji approximation
    text_centered(draw, 200, "🗼", font(80), "white")

    text_centered(draw, 340, "Du är i Paris!", font(32, bold=True), "white")
    text_centered(
        draw, 390, "Bienvenue! Appen övervakar din plats.", font(15), (255, 255, 255, 230)
    )

    draw_distance_card(draw, "750 m", text_color="white")

    draw_button(draw, 700, "Stoppa övervakning", (220, 50, 50))

    img.convert("RGB").save(os.path.join(OUTPUT_DIR, "01_in_paris.png"))
    print("  01_in_paris.png")


# ---------------------------------------------------------------------------
# Preview 2: Outside Paris (Stockholm)
# ---------------------------------------------------------------------------
def preview_outside_paris():
    img = Image.new("RGB", (WIDTH, HEIGHT), (242, 242, 247))
    draw = ImageDraw.Draw(img)

    draw_status_bar(draw)

    text_centered(draw, 200, "🌍", font(80), "black")

    text_centered(draw, 340, "Du är inte i Paris", font(32, bold=True), (0, 0, 0))
    text_centered(
        draw,
        390,
        "Appen meddelar dig när du\nanländer till Paris.",
        font(15),
        (140, 140, 145),
    )

    draw_distance_card(draw, "1 545.2 km")

    draw_button(draw, 700, "Stoppa övervakning", (220, 50, 50))

    img.save(os.path.join(OUTPUT_DIR, "02_outside_stockholm.png"))
    print("  02_outside_stockholm.png")


# ---------------------------------------------------------------------------
# Preview 3: Permission not determined
# ---------------------------------------------------------------------------
def preview_not_determined():
    img = Image.new("RGB", (WIDTH, HEIGHT), (242, 242, 247))
    draw = ImageDraw.Draw(img)

    draw_status_bar(draw)

    text_centered(draw, 240, "🌍", font(80), "black")

    text_centered(draw, 380, "Du är inte i Paris", font(32, bold=True), (0, 0, 0))
    text_centered(
        draw, 430, "Tillåt platstjänster för att börja.", font(15), (140, 140, 145)
    )

    draw_button(draw, 700, "Aktivera platstjänster", (0, 122, 255))

    img.save(os.path.join(OUTPUT_DIR, "03_not_determined.png"))
    print("  03_not_determined.png")


# ---------------------------------------------------------------------------
# Preview 4: Permission denied
# ---------------------------------------------------------------------------
def preview_denied():
    img = Image.new("RGB", (WIDTH, HEIGHT), (242, 242, 247))
    draw = ImageDraw.Draw(img)

    draw_status_bar(draw)

    text_centered(draw, 240, "🌍", font(80), "black")

    text_centered(draw, 380, "Du är inte i Paris", font(32, bold=True), (0, 0, 0))

    # Multi-line subtitle
    line1 = "Platstjänster är avstängda."
    line2 = "Aktivera dem i Inställningar."
    text_centered(draw, 430, line1, font(15), (140, 140, 145))
    text_centered(draw, 452, line2, font(15), (140, 140, 145))

    draw_button(draw, 700, "Öppna Inställningar", (0, 122, 255))

    img.save(os.path.join(OUTPUT_DIR, "04_denied.png"))
    print("  04_denied.png")


# ---------------------------------------------------------------------------
# Preview 5: Monitoring inactive
# ---------------------------------------------------------------------------
def preview_inactive():
    img = Image.new("RGB", (WIDTH, HEIGHT), (242, 242, 247))
    draw = ImageDraw.Draw(img)

    draw_status_bar(draw)

    text_centered(draw, 240, "🌍", font(80), "black")

    text_centered(draw, 380, "Du är inte i Paris", font(32, bold=True), (0, 0, 0))
    text_centered(
        draw, 430, "Tryck på knappen för att starta.", font(15), (140, 140, 145)
    )

    draw_button(draw, 700, "Börja övervaka", (0, 122, 255))

    img.save(os.path.join(OUTPUT_DIR, "05_inactive.png"))
    print("  05_inactive.png")


# ---------------------------------------------------------------------------
if __name__ == "__main__":
    os.makedirs(OUTPUT_DIR, exist_ok=True)
    print("Generating previews...")
    preview_in_paris()
    preview_outside_paris()
    preview_not_determined()
    preview_denied()
    preview_inactive()
    print("Done!")
