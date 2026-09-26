import 'dart:io';

import 'package:ffr_vision_studio/design/anim_viewer.dart';
import 'package:ffr_vision_studio/design/theme.dart';
import 'package:ffr_vision_studio/screens/add_unit_dialog.dart';
import 'package:ffr_vision_studio/services/api.dart';
import 'package:ffr_vision_studio/state/app_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

class PickerApi extends Api {
  PickerApi() : super('http://unused');

  @override
  Future<Map<String, dynamic>> ffbeUnit(String id) async => {
    'name': '9S',
    'forms': {
      '310000206': {'rarity': 6, 'shift': null, 'sprites': <String>[]},
    },
    'ffrStats': <String, dynamic>{},
  };
}

class PickerState extends ChangeNotifier implements AppState {
  @override
  Api? api = PickerApi();

  @override
  JsonMap? hostIndex = {
    'units': [
      {
        'id': '310000204',
        'name': '9S',
        'packs': ['310000206'],
        'iconForm': '310000206',
        'hasSprites': true,
        'rarity_min': 4,
        'rarity_max': 6,
        'roles': ['Breaker'],
      },
    ],
  };

  @override
  List<dynamic> units = [];

  @override
  Future<void> ensureSprites(
    String form, {
    void Function(String)? onStep,
  }) async {}

  @override
  Future<List<String>> animsFor(String form) async => ['idle', 'atk'];

  @override
  File iconFile(String form) => File('/file-that-does-not-exist/$form.png');

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  testWidgets('new units preview animations from the animation endpoint', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1300, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final app = PickerState();
    addTearDown(app.dispose);

    await tester.pumpWidget(
      ChangeNotifierProvider<AppState>.value(
        value: app,
        child: MaterialApp(
          theme: Guide.theme(),
          home: const Scaffold(body: AddUnitDialog()),
        ),
      ),
    );
    await tester.tap(find.text('9S'));
    await tester.pumpAndSettle();

    expect(tester.widget<AnimViewer>(find.byType(AnimViewer)).anims, [
      'idle',
      'atk',
    ]);
    expect(find.text('Idle  1/2'), findsOneWidget);
    expect(find.text('No animations for this look.'), findsNothing);
  });
}
