import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_theme.dart';
import '../controllers/runbook_controller.dart';

class RunbooksScreen extends ConsumerWidget {
  const RunbooksScreen({super.key});

  Future<void> _addContactDialog(BuildContext context, WidgetRef ref) async {
    final nameCtrl = TextEditingController();
    final roleCtrl = TextEditingController(text: 'Soporte familiar');
    final phoneCtrl = TextEditingController();
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Nuevo contacto de ayuda'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
                controller: nameCtrl,
                decoration: const InputDecoration(labelText: 'Nombre')),
            const SizedBox(height: 10),
            TextField(
                controller: roleCtrl,
                decoration: const InputDecoration(labelText: 'Rol / Qué cubre')),
            const SizedBox(height: 10),
            TextField(
                controller: phoneCtrl,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(labelText: 'Teléfono')),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.of(ctx).pop(false),
              child: const Text('Cancelar')),
          FilledButton(
              onPressed: () => Navigator.of(ctx).pop(true),
              child: const Text('Guardar')),
        ],
      ),
    );
    if (ok == true && nameCtrl.text.trim().isNotEmpty) {
      await ref.read(runbookControllerProvider.notifier).addContact(
            name: nameCtrl.text,
            role: roleCtrl.text,
            phone: phoneCtrl.text,
          );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncState = ref.watch(runbookControllerProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('FamilyTech Runbook')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _addContactDialog(context, ref),
        icon: const Icon(Icons.contact_phone_outlined),
        label: const Text('Contacto'),
      ),
      body: asyncState.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Error: $err')),
        data: (data) => ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 92),
          children: [
            Text('Si algo falla, empieza aquí', style: theme.textTheme.bodyMedium),
            const SizedBox(height: 16),
            Text('Guías rápidas', style: theme.textTheme.titleMedium),
            const SizedBox(height: 8),
            ...data.procedures.asMap().entries.map((entry) {
              final i = entry.key;
              final proc = entry.value;
              final dev = data.devices
                  .where((d) => d.id == proc.deviceId)
                  .firstOrNull;
              return Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: TweenAnimationBuilder<double>(
                  duration: AppMotion.duration(
                      context, Duration(milliseconds: 180 + (i * 40))),
                  curve: AppMotion.curve(context),
                  tween: Tween(begin: 0, end: 1),
                  builder: (ctx, t, child) => Opacity(
                    opacity: t,
                    child: Transform.translate(
                      offset: Offset(0, 10 * (1 - t)),
                      child: child,
                    ),
                  ),
                  child: Card(
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor:
                            theme.colorScheme.primary.withValues(alpha: 0.12),
                        child: Icon(Icons.play_arrow_rounded,
                            color: theme.colorScheme.primary),
                      ),
                      title: Text(proc.title,
                          maxLines: 2, overflow: TextOverflow.ellipsis),
                      subtitle: Text(dev?.name ?? 'Dispositivo'),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () => context.push('/wizard/${proc.id}'),
                    ),
                  ),
                ),
              );
            }),
            if (data.contacts.isNotEmpty) ...[
              const SizedBox(height: 16),
              Text('Contactos de ayuda', style: theme.textTheme.titleMedium),
              const SizedBox(height: 8),
              ...data.contacts.map((c) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Card(
                      child: ListTile(
                        leading: const Icon(Icons.phone_outlined),
                        title: Text(c.name),
                        subtitle: Text('${c.role} · ${c.phone}'),
                      ),
                    ),
                  )),
            ],
          ],
        ),
      ),
    );
  }
}

