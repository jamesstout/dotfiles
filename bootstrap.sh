#!/usr/bin/env bash
# shellcheck shell=bash
# shellcheck disable=SC1091

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)" || return 1

source "$SCRIPT_DIR/.utils" || return 1

managed_files=(
	.bash_profile .bash_prompt .iterm2_shell_integration.bash .path .exports
	.aliases .functions .gitattributes .gitconfig .gitignore .gitignore_global
	.inputrc .hgignore .wgetrc .vimrc .utils .bashrc .gemrc .tmux.conf .npmrc .ackrc
)
managed_directories=(.vim .hammerspoon .git_template)
bin_files=(
	z.lua tdu piper merge-branch.sh editor.sh extract ixio httpcompression
	bashmarks.sh de-dupe-bash-eternal-history.sh startup-gpg-agent.sh
	itunes-apps-periodic-cleanup.py blame-bird.py tm-log check-unpushed-commits.sh
)

copy_to_backup() {
	local source_path="$1"
	local backup_dir="$2"

	if [[ -d "$source_path" ]]; then
		cp -R "$source_path" "$backup_dir/"
	else
		cp -p "$source_path" "$backup_dir/"
	fi
}

confirm_overwrite() {
	local path
	local existing_paths=()

	for path in "${managed_directories[@]}" "${managed_files[@]}"; do
		[[ -e "$HOME/$path" ]] && existing_paths+=("$path")
	done

	if [[ ${#existing_paths[@]} -eq 0 || "${1:-}" == "-f" ]]; then
		return 0
	fi

	seek_confirmation "A timestamped backup will be created before replacing: ${existing_paths[*]}"
	is_confirmed
}

backup_existing_files() {
	local backup_dir
	local path

	backup_dir="$HOME/.backups/$(date +%Y%m%d-%H%M%S)"
	mkdir -p "$backup_dir" || return 1

	for path in "${managed_directories[@]}" "${managed_files[@]}"; do
		[[ -e "$HOME/$path" ]] || continue
		copy_to_backup "$HOME/$path" "$backup_dir" || return 1
	done

	e_success "Backed up existing files to $backup_dir"
}

install_dotfiles() {
	local path

	for path in "${managed_directories[@]}"; do
		cp -Rf "$SCRIPT_DIR/$path" "$HOME/" || return 1
	done

	for path in "${managed_files[@]}"; do
		cp -f "$SCRIPT_DIR/$path" "$HOME/" || return 1
	done
}

install_binaries() {
	local bin_dir="$HOME/bin"

	mkdir -p "$bin_dir" || return 1
	cp -f "${bin_files[@]/#/$SCRIPT_DIR/bin/}" "$bin_dir/" || return 1
	chmod +x "${bin_files[@]/#/$bin_dir/}" || return 1
}

update_npm() {
	if [[ "${UPDATE_NPM:-0}" != "1" ]]; then
		e_debug "Skipping npm updates; run UPDATE_NPM=1 source bootstrap.sh to include them"
		return 0
	fi

	command -v npm >/dev/null 2>&1 || return 1
	e_header "Updating npm packages..."
	npm update -g
}

update_ruby_gems() {
	local version

	if [[ "${UPDATE_RUBY_GEMS:-0}" != "1" ]]; then
		e_debug "Skipping RubyGems updates; run UPDATE_RUBY_GEMS=1 source bootstrap.sh to include them"
		return 0
	fi

	command -v rbenv >/dev/null 2>&1 || return 1
	command -v gem >/dev/null 2>&1 || return 1
	e_header "Updating RubyGems..."
	while IFS= read -r version; do
		rbenv shell "$version" || return 1
		gem update --system --no-document || return 1
		gem update || return 1
		gem cleanup -v || return 1
	done < <(rbenv whence gem)
	rbenv rehash
}

main() {
	local stats_dir="$HOME/stats"

	# if ! confirm_overwrite "${1:-}"; then
	# 	e_warning "Aborting without changing dotfiles"
	# 	return 1
	# fi

	backup_existing_files || return 1
	install_dotfiles || return 1

	if ! doiTermIntegrationCheck; then
		e_error "Could not update iTerm shell integration"
		return 1
	fi

	# shellcheck source=.brew
	source "$SCRIPT_DIR/.brew" || return 1
	update_npm || return 1
	update_ruby_gems || return 1

	mkdir -p "$stats_dir" || return 1
	install_binaries || return 1
	e_success "Bootstrap complete"
}

main "$@"
