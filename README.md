<img src="assets/icons/exported/legacy-circle.png" alt="boorusphere icon" height="92" align="right">

# Boorusphere

Simple, content-focused booru viewer for Android

![GitHub release (latest by date)](https://img.shields.io/github/v/release/nullxception/boorusphere?style=flat-square) ![GitHub Workflow Status](https://img.shields.io/github/actions/workflow/status/nullxception/boorusphere/testing.yml?label=tests&style=flat-square)

<a href="https://github.com/nullxception/boorusphere/releases">
    <img src="assets/button-GHReleases.png" alt="github release page" width="170">
</a>
<a href="https://apt.izzysoft.de/fdroid/index/apk/io.chaldeaprjkt.boorusphere">
    <img src="assets/button-IzzyOnDroid.png" alt="IzzyOnDroid release page" width="170">
</a>

# Preview

<p align="center">
    <img width="24.5%" src="assets/previews/drawer.webp" />
    <img width="24.5%" src="assets/previews/home.webp" />
    <img width="24.5%" src="assets/previews/search.webp" />
    <img width="24.5%" src="assets/previews/favorites.webp" />
</p>

# Features

- Simple and intuitive UI
- Support various booru-based imageboards
- Support playing videos and animated images (GIF, WEBM)
- Save favorites content
- Search with tag suggestion
- Download images and videos
- Block tags from search result
- Backup and restore data
- and many more ...

# Building

This projects uses several code generators such as [freezed](https://github.com/rrousselGit/freezed), [json_serializable](https://github.com/google/json_serializable.dart), [hive_generator](https://github.com/hivedb/hive), and [auto_route_generator](https://github.com/Milad-Akarie/auto_route_library).

So if you're editing some areas that needs a code generator such as entities, routing, i18n, or add/removing packages, make sure to run the code generator before building.

```bash
# Sync dependencies
$ flutter pub get

# Generate everything that needed
$ derry gen all
# ..or just regenerate i18n
$ derry gen lang
```

Run `derry ls` for complete list of script available.

After that, you can use regular `flutter` commands to deploy app to your device, for example:

```bash
# run app in debug mode
$ flutter run
```

For more details, see [Flutter's build modes](https://docs.flutter.dev/testing/build-modes).

# License

This work is licensed under [BSD 3-Clause License](LICENSE.md).
