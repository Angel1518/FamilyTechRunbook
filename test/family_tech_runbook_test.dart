import 'package:family_tech_runbook/core/theme/app_theme.dart';
import 'package:family_tech_runbook/features/runbook/controllers/runbook_controller.dart';
import 'package:family_tech_runbook/features/runbook/data/runbook_repository.dart';
import 'package:family_tech_runbook/features/runbook/models/runbook_models.dart';
import 'package:family_tech_runbook/features/runbook/services/runbook_validator.dart';
import 'package:family_tech_runbook/features/runbook/ui/runbooks_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfiNoIsolate;

  test('RunbookValidator detects cycles in procedure branches', () {
    const valid = [
      PasoRunbook(id: 'a', procedureId: 'p', instruction: 'A', yesNextStepId: 'b'),
      PasoRunbook(id: 'b', procedureId: 'p', instruction: 'B', isTerminal: true),
    ];
    expect(RunbookValidator.hasCycle(startStepId: 'a', steps: valid), isFalse);

    const cyclic = [
      PasoRunbook(id: 'a', procedureId: 'p', instruction: 'A', yesNextStepId: 'b'),
      PasoRunbook(id: 'b', procedureId: 'p', instruction: 'B', noNextStepId: 'a'),
    ];
    expect(RunbookValidator.hasCycle(startStepId: 'a', steps: cyclic), isTrue);
  });

  testWidgets('RunbooksScreen renders without overflow at 320px and 200% TextScaler', (tester) async {
    final db = await openDatabase(
      inMemoryDatabasePath,
      version: 1,
      onCreate: RunbookRepository.createSchema,
    );
    final repo = RunbookRepository(testDb: db);

    await tester.binding.setSurfaceSize(const Size(320, 568));
    await tester.pumpWidget(
      ProviderScope(
        overrides: [runbookRepositoryProvider.overrideWithValue(repo)],
        child: MediaQuery(
          data: const MediaQueryData(
            size: Size(320, 568),
            textScaler: TextScaler.linear(2.0),
          ),
          child: MaterialApp(
            theme: AppTheme.light(accent: const Color(0xFF2563EB)),
            home: const RunbooksScreen(),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    await tester.binding.setSurfaceSize(null);
    await db.close();
  });
}

