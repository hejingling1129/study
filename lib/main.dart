import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_quill/flutter_quill.dart';

import 'app.dart';
import 'app_theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const XingZhuCampusApp());
}

class XingZhuCampusApp extends StatelessWidget {
  const XingZhuCampusApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '星助校园',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.theme,
      localizationsDelegates: const [
        FlutterQuillLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('zh', 'CN'),
        Locale('en'),
      ],
      home: const DefaultTabController(
        length: 4,
        child: MainShell(),
      ),
    );
  }
}
