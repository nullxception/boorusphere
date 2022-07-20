#!/bin/sh
self=$(realpath "$(dirname "$0")")
dpi=910.22
dest=$self/exported
cd $self

if [ -d $dest ]; then
    rm -rf $dest
fi

mkdir $dest

inkscape \
    --actions="select-by-id:md-adaptive,base-circle;selection-hide;
    export-id-only;export-id:container;
    export-dpi:$dpi;export-filename:$dest/legacy-fill.png;
    export-do" logo.svg

inkscape \
    --actions="select-by-id:md-adaptive,base;selection-hide;
    export-id-only;export-id:container;
    export-dpi:$dpi;export-filename:$dest/legacy-circle.png;
    export-do" logo.svg

inkscape \
    --actions="select-by-id:md-adaptive,base,base-circle;
    selection-hide;
    export-dpi:$dpi;
    export-filename:$dest/adaptive-foreground.png;
    export-do" logo.svg

inkscape \
    --actions="export-id-only;export-id:logo;
    export-dpi:$dpi;
    export-filename:$dest/logo.png;
    export-do" logo.svg
