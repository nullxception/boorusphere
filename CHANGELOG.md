## 1.3.0
- Add rating selection to search screen
- Add settings to only blur content on timeline
- Fix favorites page bottom bar
- Fix restore data permission on Android 12
- Initial support for backstack navigation
- Remove safe-mode on settings page (replaced with rating selection)

## 1.2.9
* Fix loading danbooru image on unstable connection
* Update Flutter to 3.7.0

## 1.2.8
* Add Russian translation (by @wheremyfiji)
* Add Ukrainian translation (by @CakesTwix)
* Update Flutter engine to 3.3.10

## 1.2.7
* Add Filipino language (by @maisans-maid)
* Add Japanese language (by @rinme)
* Add Turkish language (by @kyoyacchi)
* Fix add-button did not replace typed word on search screen
* Fix Keyboard Incognito settings always keep getting reset
* Fix nomedia creation issues
* Fix video player late fullscreen exit
* Improve tag blocker mechanism
* Initial support for backup and restore app data
* Update Indonesia translations
* Update Thai translations (by @rinme and @altinat)

## 1.2.6
* Add Thai language (by @altinat)
* Improve and fix several issues on video player
* Fix download status and progress not showing properly
* Keep screen awake when opening post viewer

## 1.2.5
* Add support for Incognito Keyboard mode (Settings -> Safe Mode -> Incognito Keyboard)
* Fix scanner is being blocked on some site (such as e621)
* Fix video player crash while loading source

## 1.2.4
* Fix parser error when post(s) contains a tag ended with percent

## 1.2.3
* Add support for Shimmie2-powered boorus
* Fix tags encoding issues
* Fix searching tag that has been blocked resulting in endless loading
* Other small bugfix and improvement on server scanner and parser

## 1.2.2
* Add Indonesian language (Bahasa Indonesia)
* A lot code architectural changes for more maintainable codebase
* Settings: add option to switch language (currently only English and Indonesian)
* Fix crash issues when tyring to update app due to missing permission
* Small UI fixes and improvements

## 1.2.1
* Fix tag suggestion for E621
* Fix settings > server > show original content not saved properly
* Fix metadata parsing issues on konachan and yandere
* Fix broken Gelbooru (XML) parser
* Fix content not properly loaded on Moebooru-based websites


## 1.2.0
* Add support for parsing E621
* Add settings to show original content on post preview
* Update flutter engine to 3.3.7 (actual fix for downloader crashing issues on Android 13)

## 1.1.9
* Fix favorite button color on day mode UI
* Fix video post did not recognized as video on rule34
* Preload previous and next post (only applied to photo post, not video)

## 1.1.8
* Fix flutter engine crashing when downloading files on Android 13

## 1.1.7
* Remove problematic Android 13 notification workaround (for some unknown reason it leads to app crashing on production build)

## 1.1.6
* Add option to disable UI Blur (might helps on low-end devices)
* Add support for Favorite posts
* Add workaround for downloader notification issues on Android 13
* Fix app update version checker
* Fix several UI issues
* Handle API origin redirection when scanning server
* Improve tag suggestion result

## 1.1.5
* Fixup load more button keep trying to load page endlessly

## 1.1.4
* Add support for custom server API address
* Add support for in-app-update
* Fix load-more did not work occasionally especially when post limit is at below 40
* Fix server data editing issues
* Fix several UI inconsistency
* Parse categorized tags for server that supports it (like danbooru)

## 1.1.3
* Revamp several UI elements
* Fix app cannot be closed after using "search tag" or "add tag to current search"
* Fix search history did not sorted properly
* Fix placeholder image did not get de-blurred after clicking show button
* Fix video player state inconsistency issues
* Improve double-back to close consistency

