<p align="center">
    <img src="assets/banner.jpg" alt="boorusphere's banner image" width="70%"/>
    <br/>
    <i>Yet another booru imageboards viewer for Android</i>
</p>

## Download
<a href="https://apt.izzysoft.de/fdroid/index/apk/io.chaldeaprjkt.boorusphere">
    <img src="assets/button-IzzyOnDroid.png" alt="IzzyOnDroid release page" width="170">
</a>
<a href="https://github.com/nullxception/boorusphere/releases">
    <img src="assets/button-GHReleases.png" alt="github release page" width="170">
</a>

## Preview

<p align="center">
    <img width="23%" src="assets/previews/screen0.jpg" alt="screenshot of application menu"/>
    <img width="23%" src="assets/previews/screen1.jpg" alt="screenshot of search result"/>
    <img width="23%" src="assets/previews/screen2.jpg" alt="screenshot of photo preview"/>
    <img width="23%" src="assets/previews/screen3.jpg" alt="screenshot of video preview"/>
</p>

## Building

You can build this app just like any other flutter app, for example:

```bash
$ flutter build apk --target-platform=android-arm64
```

This projects uses several code generator such as [`freezed`](https://github.com/rrousselGit/freezed), [`json_serializable`](https://github.com/google/json_serializable.dart), and [`license_generator`](https://github.com/icapps/flutter-icapps-license), so if you're editing some areas that needs a code generator (such as models) or add/removing packages, make sure run the build_runner before debugging:

```bash
$ flutter pub run build_runner build --delete-conflicting-outputs
$ flutter pub run license_generator generate
```

## License

This work is licensed under [BSD 3-Clause License](LICENSE.md).
