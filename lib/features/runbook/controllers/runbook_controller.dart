import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/runbook_repository.dart';
import '../models/runbook_models.dart';

final runbookRepositoryProvider = Provider<RunbookRepository>(
  (ref) => RunbookRepository(),
);

class RunbookState {
  const RunbookState({
    this.devices = const [],
    this.procedures = const [],
    this.steps = const [],
    this.contacts = const [],
  });

  final List<Dispositivo> devices;
  final List<Procedimiento> procedures;
  final List<PasoRunbook> steps;
  final List<Contacto> contacts;
}

class RunbookController extends AsyncNotifier<RunbookState> {
  @override
  Future<RunbookState> build() async => _loadAll();

  RunbookRepository get _repo => ref.read(runbookRepositoryProvider);

  Future<RunbookState> _loadAll() async => RunbookState(
        devices: await _repo.listDevices(),
        procedures: await _repo.listProcedures(),
        steps: await _repo.listSteps(),
        contacts: await _repo.listContacts(),
      );

  Future<void> addContact({
    required String name,
    required String role,
    required String phone,
  }) async {
    await _repo.upsertContact(
      Contacto(
        id: 'con_${DateTime.now().microsecondsSinceEpoch}',
        name: name.trim(),
        role: role.trim(),
        phone: phone.trim(),
      ),
    );
    state = AsyncData(await _loadAll());
  }
}

final runbookControllerProvider =
    AsyncNotifierProvider<RunbookController, RunbookState>(
  RunbookController.new,
);