## 1.1.2
* Add option to clear image cache at settings
* Add option to hide downloaded media from gallery at settings
* Add option to set posts limit per load at settings
* Add changelogs viewer at about page
* Auto-load-more content on post viewer
* Downloads: Add option to redownload media when the file is missing
* Fix content loading issues 3dbooru (make sure to clear cache at settings after updating)
* Fix duplicated content issues while parsing api result
* Fix fullscreen restoration issues on Android 9 and below
* Improve search suggestion handling
* Various UI fixes and improvement

## 1.1.1
* Add download dialog and allow for downloading sample image (if exists)
* Add option to group downloaded files by server on Downloads page
* Add Settings option to blur content that rated as explicit
* Add support for Safebooru tag suggestion
  (you may need to reset server at Server -> "Reset to default" to update it)
* Add support for scanning old Danbooru v1.13.0 API (for example: 3dbooru)
* Add support for various booru post details (rating, sample image, resolution, art source)
* Add support to display sample image (lower version of original image) if exist
* Fix pause button can't be used while loading video
* Improve API parser stability
* Improve server scanning methods
* Several UI fixes and improvement
* Show preview image on Downloads page

## 1.1.0
* Add support for Android 13 themed icon
* Add option to edit existing server data
* Allow any server except last to be removed
* Add download progress indicator on Downloads Page
* Add About Page
* App icon update
* Fix all history did not show up on blank input
* Fix downloaded content did not appears on android gallery
* Fix duplicated tags when using append button on search suggestion
* Fix filename display issues on Downloads Page
* Fix retry button did not retry the current page

## 1.0.9
* New feature: Download content directly from the app!
* New UI: Material Design 3 with wallpaper-based color theme for Android 12
* Add more option to manipulate search tags on the floating action button
* Fix parsing Gelbooru API result
* Fix crashing when a server is removed
* Fix video player cannot be muted early
* Fix various UI-related issues
* Improve API transactions stability

## 1.0.8
* Fix clicking URLs did not open external browser
* Fix some minor issues on suggestion, favicon, and custom server scanning.

## 1.0.7
* New feature: Custom booru server
* UI Layout and theming improvement
* Fix deprecated code and update dependencies

## 1.0.6
* Add double back trigger to close app
* Improve search suggestion handling
* Improve video player implementation
* Update several deprecated code and dependencies
* and many other improvement under the hood

## 1.0.5
* Add copy-to-clipboard button to links on the post info page
* Add clear-all button for the search history
* Fix blocked tag list cannot be scrolled
* Fix safe mode for Danbooru
* Muting video volume is now persistent
* New pitch black theme option for the dark mode
* Now you can search the tag directly when selecting the list of tags on the post info page
* Several minor fix and enhancements for the UIs
* Update several deprecated code and dependencies

## 1.0.4
* Add a feature for blocking a particular tags from search result and history
* Several UI Improvement on Search bar (tag suggestion and history) and sidebar
* Now History entries can be removed by swipe it left
* Search suggestion and history entries on-click behaviour are changed, from adding to the search bar to directly search the particular entry.
* However, + button is added because it's really handy for searching multiple tags like before.
* Sidebar now shows the server's web icon instead of basic globe icon

## 1.0.3
* Properly sort search history from latest entry down to the oldest entry
* Fix similar search query are being saved to history (the already saved one are still exists, we have to manually clear it)
* Improve thumbnail quality especially on 2x and 3x grid
* Migrate Tags UI from flutter_tags to simple TextButton
* Update app dependencies

## 1.0.2
* Auto-scroll to the last opened post when go back to home
* Fix Search bar color did not updated when changing theme
* Implement simple update checker based on pubspec.yaml
* Improve Search suggestion behavior
* Make tags safe from being covered by floating action button
* Migrate video player from video_player package to better_player
* Theme switcher can also be persist and has an option to respect system theme
* Beautify drawer menu
* Show displayed source info on the Post Detail (for video post that has zip source)

## 1.0.1
* New Feature: Tag Search History
* Breaking changes: Migrate the settings storage from SharedPreferences to Hivedb.
  any changes on previous version not be preserved (selected server, grid number, safe mode).
* Improved Post tags UI

## 1.0.0
* Initial release
