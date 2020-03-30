#!/bin/bash
#
# Build the project and deploy it for gh-pages
#

# Exit on error
set -e
# Echo commands
set -x

# Build the target 
bash build.sh

cd build/HTML5
git init .
git checkout -b gh-pages
git add -A
git commit -m "Publish to gh-pages"
git remote add origin git@github.com:doctor-g/CanningHeroesGE.git
git push --force -u origin gh-pages
