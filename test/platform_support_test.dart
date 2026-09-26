import 'dart:io';

import 'package:ffr_vision_studio/services/platform_support.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Linux paths cross the Windows engine boundary through the Z drive', () {
    const linuxPath = '/var/home/me/Game Files/FFRS';
    if (Platform.isLinux) {
      expect(
        PlatformSupport.toEnginePath(linuxPath),
        r'Z:\var\home\me\Game Files\FFRS',
      );
      expect(
        PlatformSupport.fromEnginePath(r'Z:\var\home\me\Game Files\FFRS'),
        linuxPath,
      );
    } else {
      expect(PlatformSupport.toEnginePath(linuxPath), linuxPath);
      expect(
        PlatformSupport.fromEnginePath(r'Z:\var\home\me\Game Files\FFRS'),
        r'Z:\var\home\me\Game Files\FFRS',
      );
    }
  });

  test('Linux app data follows XDG_DATA_HOME', () {
    if (!Platform.isLinux) return;
    expect(
      PlatformSupport.appDataRoot(
        environment: const {'HOME': '/home/me', 'XDG_DATA_HOME': '/data'},
      ),
      '/data/ffr-vision-studio',
    );
    expect(
      PlatformSupport.appDataRoot(environment: const {'HOME': '/home/me'}),
      '/home/me/.local/share/ffr-vision-studio',
    );
  });

  test('Linux launches the packaged engine through a private UMU prefix', () {
    if (!Platform.isLinux) return;
    final launch = PlatformSupport.engineLaunch(
      '/data/ffr/engine/Engine.exe',
      '/data/ffr/logs',
    );
    expect(launch.command, 'umu-run');
    expect(launch.arguments, ['/data/ffr/engine/Engine.exe', '--engine']);
    expect(launch.environment['FFR_LOG_DIR'], r'Z:\data\ffr\logs');
    expect(launch.environment['WINEPREFIX'], '/data/ffr/proton-prefix');
  });
}
