<img src="assets/icons/exported/legacy-circle.png" alt="boorusphere icon" height="92" align="right">

# Boorusphere

Simple, content-focused booru viewer for Android

<a href="https://github.com/nullxception/boorusphere/releases">
    <img src="assets/button-GHReleases.png" alt="github release page" width="170">
</a>
<a href="https://apt.izzysoft.de/fdroid/index/apk/io.chaldeaprjkt.boorusphere">
    <img src="assets/button-IzzyOnDroid.png" alt="IzzyOnDroid release page" width="170">
</a>

# Preview
<p align="center">
    <img width="23%" src="assets/previews/screen0.jpg" alt="screenshot of application menu"/>
    <img width="23%" src="assets/previews/screen1.jpg" alt="screenshot of search result"/>
    <img width="23%" src="assets/previews/screen2.jpg" alt="screenshot of photo preview"/>
    <img width="23%" src="assets/previews/screen3.jpg" alt="screenshot of video preview"/>
</p>

# Building

This projects uses several code generator :
- [`freezed`](https://github.com/rrousselGit/freezed)
- [`json_serializable`](https://github.com/google/json_serializable.dart)
- [`flutter_oss_licenses`](https://github.com/espresso3389/flutter_oss_licenses)

So if you're editing some areas that needs a code generator (such as `lib/data`) or add/removing packages, make sure run the particular codegens before. for example:

```bash
# Run code generator for the data entities
$ flutter pub run build_runner build --delete-conflicting-outputs

# Generate licenses
$ flutter pub run flutter_oss_licenses:generate.dart -o lib/generated_licenses.dart
$ dart format --fix lib/generated_licenses.dart

# Build production-ready apks
$ flutter build apk --split-per-abi
```

# License

This work is licensed under [BSD 3-Clause License](LICENSE.md).
