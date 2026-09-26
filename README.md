# FFR Vision Studio

The native Windows and Linux front of the studio: a Flutter desktop app that downloads and supervises the Python/.NET engine
(`FFR Vision Studio Engine.exe`, fetched from the project's host on first start) and drives its Easy mode natively.
This repository is the app on its own: it needs nothing else on disk to build, and at runtime it talks only to the
engine over localhost and to the host over HTTPS. Design: `DESIGN.md` and `lib/design/DIRECTION.md`. The engine's
source, the pack builder and the project notes live in a separate project repository, which is not published yet.

## Build

```
flutter pub get
flutter analyze
flutter test
flutter build windows --release            # a developer build (version 1.0.0, build 0)
```

### Linux on Bazzite and other immutable systems

Flutter is required to compile the app, but not to run the compiled bundle. `uv` cannot replace it because Flutter ships
the Dart compiler, desktop engine, and build tooling together. The repository includes a Podman build so Flutter, Clang,
CMake, Ninja, and GTK development files do not need to be installed on the host:

```sh
./tool/build_linux.sh
./build/linux/x64/release/bundle/ffr_vision_studio
```

For a build that can use the current hosted engine, stamp it with the release build number just like the Windows build:

```sh
./tool/build_linux.sh --build-name 1.0.0 --build-number <n> \
  --dart-define=APP_VERSION=1.0.0 --dart-define=APP_BUILD=<n>
```

The current number is the `build` value in `https://ffbe.luminest.io/manifest.json`. An unstamped build still compiles and
opens, but it refuses a hosted engine whose `minApp` is newer than build 0.

The build command creates a reusable container image, so its first run downloads the Flutter SDK and takes longer. The
output is the normal relocatable Flutter bundle; keep its executable, `lib/`, and `data/` together.

The engine is still published only as a Windows executable. On Linux the app runs it through `umu-run` in a private Proton
prefix under `$XDG_DATA_HOME/ffr-vision-studio` (normally `~/.local/share/ffr-vision-studio`). Bazzite includes UMU. On
another distribution, install `umu-run` before starting the app. Steam game folders are detected from native and Flatpak
Steam libraries and translated to Proton paths only when the app calls the engine.

A developer build is enough to work on the app: it talks to the live host exactly like a release does. A numbered
build stamps the version into the exe and into the app's own version check:

```
flutter build windows --release --build-name 1.0.0 --build-number <n> \
  --dart-define=APP_VERSION=1.0.0 --dart-define=APP_BUILD=<n>
```

`.github/workflows/windows.yml` runs analyze, test and that build on every push (build 0) and attaches the Release
folder as an artifact; a numbered build is a manual run ("Run workflow" with the build number). The zips people
download are assembled by the packaging run in the project repository, which passes the same flags and ships the
exe next to the engine and the data packs.

## Layout

- `lib/main.dart` window, single-instance lock, header, engine-down banner
- `lib/state/app_state.dart` boot (downloads, offline start, update notice), engine supervision, units, build, restore
- `lib/services/` engine process, downloader (resume + checksum), engine API client, game folder detection, paths
- `lib/design/` the guide's tokens (`Guide`, day and night editions), parts, wordmark, motion viewer, choice
- `lib/screens/` setup, home (spread), unit page and its four steps, add-unit, copy-a-vision, about, build status
- `windows/runner/Runner.rc` exe metadata; `windows/runner/resources/app_icon.ico` Rain's face

## Developing without touching your real install

Start the Windows exe with `LOCALAPPDATA` pointed at a scratch folder, or the Linux bundle with `XDG_DATA_HOME` pointed at
a scratch folder. The app keeps everything below that location. `FFR_STUDIO_HOST` points it at another host tree (a local copy served on
127.0.0.1, for instance); it defaults to the live host, which is all a developer build needs.

## Files

`CHANGELOG.md` (by build), `LICENSE` (MIT for the code; the game's art and data are Square Enix's and excluded),
`CONTRIBUTING.md`, `.github/workflows/windows.yml`, and `.github/workflows/linux.yml` (analyze, test, build, artifact).
