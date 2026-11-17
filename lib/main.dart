import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app/app_router.dart';
import 'core/theme/app_theme.dart';
import 'features/runbook/ui/settings_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const ProviderScope(child: FamilyTechRunbookApp()));
}

class FamilyTechRunbookApp extends ConsumerWidget {
  const FamilyTechRunbookApp({super.key});

  static const Color accentBlue = Color(0xFF2563EB);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);
    return MaterialApp.router(
      title: 'FamilyTech Runbook',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(accent: accentBlue),
      darkTheme: AppTheme.dark(accent: accentBlue),
      themeMode: themeMode,
      routerConfig: appRouter,
    );
  }
}
