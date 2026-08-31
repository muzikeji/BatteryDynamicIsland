#!/bin/bash
# BatteryIsland 双版本编译脚本：rootless + roothide
#
# 前置条件：
#   - 已安装 Theos（export THEOS=/path/to/theos，或默认 ~/theos）
#   - roothide 方案需要 roothide 的 Theos fork：https://github.com/roothide/theos
#     （标准 Theos 仅支持 rootless；若编译 roothide 请将 THEOS 指向 roothide fork）
#   - $THEOS/sdks 下已有 iOS 16.1+ SDK（含 ActivityKit.framework）
#
# 用法：
#   ./build.sh            # 编译两个版本
#   ./build.sh rootless   # 仅编译 rootless
#   ./build.sh roothide   # 仅编译 roothide

set -euo pipefail

export THEOS="${THEOS:-$HOME/theos}"

SCHEMES=("$@")
if [ "${#SCHEMES[@]}" -eq 0 ]; then
    SCHEMES=(rootless roothide)
fi

cd "$(dirname "$0")"

for scheme in "${SCHEMES[@]}"; do
    echo "=============================================="
    echo "==> 编译 ${scheme} 版本"
    echo "=============================================="
    make clean >/dev/null 2>&1 || true
    THEOS_PACKAGE_SCHEME="${scheme}" make package FINALPACKAGE=1
done

echo ""
echo "==> 产物："
ls -1 packages/*.deb
