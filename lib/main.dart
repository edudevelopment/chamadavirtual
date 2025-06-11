import 'package:chamadavirtual/pages/turmas_page.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'themes/theme.dart';
import 'pages/home_page.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => TurmasProvider()),
      ],
      child: MaterialApp(
        title: 'Chamada Escolar',
        theme: darkTheme,
        themeMode: ThemeMode.system,
        home: const HomePage(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}