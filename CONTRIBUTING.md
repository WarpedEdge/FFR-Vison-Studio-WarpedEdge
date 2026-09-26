# Contributing

Thanks for looking at the studio. A few things that keep it easy to work on.

## What this repository is

The Windows and Linux app. It downloads the engine (Python + .NET tools packaged as `FFR Vision Studio Engine.exe`) and the game
data packs from the project's hosts on first start, then talks to that engine over localhost. The engine's source lives in
a separate project repository and Linux currently runs that engine through UMU/Proton. The source is not published yet;
until it is, issues about the mod itself (what the game shows)
are welcome here too, marked as engine issues.

## Setup

```
flutter pub get
flutter analyze
flutter test
flutter build windows --release
./tool/build_linux.sh            # immutable-Linux build through Podman
```

Run the built app with these environment variables to keep your real install untouched:

- `LOCALAPPDATA` pointed at a scratch folder (the app keeps everything under `<LOCALAPPDATA>\FFR Vision Studio`)
- `XDG_DATA_HOME` pointed at a scratch folder for a Linux run
- `FFR_STUDIO_HOST` pointed at a local copy of the host tree if you have one (defaults to the live host)

Neither environment variable is required. The live host can require a current numbered app build; use the version flags
documented in `README.md` when testing the hosted engine.

## Design rules

The look is a strategy-guide spread; `DESIGN.md` and `lib/design/DIRECTION.md` describe it. In short:
colours come from `Guide` (both editions), pictures of the game sit in 2 px ink frames, sections open with a colour band, one
red button per screen changes the game, no rounded corners, no gradients, plain copy in the second person.

## Pull requests

- `flutter analyze` clean (infos about deprecated Material members are known), `flutter test` green.
- One change per pull request, with a line in `CHANGELOG.md` under the unreleased build.
- Screenshots for anything visible.
