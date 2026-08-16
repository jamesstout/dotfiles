#!/usr/bin/env bash

for file in **/*.flac
do
    echo "$file"
    /usr/local/bin/xld --profile Jimmy "$file"
done

