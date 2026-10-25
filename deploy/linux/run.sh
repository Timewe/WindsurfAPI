#!/usr/bin/env bash
# WindsurfAPI — Linux 前台启动脚本
set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
EXE="$SCRIPT_DIR/windsurfapi"

if [ ! -f "$EXE" ]; then
  echo "错误: 未找到 windsurfapi 可执行文件。" >&2
  echo "请把 windsurfapi 放到 $SCRIPT_DIR" >&2
  exit 1
fi

chmod +x "$EXE"
exec "$EXE" "$@"
