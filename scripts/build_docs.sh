#!/bin/bash

# Docs by jazzy
# https://github.com/realm/jazzy
# ------------------------------

if which jazzy >/dev/null; then
    jazzy \
        --clean \
        --author 'PlanGrid' \
        --author_url 'https://twitter.com/PlanGrid' \
        --github_url 'https://github.com/plangrid/ReactiveLists' \
        --module 'ReactiveLists' \
        --source-directory . \
        --readme 'README.md' \
        --documentation 'Guides/*.md' \
        --output docs/ \;
else
    echo "
    Error: jazzy not installed! <https://github.com/realm/jazzy>
    Install: gem install jazzy
    "
    exit 1
fi
