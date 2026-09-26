import 'dart:io';

import 'package:path/path.dart' as p;

import 'platform_support.dart';

/// Where the app keeps the engine and its data.
/// The engine writes extracted/, build/ and mods/ next to itself, like the repository does.
class AppPaths {
  AppPaths._(this.root);
  final String root;

  static AppPaths resolve() {
    final root = PlatformSupport.appDataRoot();
    Directory(root).createSync(recursive: true);
    return AppPaths._(root);
  }

  String get engineDir => p.join(root, 'engine');
  String get engineExe => p.join(engineDir, 'FFR Vision Studio Engine.exe');
  String get downloads => p.join(root, 'downloads');
  String get icons => p.join(root, 'icons');
  String get settingsFile => p.join(root, 'settings.json');
  String get installedManifest => p.join(root, 'installed.json');
  String get engineData => p.join(engineDir, 'data');
  String get engineSprites => p.join(engineDir, 'data', 'ffbe', 'sprites');
}
