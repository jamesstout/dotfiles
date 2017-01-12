#!/usr/bin/env bash

# echo ${BASH_SOURCE[0]}

# SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
 
# echo "$SCRIPT_DIR"

# cd "$SCRIPT_DIR" || exit

# pwd

set -e

eval "$(rbenv init -)"

for version in `rbenv whence gem`; do
  #rbenv shell "$version"
  echo "Updating rubygems for $version"
  #gem update --system --no-document --quiet
  echo ""
done
