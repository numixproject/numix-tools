#!/usr/bin/env bash

# Numix icon themes packaging script, v0.1
# GPLv3+ Licensed, Copyright 2019, Numix Project

themes=("circle" "square")

# ensure it has the core repo downloaded and up to date
if [ ! -d "core/" ]; then
    git clone git@github.com:numixproject/numix-core.git core
    cd core/
else
    cd core/ && git pull
fi

for theme in "${themes[@]}"; do
    # build the latest theme from git
    ./gen.py --platform linux --theme $theme
    cd ../

    # ensure it has the theme packaging repo downloaded and up to date
    if [ ! -d "$theme" ]; then
        git clone git@github.com:numixproject/numix-icon-theme-$theme.git $theme
        cd $theme
    else
        cd $theme && git pull
    fi

    # replace the theme app dir with the newly built one
    dir="Numix-${theme^}/48/apps"
    rm -r $dir
    mv ../core/numix-icon-theme-$theme/$dir $dir

    # check if changes to make
    if ! git diff-index --quiet HEAD --; then
        git add $dir
        git commit -m "Icons from $(date +%y.%m.%d)"
        git push origin master
    fi

    # return to core directory
    cd ../core
done
