#!/usr/bin/env bash
# Report local Git branches with commits ahead of their configured upstream.

set -o nounset
set -o pipefail

projects_dir="${1:-$HOME/Projects}"

if [[ ! -d "$projects_dir" ]]; then
	printf 'Projects directory not found: %s\n' "$projects_dir" >&2
	exit 1
fi

found_unpushed=0
found_without_upstream=0
found_repositories=0

while IFS= read -r -d '' git_marker; do
	repository_dir="${git_marker%/.git}"
	[[ "$git_marker" == *.git ]] || continue

	if ! git -C "$repository_dir" rev-parse --is-inside-work-tree >/dev/null 2>&1; then
		continue
	fi

	found_repositories=1
	while IFS=$'\t' read -r branch_name upstream_name; do
		if [[ -z "$upstream_name" ]]; then
			printf 'NO UPSTREAM  %s  %s\n' "$repository_dir" "$branch_name"
			found_without_upstream=1
			continue
		fi

		ahead_count=$(git -C "$repository_dir" rev-list --count "$upstream_name..$branch_name")
		if ((ahead_count > 0)); then
			printf 'AHEAD %-6s  %s  %s -> %s\n' "$ahead_count" "$repository_dir" "$branch_name" "$upstream_name"
			found_unpushed=1
		fi
	done < <(git -C "$repository_dir" for-each-ref --format='%(refname:short)%09%(upstream:short)' refs/heads)
done < <(find "$projects_dir" -type d -name .git -prune -print0)

if ((found_repositories == 0)); then
	printf 'No Git repositories found under %s\n' "$projects_dir" >&2
	exit 1
fi

if ((found_unpushed == 0 && found_without_upstream == 0)); then
	printf 'All tracked branches are pushed.\n'
fi

if ((found_unpushed)); then
	exit 2
fi

if ((found_without_upstream)); then
	exit 3
fi
