# Script to compress large image files in the NJUXun project
# Uses Pillow, JPEG quality 75, max dimension 1920px
import os
import sys
from pathlib import Path
from PIL import Image

# Config
JPEG_QUALITY = 75          # JPEG compression quality (1-100)
MAX_DIMENSION = 1920       # Max pixels on longest side

PROJECT_ROOT = Path(__file__).resolve().parent.parent

# Directories with images to compress
IMAGE_DIRS = [
    PROJECT_ROOT / 'backend' / 'public' / 'images',
    PROJECT_ROOT / 'frontend' / 'public' / 'images',
]

# Individual image files (maps, etc.)
SINGLE_IMAGES = [
    PROJECT_ROOT / 'frontend' / 'public' / 'gulou_map.png',
    PROJECT_ROOT / 'frontend' / 'public' / 'e6.jpg',
    PROJECT_ROOT / 'frontend' / 'src' / 'assets' / 'gulou_map.png',
    PROJECT_ROOT / 'frontend' / 'src' / 'assets' / 'gulou_map_original_7087x10630.png',
    PROJECT_ROOT / 'frontend' / 'src' / 'assets' / 'nju_bg_1.jpg',
]

COMPRESSED_DIR = PROJECT_ROOT / 'scripts' / 'compressed_backup'
BACKUP_ENABLED = True


def compress_image(filepath: Path, quality: int = JPEG_QUALITY, max_dim: int = MAX_DIMENSION):
    """Compress a single image, return (original_size, compressed_size, status, reduction_pct)"""
    original_size = filepath.stat().st_size
    filename = filepath.name.lower()

    try:
        img = Image.open(filepath)
        original_mode = img.mode

        # Handle transparency for JPEG conversion
        has_alpha = original_mode in ('RGBA', 'LA', 'P')

        if filename.endswith('.jpg') or filename.endswith('.jpeg'):
            if has_alpha:
                background = Image.new('RGB', img.size, (255, 255, 255))
                if original_mode == 'P':
                    img = img.convert('RGBA')
                background.paste(img, mask=img.split()[-1] if has_alpha else None)
                img = background
            elif original_mode != 'RGB':
                img = img.convert('RGB')

        # Resize if needed: longest side <= max_dim
        w, h = img.size
        longest = max(w, h)
        if longest > max_dim:
            ratio = max_dim / longest
            new_size = (int(w * ratio), int(h * ratio))
            img = img.resize(new_size, Image.Resampling.LANCZOS)
            print(f"    Resized: {w}x{h} -> {new_size[0]}x{new_size[1]}")

        # Save compressed
        if filename.endswith('.jpg') or filename.endswith('.jpeg'):
            img.save(filepath, 'JPEG', quality=quality, optimize=True)
        elif filename.endswith('.png'):
            img.save(filepath, 'PNG', optimize=True)
        else:
            img.save(filepath, optimize=True)

        compressed_size = filepath.stat().st_size
        reduction = (1 - compressed_size / original_size) * 100
        status = 'OK' if reduction > 0 else 'NO REDUCTION'
        return original_size, compressed_size, status, reduction

    except Exception as e:
        return original_size, 0, f'ERROR: {e}', 0


def backup_image(filepath: Path):
    """Backup original image to compressed_backup directory"""
    backup_path = COMPRESSED_DIR / filepath.relative_to(PROJECT_ROOT)
    backup_path.parent.mkdir(parents=True, exist_ok=True)
    with open(filepath, 'rb') as src, open(backup_path, 'wb') as dst:
        dst.write(src.read())
    return backup_path


def format_size(size_bytes: int) -> str:
    """Format file size for display"""
    for unit in ['B', 'KB', 'MB', 'GB']:
        if size_bytes < 1024:
            return f"{size_bytes:.1f} {unit}"
        size_bytes /= 1024
    return f"{size_bytes:.1f} TB"


def main():
    print("=" * 60)
    print("   NJUXun Image Compression Tool")
    print("=" * 60)
    print(f"JPEG Quality: {JPEG_QUALITY} | Max Dimension: {MAX_DIMENSION}px")
    print()

    if BACKUP_ENABLED:
        COMPRESSED_DIR.mkdir(parents=True, exist_ok=True)
        print(f"Backup dir: {COMPRESSED_DIR}")
        print()

    total_original = 0
    total_compressed = 0
    file_count = 0

    # Compress images in directories
    for img_dir in IMAGE_DIRS:
        if not img_dir.exists():
            print(f"[SKIP] Directory not found: {img_dir}")
            continue

        print(f"[DIR] {img_dir}")
        images = sorted([f for f in img_dir.iterdir()
                        if f.suffix.lower() in ('.jpg', '.jpeg', '.png')])

        for img_path in images:
            if BACKUP_ENABLED:
                backup_image(img_path)

            orig, comp, status, reduction = compress_image(img_path)
            total_original += orig
            total_compressed += comp
            file_count += 1
            print(f"  {img_path.name}: {format_size(orig)} -> {format_size(comp)} ({reduction:.0f}%) [{status}]")
        print()

    # Compress individual files
    for img_path in SINGLE_IMAGES:
        if not img_path.exists():
            print(f"[SKIP] File not found: {img_path}")
            continue

        if BACKUP_ENABLED:
            backup_image(img_path)

        # Use higher quality for maps to preserve readability
        quality = 85 if 'map' in str(img_path).lower() else JPEG_QUALITY
        print(f"[FILE] {img_path.relative_to(PROJECT_ROOT)}")
        orig, comp, status, reduction = compress_image(img_path, quality=quality)
        total_original += orig
        total_compressed += comp
        file_count += 1
        print(f"  {img_path.name}: {format_size(orig)} -> {format_size(comp)} ({reduction:.0f}%) [{status}]")
        print()

    print("=" * 60)
    print(f"Total files processed: {file_count}")
    print(f"Original size:  {format_size(total_original)}")
    print(f"Compressed:     {format_size(total_compressed)}")
    if total_original > 0:
        saved = total_original - total_compressed
        pct = (1 - total_compressed / total_original) * 100
        print(f"Space saved:    {format_size(saved)} ({pct:.0f}%)")
    print("=" * 60)
    print()
    print("Tip: To restore originals, copy files from:")
    print(f"  {COMPRESSED_DIR}")
    print("  Then adjust JPEG_QUALITY / MAX_DIMENSION and re-run.")


if __name__ == '__main__':
    main()
