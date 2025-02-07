import 'package:ffmpeg_kit_flutter/ffmpeg_kit_config.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_gemini/flutter_gemini.dart';
import 'package:flutter_iptv_client/common/logger.dart';
import 'package:flutter_iptv_client/common/shared_preference.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import 'ui/page/home_page.dart';
import 'provider/channel_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  FFmpegKitConfig.enableLogCallback((log) {
    logger.i('ffmpeg: ${log.getMessage()}');
  });
  sharedPreferences = await SharedPreferences.getInstance();
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);
  await dotenv.load();
  Gemini.init(apiKey: dotenv.env['GEMINI_KEY']!);
  MobileAds.instance.initialize();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ChannelProvider()),
      ],
      builder: (context, child) {
        return MaterialApp(
          title: 'IPTV Player',
          themeMode: ThemeMode.dark,
          theme: ThemeData(
            iconButtonTheme: IconButtonThemeData(
              style: ButtonStyle(
                  overlayColor: MaterialStateProperty.all(Colors.grey)
              )
            ),
            filledButtonTheme: FilledButtonThemeData(
              style: ButtonStyle(
                  overlayColor: MaterialStateProperty.all(const Color(0x66000000))
              )
            ),
            colorScheme: ColorScheme.fromSeed(
                seedColor: Colors.deepPurple, brightness: Brightness.dark),
            useMaterial3: true,
          ),
          home: Stack(
            children: [
              const HomePage(),
              Visibility(
                  visible:
                      context.select((ChannelProvider value) => value.loading),
                  child: Container(
                      alignment: Alignment.center,
                      color: Theme.of(context).colorScheme.onSecondaryContainer.withAlpha(100),
                      child: const CircularProgressIndicator()))
            ],
          ),
        );
      },
    );
  }
}
