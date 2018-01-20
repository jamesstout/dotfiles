#!/usr/bin/env bash
# shellcheck shell=bash

# Header logging
e_header() {
    printf "\n$(tput setaf 7)%s$(tput sgr0)\n" "$@"
}
# debug logging
e_debug() {
    printf "$(tput setaf 2)%s$(tput sgr0)\n" "$@"
}

# Success logging
e_success() {
    printf "$(tput setaf 64)✓ %s$(tput sgr0)\n" "$@"
}

# Error logging
e_error() {
    printf "$(tput setaf 1)x %s$(tput sgr0)\n" "$@"
}

# Warning logging
e_warning() {
    printf "$(tput setaf 136)! %s$(tput sgr0)\n" "$@"
}

is_git_repo() {
    $(git rev-parse --is-inside-work-tree &> /dev/null)
}

is_git_dir() {
    $(git rev-parse --is-inside-git-dir 2> /dev/null)
}

get_git_branch() {
    local branch_name

    # Get the short symbolic ref
    branch_name=$(git symbolic-ref --quiet --short HEAD 2> /dev/null) ||
    # If HEAD isn't a symbolic ref, get the short SHA
    branch_name=$(git rev-parse --short HEAD 2> /dev/null) ||
    # Otherwise, just give up
    branch_name="(unknown)"

    printf "%s" "$branch_name"
}

git_status_ok() {

    if ! is_git_repo || is_git_dir; then
    	e_error "Not a git repo or dir"
        return 1
    fi

    # ensure index is up to date
    git update-index --really-refresh  -q &>/dev/null

    # remember git will ignore empty dirs
    # unless they contain a .gitignore file
    # so the prompt should be correct
    # with the caveat that it ignores any new empty folders

    # Check for uncommitted changes in the index
    if ! $(git diff --quiet --ignore-submodules --cached); then
        e_error "uncommitted changes"
        return 1
    fi

    # Check for unstaged changes
    if ! $(git diff-files --quiet --ignore-submodules --); then
        e_error "unstaged changes"
        return 1

    fi

    # Check for untracked files
    if [ -n "$(git ls-files --others --exclude-standard)" ]; then
        e_error "untracked files"
        return 1
    fi

    # # Check for stashed files
    # if $(git rev-parse --verify refs/stash &>/dev/null); then
    #     e_error "stashed files"
    #     return 1
    # fi

 	return 0
}



e_debug "checking git status is good"

if ! git_status_ok; then
    e_error "git status not clean"
    exit 255
fi
 
git_branch=$(get_git_branch)

if [[ "$git_branch" == "master" ]]; then
    e_error "on MASTER!"
    exit 255
else 
	e_debug "switch to master"
	git checkout master
	e_debug "merging $git_branch into master"
	git merge "$git_branch" --no-ff --log
	e_debug "tagging $git_branch"
	git tag -a v"$git_branch" -m "tagging v$git_branch"
fi
   


