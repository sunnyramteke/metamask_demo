import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:metamask_demo/screens/landing_screen.dart';
import 'package:provider/provider.dart';
import 'package:web3modal_flutter/web3modal_flutter.dart';

import 'controllers/theme_provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp])
      .then((value) => runApp(MultiProvider(providers: [
            ChangeNotifierProvider<DarkThemeProvider>(
              create: (_) => DarkThemeProvider()..loadThemePreference(),
            ),
          ], child: const MyApp())));
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  bool _isDarkMode = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      setState(() {
        final platformDispatcher = View.of(context).platformDispatcher;
        final platformBrightness = platformDispatcher.platformBrightness;
        _isDarkMode = platformBrightness == Brightness.dark;
      });
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangePlatformBrightness() {
    if (mounted) {
      setState(() {
        final platformDispatcher = View.of(context).platformDispatcher;
        final platformBrightness = platformDispatcher.platformBrightness;
        _isDarkMode = platformBrightness == Brightness.dark;
      });
    }
    super.didChangePlatformBrightness();
  }

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return Web3ModalTheme(
      isDarkMode: Provider.of<DarkThemeProvider>(context).darkTheme,
      themeData: _themeData,
      child: const MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Metamask Demo',
        home: LandingScreen(),
      ),
    );
  }

  Web3ModalThemeData get _themeData => Web3ModalThemeData(
        lightColors: Web3ModalColors.lightMode.copyWith(
          accent100: const Color.fromARGB(255, 30, 59, 236),
          background100: Color(0xFF2D3CBA),
          // Main Modal's background color
          background125: const Color.fromARGB(255, 214, 227, 255),
          background175: const Color.fromARGB(255, 143, 173, 255),
          inverse100: const Color.fromARGB(255, 233, 237, 236),
          inverse000: const Color.fromARGB(255, 22, 18, 19),
          // Main Modal's text
          foreground100: const Color.fromARGB(255, 22, 18, 19),
          // Secondary Modal's text
          foreground150: const Color.fromARGB(255, 22, 18, 19),
        ),
        darkColors: Web3ModalColors.darkMode.copyWith(
          accent100: const Color.fromARGB(255, 161, 183, 231),
          background100: Color(0xFF0A0E21),
          // Main Modal's background color
          background125: Color(0xFF1D1E33),
          background175: Color(0xFF0A0E21),
          inverse100: const Color.fromARGB(255, 22, 18, 19),
          inverse000: const Color.fromARGB(255, 233, 237, 236),
          // Main Modal's text
          foreground100: const Color.fromARGB(255, 233, 237, 236),
          // Secondary Modal's text
          foreground150: const Color.fromARGB(255, 233, 237, 236),
        ),
        radiuses: Web3ModalRadiuses.circular,
      );
}
