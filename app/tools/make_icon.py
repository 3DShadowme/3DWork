#!/usr/bin/env python3
# 生成 FilamentManager 的 App 图标（纯 zlib，无需 PIL）
import zlib, struct, math, os

OUT_DIR = os.path.join(os.path.dirname(__file__),
                       "..", "layout", "Applications", "FilamentManager.app")

ICONS = {
    "AppIcon60x60@2x.png": 120,
    "AppIcon60x60@3x.png": 180,
    "AppIcon76x76@2x.png": 152,
    "AppIcon83.5x83.5@2x.png": 167,
}

BG = (10, 132, 255)      # system blue
SPOOL = (255, 255, 255)  # white spool
HOLE = (180, 190, 200)   # hole gray
FIL = (255, 149, 0)      # orange filament ring


def draw(size):
    cx = cy = size / 2.0
    R = size * 0.36
    r = size * 0.13
    ring = R * 0.62
    ring_w = R * 0.13
    buf = bytearray()
    for y in range(size):
        for x in range(size):
            dx = x + 0.5 - cx
            dy = y + 0.5 - cy
            d = math.hypot(dx, dy)
            if d <= R:
                if d <= r:
                    col = HOLE
                elif abs(d - ring) < ring_w:
                    col = FIL
                else:
                    col = SPOOL
            else:
                col = BG
            buf.extend(col)
    return bytes(buf)


def write_png(path, size, rgb):
    raw = bytearray()
    stride = size * 3
    for y in range(size):
        raw.append(0)
        raw.extend(rgb[y * stride:(y + 1) * stride])
    comp = zlib.compress(bytes(raw), 9)

    def chunk(typ, body):
        return (struct.pack(">I", len(body)) + typ + body +
                struct.pack(">I", zlib.crc32(typ + body) & 0xFFFFFFFF))

    with open(path, "wb") as f:
        f.write(b"\x89PNG\r\n\x1a\n")
        ihdr = struct.pack(">IIBBBBB", size, size, 8, 2, 0, 0, 0)
        f.write(chunk(b"IHDR", ihdr))
        f.write(chunk(b"IDAT", comp))
        f.write(chunk(b"IEND", b""))


def main():
    os.makedirs(OUT_DIR, exist_ok=True)
    for name, size in ICONS.items():
        path = os.path.join(OUT_DIR, name)
        write_png(path, size, draw(size))
        print("wrote", path, size, "x", size)


if __name__ == "__main__":
    main()
