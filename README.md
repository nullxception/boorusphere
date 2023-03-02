<img src="assets/icons/exported/legacy-circle.png" alt="boorusphere icon" height="92" align="right">

# Boorusphere ![GitHub release (latest by date)](https://img.shields.io/github/v/release/nullxception/boorusphere?style=flat-square) ![GitHub Workflow Status](https://img.shields.io/github/actions/workflow/status/nullxception/boorusphere/testing.yml?label=tests&style=flat-square)

Simple, content-focused booru viewer for Android

<a href="https://github.com/nullxception/boorusphere/releases">
    <img src="assets/button-GHReleases.png" alt="github release page" width="170">
</a>
<a href="https://apt.izzysoft.de/fdroid/index/apk/io.chaldeaprjkt.boorusphere">
    <img src="assets/button-IzzyOnDroid.png" alt="IzzyOnDroid release page" width="170">
</a>

# Preview

<details open>
    <summary>Feature and Content</summary>
        <p align="center">
         <img width="23%" src="assets/previews/content/screen0.jpg" alt="screenshot of photo preview"/>
         <img width="23%" src="assets/previews/content/screen1.jpg" alt="screenshot of of video preview"/>
         <img width="23%" src="assets/previews/content/screen2.jpg" alt="screenshot of tag searching"/>
         <img width="23%" src="assets/previews/content/screen3.jpg" alt="screenshot of search bar"/>
     </p>
</details>

<details>
    <summary>Light Theme</summary>
        <p align="center">
         <img width="23%" src="assets/previews/light/screen0.jpg" alt="screenshot of application version"/>
         <img width="23%" src="assets/previews/light/screen1.jpg" alt="screenshot of settings"/>
         <img width="23%" src="assets/previews/light/screen2.jpg" alt="screenshot of download option"/>
         <img width="23%" src="assets/previews/light/screen3.jpg" alt="screenshot of content infomation"/>
     </p>
</details>

<details>
    <summary>Dark Theme</summary>
        <p align="center">
         <img width="23%" src="assets/previews/dark/screen0.jpg" alt="screenshot of application version"/>
         <img width="23%" src="assets/previews/dark/screen1.jpg" alt="screenshot of settings"/>
         <img width="23%" src="assets/previews/dark/screen2.jpg" alt="screenshot of download option"/>
         <img width="23%" src="assets/previews/dark/screen3.jpg" alt="screenshot of content infomation"/>
     </p>
</details><br/>

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
