import 'dart:io';

import 'package:path/path.dart' as p;

class EngineLaunch {
  const EngineLaunch(this.command, this.arguments, this.environment);

  final String command;
  final List<String> arguments;
  final Map<String, String> environment;
}

/// Small platform differences around the unchanged Windows engine.
class PlatformSupport {
  static String appDataRoot({
    Map<String, String>? environment,
    String? currentDirectory,
  }) {
    final env = environment ?? Platform.environment;
    final current = currentDirectory ?? Directory.current.path;
    if (Platform.isLinux) {
      final home = env['HOME'] ?? current;
      return p.join(
        env['XDG_DATA_HOME'] ?? p.join(home, '.local', 'share'),
        'ffr-vision-studio',
      );
    }
    final base =
        env['LOCALAPPDATA'] ?? env['APPDATA'] ?? env['USERPROFILE'] ?? current;
    return p.join(base, 'FFR Vision Studio');
  }

  static String toEnginePath(String path) {
    if (!Platform.isLinux || !p.isAbsolute(path)) return path;
    return 'Z:${path.replaceAll('/', r'\')}';
  }

  static String fromEnginePath(String path) {
    if (!Platform.isLinux ||
        !RegExp(r'^Z:\\', caseSensitive: false).hasMatch(path)) {
      return path;
    }
    return '/${path.substring(3).replaceAll(r'\', '/')}';
  }

  static EngineLaunch engineLaunch(String exePath, String? logDir) {
    if (!Platform.isLinux) {
      final environment = <String, String>{};
      if (logDir != null) environment['FFR_LOG_DIR'] = logDir;
      return EngineLaunch(exePath, const ['--engine'], environment);
    }
    return EngineLaunch(
      'umu-run',
      [exePath, '--engine'],
      {
        if (logDir != null) 'FFR_LOG_DIR': toEnginePath(logDir),
        'GAMEID': 'umu-ffr-vision-studio',
        'WINEPREFIX': p.join(File(exePath).parent.parent.path, 'proton-prefix'),
      },
    );
  }

  static List<String> linuxSteamLibraries() {
    final home = Platform.environment['HOME'];
    if (home == null) return const [];
    final roots = [
      p.join(home, '.local', 'share', 'Steam'),
      p.join(home, '.steam', 'steam'),
      p.join(
        home,
        '.var',
        'app',
        'com.valvesoftware.Steam',
        '.local',
        'share',
        'Steam',
      ),
    ];
    final out = <String>[];
    for (final root in roots) {
      if (!Directory(root).existsSync()) continue;
      if (!out.contains(root)) out.add(root);
      final vdf = File(p.join(root, 'steamapps', 'libraryfolders.vdf'));
      if (!vdf.existsSync()) continue;
      for (final line in vdf.readAsLinesSync()) {
        final match = RegExp(r'^\s*"path"\s+"(.*)"\s*$').firstMatch(line);
        if (match == null) continue;
        final path = p.normalize(match.group(1)!.replaceAll(r'\\', r'\'));
        if (Directory(path).existsSync() && !out.contains(path)) out.add(path);
      }
    }
    return out;
  }
}
