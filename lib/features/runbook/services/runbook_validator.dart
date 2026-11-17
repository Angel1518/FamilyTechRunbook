import 'dart:typed_data';

import 'package:pdf/widgets.dart' as pw;

import '../models/runbook_models.dart';

class RunbookValidator {
  /// Returns true if the directed step graph contains any cycle.
  static bool hasCycle({
    required String startStepId,
    required List<PasoRunbook> steps,
  }) {
    final map = {for (final s in steps) s.id: s};
    final visiting = <String>{};
    final visited = <String>{};

    bool dfs(String? id) {
      if (id == null || !map.containsKey(id)) return false;
      if (visiting.contains(id)) return true;
      if (visited.contains(id)) return false;

      visiting.add(id);
      final node = map[id]!;
      if (dfs(node.yesNextStepId) || dfs(node.noNextStepId)) return true;
      visiting.remove(id);
      visited.add(id);
      return false;
    }

    return dfs(startStepId);
  }

  static Future<Uint8List> buildPrintablePdf({
    required Dispositivo device,
    required Procedimiento proc,
    required List<PasoRunbook> steps,
    required List<Contacto> contacts,
  }) async {
    final doc = pw.Document();
    doc.addPage(
      pw.MultiPage(
        build: (ctx) => [
          pw.Header(
            level: 0,
            child: pw.Text(
              'Guía rápida: ${device.name} — ${proc.title}',
              style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold),
            ),
          ),
          ...steps.asMap().entries.map(
                (e) => pw.Paragraph(
                  text: '${e.key + 1}. ${e.value.instruction}',
                ),
              ),
          if (contacts.isNotEmpty) ...[
            pw.SizedBox(height: 12),
            pw.Header(level: 1, child: pw.Text('A quién llamar si sigue fallando')),
            ...contacts.map((c) => pw.Text('${c.name} (${c.role}): ${c.phone}')),
          ],
        ],
      ),
    );
    return doc.save();
  }
}

