import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rtf_view/constants/theme.dart';
import 'package:rtf_view/screens/splash_screen.dart';
import 'package:rtf_view/services/rtf_provider.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [ChangeNotifierProvider(create: (_) => RtfProvider())],
      child: MaterialApp(
        title: 'RTF Viewer',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        home: const SplashScreen(),
      ),
    );
  }
}
