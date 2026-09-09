#!/usr/bin/env bash
# 一键推送:主仓库与全部子仓库同步推送到 GitCode(origin)与 GitHub(github)。
# 用法:
#   ./推送.sh              # 普通推送
#   ./推送.sh --force      # 强制推送(用于 LFS 迁移等历史重写后)
#   ./推送.sh --fetch      # 推送前先拉取各仓库(origin)
set -euo pipefail
export GIT_TERMINAL_PROMPT=0   # 无凭据时立即失败而非挂起等待输入
export GIT_HTTP_LOW_SPEED_LIMIT=1000
export GIT_HTTP_LOW_SPEED_TIME=30

cd "$(dirname "$0")"

# 仓库列表:主仓库 + 子模块
repos=(. 文档 模板 程序 图片)

extra=()
for a in "$@"; do
  case "$a" in
    --force) extra+=(--force) ;;
    --fetch) fetch=1 ;;
    *) echo "未知参数: $a"; exit 1 ;;
  esac
done

fetch=${fetch:-0}

for r in "${repos[@]}"; do
  echo "===== $r ====="
  # 子模块可能处于 detached HEAD,先切回 main
  if [ "$r" != "." ] && [ "$(git -C "$r" branch --show-current)" != "main" ]; then
    git -C "$r" checkout main
  fi
  if [ "$fetch" = "1" ]; then
    git -C "$r" pull origin main --ff-only || echo "  (拉取跳过/无更新)"
  fi
  # 防呆:origin 必须指向 GitCode(避免被 .gitmodules 同步覆盖)
  if ! git -C "$r" remote get-url origin | grep -q "gitcode.com"; then
    echo "  (警告:$r 的 origin 不是 GitCode,跳过 origin 推送)"
    true
  else
  echo "--> GitCode(origin)"
  git -C "$r" push origin main ${extra[@]+"${extra[@]}"} || echo "  (GitCode 推送失败,继续)"
  echo "--> GitHub(github)"
  git -C "$r" push github main ${extra[@]+"${extra[@]}"} || echo "  (GitHub 推送失败,继续)"
  fi
done

echo "全部完成。"
