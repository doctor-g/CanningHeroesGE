#!/bin/bash
#
# Build the HTML5 target of the project.
#

# Exit on error
set -e
# Echo commands
set -x

TARGET=index
DIR=build/HTML5

# Create the staging directory
mkdir -p $DIR

# Build the normal output
godot --path project --export "HTML5" ../$DIR/$TARGET.html

#
# The following steps to reduce the project size come from
# https://www.reddit.com/r/godot/comments/8b67lb/guide_how_to_compress_wasmpck_file_to_make_html5/
#

# Copy pako to the staging directory 
cp tools/pako_inflate.min.js $DIR

# Go to the staging directory
cd $DIR

# Zip up the wasm and pck files
for FILE in $TARGET.wasm $TARGET.pck
do
    gzip -f $FILE
done

# Make the html file load the pako script
FIND="<script type='text/javascript' src='$TARGET.js'></script>"
REPLACE="<script type=\"text/javascript\" src=\"pako_inflate.min.js\"></script>$FIND"
sed -i -e "s@$FIND@$REPLACE@" $TARGET.html

# Make the js file unzip the gzipped artifacts
FIND="function loadXHR(resolve, reject, file, tracker) {"
REPLACE=$FIND" if (file.substr(-5) === '.wasm' || file.substr(-4) === '.pck') { file += '.gz'; var resolve_orig = resolve; resolve = function(xhr) { return resolve_orig(xhr.responseURL.substr(-3) === '.gz' ? { response: pako.inflate(xhr.response), responseType: xhr.responseType, responseURL: xhr.responseURL, status: xhr.status, statusText: xhr.statusText } : xhr); }; }"
sed -i -e "s@$FIND@$REPLACE@" $TARGET.js
