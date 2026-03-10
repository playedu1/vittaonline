import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vittaonline/config/theme.dart';
import 'package:vittaonline/router/app_router.dart';

class VittaOnlineApp extends ConsumerWidget {
  const VittaOnlineApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouter);

    return MaterialApp.router(
      title: 'VittaOnline',
      theme: VittaOnlineTheme.lightTheme,
      routerConfig: router,
      debugShowCheckedModeBanner: false,
    );
  }
}
