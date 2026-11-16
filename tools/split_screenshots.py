import os
import sys
from PIL import Image

def split_panorama(image_path, target_platform="appstore"):
    """
    Split a wide panoramic banner into 2 seamless continuous screenshots.
    target_platform: 'appstore' (1290x2796 per slide) or 'playstore' (1080x2400 per slide)
    """
    if not os.path.exists(image_path):
        print(f"Error: File '{image_path}' not found.")
        return

    img = Image.open(image_path)
    w, h = img.size
    print(f"Loaded image: {image_path} (Original Size: {w}x{h})")

    if target_platform.lower() == "appstore":
        slide_w = 1290
        slide_h = 2796
    else:
        slide_w = 1080
        slide_h = 2400

    target_total_w = slide_w * 2
    target_total_h = slide_h

    # Resize image to fit total panoramic dimensions if needed
    resized = img.resize((target_total_w, target_total_h), Image.Resampling.LANCZOS)

    # Split left (Slide 1) and right (Slide 2)
    slide1 = resized.crop((0, 0, slide_w, slide_h))
    slide2 = resized.crop((slide_w, 0, target_total_w, slide_h))

    out_dir = os.path.dirname(image_path) or "."
    out1 = os.path.join(out_dir, f"{target_platform}_slide_01.png")
    out2 = os.path.join(out_dir, f"{target_platform}_slide_02.png")

    slide1.save(out1, "PNG", quality=100)
    slide2.save(out2, "PNG", quality=100)

    print(f"Success! Created 2 seamless slides:")
    print(f"  1. {out1} ({slide_w}x{slide_h} px)")
    print(f"  2. {out2} ({slide_w}x{slide_h} px)")

if __name__ == "__main__":
    if len(sys.argv) < 2:
        print("Usage: python split_screenshots.py <path_to_panorama_image> [appstore|playstore]")
    else:
        plat = sys.argv[2] if len(sys.argv) > 2 else "appstore"
        split_panorama(sys.argv[1], plat)
