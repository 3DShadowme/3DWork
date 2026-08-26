#!/usr/bin/env bash
# 把 Theos 打出的 .deb 转换成 巨魔(TrollStore) 可直接安装的 .tipa
set -e
cd "$(dirname "$0")"

DEB=$(ls -t packages/*.deb 2>/dev/null | head -n1)
if [ -z "$DEB" ]; then
  echo "未找到 packages/*.deb，请先运行: make package"
  exit 1
fi

WORK=$(mktemp -d)
echo "解包 $DEB ..."
dpkg-deb -x "$DEB" "$WORK/ext"

APP=$(find "$WORK/ext" -name "FilamentManager.app" -type d | head -n1)
if [ -z "$APP" ]; then
  echo "deb 中未找到 FilamentManager.app"
  exit 1
fi

rm -rf "$WORK/Payload"
mkdir -p "$WORK/Payload"
cp -R "$APP" "$WORK/Payload/FilamentManager.app"

OUT="$PWD/FilamentManager.tipa"
rm -f "$OUT"
cd "$WORK"
zip -r -y "$OUT" Payload >/dev/null

echo "已生成安装包: $OUT"
echo "把该 .tipa 用 巨魔(TrollStore) 打开即可安装。"
