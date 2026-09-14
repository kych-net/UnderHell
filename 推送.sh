#!/usr/bin/env bash
# 一键推送:主仓库与全部子仓库同步推送到 GitCode(origin)与 GitHub(github)。
# 推送顺序:先子模块、后主仓库 —— 确保主仓库更新子模块指针的 commit
# 推送时,其引用的子模块 commit 已在各远端存在;否则 CI 拉子模块时
# 会因引用不可达而失败("not our ref" / direct fetching that commit failed)。
# 用法:
#   ./推送.sh              # 普通推送
#   ./推送.sh --force      # 强制推送(用于 LFS 迁移等历史重写后)
#   ./推送.sh --fetch      # 推送前先拉取各仓库(origin)
set -euo pipefail
export GIT_TERMINAL_PROMPT=0   # 无凭据时立即失败而非挂起等待输入
export GIT_HTTP_LOW_SPEED_LIMIT=1000
export GIT_HTTP_LOW_SPEED_TIME=30

cd "$(dirname "$0")"

# 仓库列表:主仓库(.)最后推送,子模块(文档 模板 程序 图片)先推。
# 理由见文件头注释:保证子模块提交先于主仓库指针提交上线。
repos=(文档 模板 程序 图片 .)

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
  git -C "$r" push --recurse-submodules=on-demand origin main ${extra[@]+"${extra[@]}"} || echo "  (GitCode 推送失败,继续)"
  echo "--> GitHub(github)"
  git -C "$r" push --recurse-submodules=on-demand github main ${extra[@]+"${extra[@]}"} || echo "  (GitHub 推送失败,继续)"
  fi
done

echo "全部完成。"
