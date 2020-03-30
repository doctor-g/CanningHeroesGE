#!/bin/bash
#
# Build the HTML5 target of the project.
#

# Exit on error
set -e
# Echo commands
set -x

godot --path project --export "HTML5" ../build/HTML5/index.html

