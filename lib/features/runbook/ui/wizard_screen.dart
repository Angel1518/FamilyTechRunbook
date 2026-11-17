import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../../core/theme/app_theme.dart';
import '../controllers/runbook_controller.dart';
import '../models/runbook_models.dart';
import '../services/runbook_validator.dart';

class WizardScreen extends ConsumerStatefulWidget {
  const WizardScreen({super.key, required this.procedureId});
  final String procedureId;

  @override
  ConsumerState<WizardScreen> createState() => _WizardScreenState();
}

class _WizardScreenState extends ConsumerState<WizardScreen> {
  String? _currentStepId;
  final List<String> _history = [];

  Future<void> _exportPdf(
    Dispositivo dev,
    Procedimiento proc,
    List<PasoRunbook> steps,
    List<Contacto> contacts,
  ) async {
    try {
      final dir = await getTemporaryDirectory();
      final file = File(p.join(dir.path, 'guia_${proc.id}.pdf'));
      await file.writeAsBytes(await RunbookValidator.buildPrintablePdf(
        device: dev,
        proc: proc,
        steps: steps,
        contacts: contacts,
      ));
      await Share.shareXFiles([XFile(file.path)], subject: proc.title);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Error al exportar: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final asyncState = ref.watch(runbookControllerProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Asistente paso a paso')),
      body: asyncState.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Error: $err')),
        data: (data) {
          final proc = data.procedures
              .where((p) => p.id == widget.procedureId)
              .firstOrNull;
          if (proc == null) {
            return const Center(child: Text('Guía no encontrada.'));
          }
          final steps =
              data.steps.where((s) => s.procedureId == proc.id).toList();
          final stepId = _currentStepId ?? proc.firstStepId;
          final step = steps.where((s) => s.id == stepId).firstOrNull;
          final dev = data.devices
                  .where((d) => d.id == proc.deviceId)
                  .firstOrNull ??
              const Dispositivo(id: 'd', name: 'Dispositivo');

          return Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(proc.title, style: theme.textTheme.titleLarge),
                const SizedBox(height: 16),
                Expanded(
                  child: AnimatedSwitcher(
                    duration: AppMotion.duration(
                        context, const Duration(milliseconds: 220)),
                    child: step == null
                        ? const Center(child: Text('Paso no encontrado.'))
                        : Card(
                            key: ValueKey(step.id),
                            child: Padding(
                              padding: const EdgeInsets.all(20),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  Text(
                                    step.instruction,
                                    style: theme.textTheme.headlineSmall,
                                    textAlign: TextAlign.center,
                                  ),
                                  const SizedBox(height: 24),
                                  if (!step.isTerminal) ...[
                                    if (step.yesNextStepId != null)
                                      FilledButton(
                                        onPressed: () => setState(() {
                                          _history.add(step.id);
                                          _currentStepId = step.yesNextStepId;
                                        }),
                                        child: const Text('Sí'),
                                      ),
                                    const SizedBox(height: 10),
                                    if (step.noNextStepId != null)
                                      OutlinedButton(
                                        onPressed: () => setState(() {
                                          _history.add(step.id);
                                          _currentStepId = step.noNextStepId;
                                        }),
                                        child: const Text('No'),
                                      ),
                                  ] else
                                    FilledButton.icon(
                                      onPressed: () => setState(() {
                                        _history.clear();
                                        _currentStepId = proc.firstStepId;
                                      }),
                                      icon: const Icon(Icons.replay),
                                      label: const Text('Empezar de nuevo'),
                                    ),
                                ],
                              ),
                            ),
                          ),
                  ),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 10,
                  runSpacing: 8,
                  alignment: WrapAlignment.spaceBetween,
                  children: [
                    if (_history.isNotEmpty)
                      TextButton.icon(
                        onPressed: () => setState(() {
                          _currentStepId = _history.removeLast();
                        }),
                        icon: const Icon(Icons.arrow_back),
                        label: const Text('Paso anterior'),
                      ),
                    OutlinedButton.icon(
                      onPressed: () =>
                          _exportPdf(dev, proc, steps, data.contacts),
                      icon: const Icon(Icons.picture_as_pdf_outlined),
                      label: const Text('Imprimir / PDF'),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

