# Add `~/bin` to the `$PATH`
export PATH="$HOME/bin:$PATH"

# Load the shell dotfiles, and then some:
# * ~/.path can be used to extend `$PATH`.
# * ~/.extra can be used for other settings you don’t want to commit.
for file in ~/.{path,bash_prompt,exports,aliases,utils,functions,extra}; do
	[ -r "$file" ] && source "$file"
done
unset file

. ~/bin/z.sh

source ~/.iterm2_shell_integration.bash

#. ~/bin/bashmarks.sh
# shamelessly copied from https://github.com/janmoesen/tilde/blob/master/.bash/shell
# Shell options, environment variables and readline settings
# =============================================================================

# Globbing and completion
# -----------------------------------------------------------------------------

# Do not autocomplete when accidentally pressing Tab on an empty line. (It takes
# forever and yields "Display all 15 gazillion possibilites?")
shopt -s no_empty_cmd_completion;

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
	shopt -s "$option" 2> /dev/null
done

# Add tab completion for SSH hostnames based on ~/.ssh/config, ignoring wildcards
[ -e "$HOME/.ssh/config" ] && complete -o "default" -o "nospace" -W "$(grep "^Host" ~/.ssh/config | grep -v "[?*]" | cut -d " " -f2)" scp sftp ssh

# Add tab completion for `defaults read|write NSGlobalDomain`
# You could just use `-g` instead, but I like being explicit
complete -W "NSGlobalDomain" defaults

# Add `killall` tab completion for common apps
complete -o "nospace" -W "Calendar Dock Dashboard Finder Mail Safari iTunes SystemUIServer, Crashlytics, Cloud, Dropbox, Fantastical, Growl, HazelHelper, ChronoSyncBackgrounder, GeekTool\ Helper" killall

## Tab Completions
set completion-ignore-case On

prefix=$(brew --prefix)
for comp in \
  /etc/bash_completion \
  $prefix/share/bash-completion/bash_completion \
  $prefix/Library/Contributions/brew_bash_completion.sh \
  $prefix/etc/grc.bashrc \
  $prefix/etc/bash_completion.d/git-completion.bash
do
    [[ -e $comp ]] && source $comp
done
