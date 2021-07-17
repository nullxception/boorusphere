#!/bin/bash
#
# apk-releases renamer
#
name=boorusphere
rootdir=$(realpath $(dirname $(readlink -f $0))/..)
ver=$(grep -E '^version: ' $rootdir/pubspec.yaml | head -n1 | sed 's/.* \([0-9.]*\)+.*/\1/')
archs=(arm64-v8a armeabi-v7a x86_64)
outdir=$rootdir/build/app/outputs/flutter-apk
for arch in ${archs[@]}; do
    src=app-$arch-release.apk
    dest=boorusphere-$ver-$arch.apk
    mv $outdir/$src $outdir/$dest
done
