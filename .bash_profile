# shellcheck shell=bash
# Add `~/bin` to the `$PATH`
export PATH="$HOME/bin:$PATH"

# Load environment and local override files.
for file in ~/.{path,exports,emails,utils,functions,extra}; do
	# shellcheck source=/dev/null
	[ -r "$file" ] && source "$file"
done
unset file

# Prompt, aliases, completion, and shell options are interactive-only.
[[ $- == *i* ]] || return 0

# Load interactive shell configuration.
for file in ~/.{bash_prompt,aliases}; do
	# shellcheck source=/dev/null
	[ -r "$file" ] && source "$file"
done
unset file


#~/bin/startup-gpg-agent.sh


#  NO need for this with the new agent

# GPG
# if [ -f "${HOME}/.gnupg/.gpg-agent-info" ]; then
# 	# shellcheck source=/Users/james/.gnupg/.gpg-agent-info
# 	. "${HOME}/.gnupg/.gpg-agent-info"
# 	export GPG_AGENT_INFO
# 	export SSH_AUTH_SOCK
# 	launchctl setenv GPG_AGENT_INFO "$GPG_AGENT_INFO"
# fi
# GPG_TTY=$(tty)
# export GPG_TTY

#. ~/bin/bashmarks.sh
# shamelessly copied from https://github.com/janmoesen/tilde/blob/master/.bash/shell
# Shell options, environment variables and readline settings
# =============================================================================

# Globbing and completion
# -----------------------------------------------------------------------------

# Do not autocomplete when accidentally pressing Tab on an empty line. (It takes
# forever and yields "Display all 15 gazillion possibilites?")
shopt -s no_empty_cmd_completion

# Case-insensitive globbing (used in pathname expansion)
shopt -s nocaseglob

# Append to the Bash history file, rather than overwriting it
shopt -s histappend

# save multi-line commands as one command
shopt -s cmdhist

# include .files when globbing.
shopt -s dotglob 2>/dev/null

# use extra globing features. See man bash, search extglob.
shopt -s extglob 2>/dev/null

# Autocorrect typos in path names when using `cd`
shopt -s cdspell 2>/dev/null
shopt -s dirspell 2>/dev/null

# Check the window size after each command and, if necessary, update the values
# of LINES and COLUMNS.
shopt -s checkwinsize 2>/dev/null

# Enable some Bash 4 features when possible:
# * `autocd`, e.g. `**/qux` will enter `./foo/bar/baz/qux`
# * Recursive globbing, e.g. `echo **/*.txt`
for option in autocd globstar; do
	shopt -s "$option" 2>/dev/null
done

# Add tab completion for SSH hostnames based on ~/.ssh/config, ignoring wildcards
if [[ -r "$HOME/.ssh/config" ]]; then
	ssh_hosts=$(awk '$1 == "Host" { for (host_index = 2; host_index <= NF; host_index++) if ($host_index !~ /[?*]/) print $host_index }' "$HOME/.ssh/config")
	complete -o "default" -o "nospace" -W "$ssh_hosts" scp sftp ssh
	unset ssh_hosts
fi

# Add tab completion for `defaults read|write NSGlobalDomain`
# You could just use `-g` instead, but I like being explicit
complete -W "NSGlobalDomain" defaults

# Add `killall` tab completion for common apps
complete -o "nospace" -W "Calendar Dock Dashboard Finder Mail Safari iTunes SystemUIServer, Fabric, Cloud, Dropbox, Fantastical, HazelHelper, ChronoSyncBackgrounder, GeekTool\ Helper" killall

## Tab Completions
set completion-ignore-case On

if command -v brew >/dev/null 2>&1; then
	brew_prefix=$(brew --prefix)
	for comp in \
		"$brew_prefix/etc/grc.bashrc" \
		"$brew_prefix/etc/bash_completion.d/git-completion.bash" \
		"$brew_prefix/etc/bash_completion.d/brew" \
		"$brew_prefix/etc/bash_completion.d/mas"; do
		# shellcheck source=/dev/null
		[[ -r "$comp" ]] && source "$comp"
	done
	unset brew_prefix comp
fi

unalias ls 2>/dev/null || true
# Detect which `ls` flavor is in use
if ls --color >/dev/null 2>&1; then # GNU `ls`
	colorflag="--color"
else # OS X `ls`
	colorflag="-G"
fi

# shellcheck disable=SC2139
alias ls="ls ${colorflag}"
unset colorflag
# these are set in /usr/local/etc/grc.bashrc
# I don't want them
# unalias make
# unalias gcc
# unalias g++
# unalias as
# unalias docker
# unalias gas
# unalias ld
# unalias netstat
# unalias ping
# unalias traceroute
# unalias head
# unalias ip
# unalias tail
# unalias dig
# unalias diff
#unalias du

alias ip="dig +short myip.opendns.com @resolver1.opendns.com"

if command -v thefuck >/dev/null 2>&1; then
	eval "$(thefuck --alias fk)"
fi
if command -v rbenv >/dev/null 2>&1; then
	eval "$(rbenv init -)"
fi
if command -v lua >/dev/null 2>&1 && [[ -r "$HOME/bin/z.lua" ]]; then
	eval "$(lua "$HOME/bin/z.lua" --init bash enhanced once fzf)"
fi
# source ~/bin/czmod/czmod.bash
# shellcheck disable=SC1091
[[ -r "$HOME/.iterm2_shell_integration.bash" ]] && source "$HOME/.iterm2_shell_integration.bash"
