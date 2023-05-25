<img src="assets/icons/exported/legacy-circle.png" alt="boorusphere icon" height="92" align="right">

# Boorusphere

Simple, content-focused booru viewer for Android

<p>
    <a href="https://github.com/asyncmash/boorusphere/releases/latest">
        <img alt="Latest release" src="https://img.shields.io/github/v/release/asyncmash/boorusphere?style=flat-square">
    </a>
    <img alt="Workflow status" src="https://img.shields.io/github/actions/workflow/status/asyncmash/boorusphere/testing.yml?style=flat-square">
    <a href="https://github.com/asyncmash/boorusphere/blob/main/LICENSE.md">
        <img alt="License" src="https://img.shields.io/github/license/asyncmash/boorusphere?color=violet&style=flat-square">
    </a>
</p>
<p>
    <a href="https://github.com/asyncmash/boorusphere/releases">
        <img src="assets/button-GHReleases.png" alt="GitHub release" width="160">
    </a>
    <a href="https://apt.izzysoft.de/fdroid/index/apk/io.chaldeaprjkt.boorusphere">
        <img src="assets/button-IzzyOnDroid.png" alt="IzzyOnDroid release" width="160">
    </a>
</p>

# Preview

<p align="justify">
    <img width="24%" src="assets/previews/drawer.webp" />
    <img width="24%" src="assets/previews/home.webp" />
    <img width="24%" src="assets/previews/search.webp" />
    <img width="24%" src="assets/previews/favorites.webp" />
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
