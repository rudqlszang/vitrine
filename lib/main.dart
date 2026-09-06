import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'core/strings.dart';
import 'core/theme/app_theme.dart';
import 'data/local/order_box.dart';
import 'data/local/providers.dart';
import 'features/home/home_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      statusBarBrightness: Brightness.light,
    ),
  );

  await Hive.initFlutter();
  final orders = await OrderBox.open();

  runApp(
    ProviderScope(
      overrides: [orderBoxProvider.overrideWithValue(orders)],
      child: const VitrineApp(),
    ),
  );
}

class VitrineApp extends ConsumerStatefulWidget {
  const VitrineApp({super.key});

  @override
  ConsumerState<VitrineApp> createState() => _VitrineAppState();
}

class _VitrineAppState extends ConsumerState<VitrineApp> {
  Timer? _tick;

  @override
  void initState() {
    super.initState();
    // 배송 단계는 경과 시간으로 계산되므로 주기적으로 다시 그리기만 하면 된다.
    _tick = Timer.periodic(
      const Duration(minutes: 1),
      (_) => ref.read(ordersProvider.notifier).refresh(),
    );
  }

  @override
  void dispose() {
    _tick?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: Strings.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.build(),
      home: const HomeScreen(),
    );
  }
}
