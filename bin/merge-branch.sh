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
    git rev-parse --is-inside-work-tree >/dev/null 2>&1
}

is_git_dir() {
    git rev-parse --is-inside-git-dir >/dev/null 2>&1
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
    local status_output

    if ! is_git_repo || is_git_dir; then
        e_error "Not a git working tree"
        return 1
    fi

    status_output=$(git status --porcelain=v2 --untracked-files=all 2>/dev/null) || {
        e_error "Could not read Git status"
        return 1
    }
    if [[ -n "$status_output" ]]; then
        e_error "working tree is not clean"
        return 1
    fi

    return 0
}



e_debug "checking git status is good"

if ! git_status_ok; then
    e_error "git status not clean"
    exit 255
fi
 
git_branch=$(get_git_branch)

if [[ "$git_branch" == "main" ]]; then
    e_error "on main!"
    exit 255
else 
    e_debug "switch to main"
    git checkout main || exit 1
    e_debug "merging $git_branch into main"
    git merge "$git_branch" --no-ff --log || exit 1
    e_debug "tagging $git_branch"
    git tag -s "$git_branch" -m "tagging $git_branch" || exit 1
fi
   


