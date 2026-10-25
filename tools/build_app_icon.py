"""Create the Windows application icon from the government budget artwork."""

from pathlib import Path

from PIL import Image


ROOT = Path(__file__).resolve().parents[1]
SOURCE = ROOT / "assets" / "budget_icons" / "budget_admin.png"
TARGET = ROOT / "assets" / "app_icon.ico"
SIZES = [(size, size) for size in (16, 32, 48, 64, 128, 256)]


def main() -> None:
    with Image.open(SOURCE) as artwork:
        if artwork.size != (256, 256):
            raise ValueError(f"Expected a 256x256 source image, got {artwork.size}")
        artwork.convert("RGBA").save(TARGET, format="ICO", sizes=SIZES)
    with Image.open(TARGET) as icon:
        actual = icon.ico.sizes()
    if actual != set(SIZES):
        raise ValueError(f"Incomplete ICO sizes: {actual}")
    print(f"Created {TARGET} with {len(actual)} sizes")


if __name__ == "__main__":
    main()
