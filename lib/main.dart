import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/timezone.dart' as tz;

import 'utils/ad_manager.dart';
import 'providers/varlik_provider.dart';
import 'providers/butce_provider.dart';
import 'providers/app_prefs_provider.dart';
import 'utils/notifications.dart';
import 'screens/main_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Yalnızca dikey yön
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  // Türkçe sayı formatı için varsayılan locale
  Intl.defaultLocale = 'tr_TR';

  // Zaman dilimi başlat
  tz.initializeTimeZones();
  try {
    final tzName = await FlutterTimezone.getLocalTimezone();
    tz.setLocalLocation(tz.getLocation(tzName));
  } catch (_) {
    tz.setLocalLocation(tz.getLocation('Europe/Istanbul'));
  }

  // AdMob başlat
  await AdManager.init();

  // Bildirimleri başlat
  await NotificationManager.shared.init();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => VarlikProvider()),
        ChangeNotifierProvider(create: (_) => ButceProvider()),
        ChangeNotifierProvider(create: (_) => AppPrefsProvider()),
      ],
      child: const TasarrufXApp(),
    ),
  );
}

class TasarrufXApp extends StatelessWidget {
  const TasarrufXApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TasarrufX',
      debugShowCheckedModeBanner: false,
      themeMode: ThemeMode.light,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF30D158),
          brightness: Brightness.light,
        ),
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFF2F2F7),
        cardColor: Colors.white,
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: Colors.white,
          selectedItemColor: Color(0xFF30D158),
          unselectedItemColor: Color(0xFF8E8E93),
          type: BottomNavigationBarType.fixed,
          elevation: 0,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFFF2F2F7),
          surfaceTintColor: Colors.transparent,
          elevation: 0,
          scrolledUnderElevation: 0,
          titleTextStyle: TextStyle(
            color: Colors.black,
            fontSize: 17,
            fontWeight: FontWeight.w600,
          ),
          iconTheme: IconThemeData(color: Color(0xFF30D158)),
        ),
        sliderTheme: const SliderThemeData(
          activeTrackColor: Color(0xFF30D158),
          thumbColor: Color(0xFF30D158),
          inactiveTrackColor: Color(0xFFD1D1D6),
        ),
        switchTheme: SwitchThemeData(
          thumbColor: WidgetStateProperty.all(Colors.white),
          trackColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return const Color(0xFF30D158);
            }
            return const Color(0xFFD1D1D6);
          }),
        ),
      ),
      home: const MainScreen(),
    );
  }
}
