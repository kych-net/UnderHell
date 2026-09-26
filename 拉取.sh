#!/usr/bin/env bash
# 一键拉取:主仓库与全部子仓库从 GitCode(origin)与 GitHub(github)拉取最新。
# 只拉取,不提交、不推送。
# 子模块可能处于 detached HEAD,会先切回 main 再拉。
# 同时强制同步标签:远端同名 tag 会覆盖本地 tag(历史重写/重打 tag 后本地会过期)。
# 用法:
#   ./拉取.sh            # 普通拉取(--ff-only)
#   ./拉取.sh --rebase   # 用 rebase 方式拉取
set -euo pipefail
export GIT_TERMINAL_PROMPT=0   # 无凭据时立即失败而非挂起等待输入
export GIT_HTTP_LOW_SPEED_LIMIT=1000
export GIT_HTTP_LOW_SPEED_TIME=30

cd "$(dirname "$0")"

# 仓库列表:主仓库(.)最后拉,子模块先拉。
repos=(文档 模板 程序 图片 素材 .)
remotes=(origin github)

extra=()
for a in "$@"; do
  case "$a" in
    --rebase) extra+=(--rebase) ;;
    *) echo "未知参数: $a"; exit 1 ;;
  esac
done

# --ff-only 与 --rebase 互斥:默认 --ff-only,传 --rebase 时改用 rebase。
if [ "${#extra[@]}" -gt 0 ]; then
  pull_args=("${extra[@]}")
else
  pull_args=(--ff-only)
fi

for r in "${repos[@]}"; do
  echo "===== $r ====="
  # 子模块可能处于 detached HEAD,先切回 main(有本地改动时可能失败,提示后继续)
  if [ "$r" != "." ] && [ "$(git -C "$r" branch --show-current)" != "main" ]; then
    git -C "$r" checkout main || echo "  (切到 main 失败,可能工作区有改动)"
  fi
  for remote in "${remotes[@]}"; do
    if ! git -C "$r" remote get-url "$remote" >/dev/null 2>&1; then
      echo "  (无 $remote 远程,跳过)"
      continue
    fi
    echo "--> $remote"
    git -C "$r" pull "${pull_args[@]}" "$remote" main || echo "  ($remote 拉取跳过/无更新)"
    # 强制同步标签:用远端同名 tag 覆盖本地。多远程时后拉取者优先(顺序 origin → github)。
    git -C "$r" fetch --tags --force "$remote" || echo "  ($remote 标签同步跳过)"
  done
done

echo "全部完成。"