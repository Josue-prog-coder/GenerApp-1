import 'package:flutter/material.dart';
import 'package:ihc_project/providers/participant_provider.dart';
import 'package:ihc_project/providers/attendance_provider.dart';
import 'package:ihc_project/providers/logistics_provider.dart'; // <-- Nuevo Import
import 'package:ihc_project/providers/auth_provider.dart'; // <-- Nuevo Import
import 'package:ihc_project/modules/authentication/login_screen.dart'; // Asegúrate de tener este import
import 'package:provider/provider.dart';

void main() {
  runApp(
    MultiProvider( // Usamos MultiProvider para envolver la app con varios providers
      providers: [
        ChangeNotifierProvider(create: (context) => ParticipantProvider()),
        ChangeNotifierProvider(create: (context) => AttendanceProvider()),
        ChangeNotifierProvider(create: (context) => AuthProvider()),      // <-- Añadido AuthProvider
        ChangeNotifierProvider(create: (context) => LogisticsProvider()), // <-- Nuevo Provider de Logística
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'GenerApp',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.red,
        colorScheme: ColorScheme.fromSwatch(
          primarySwatch: Colors.red,
          accentColor: Colors.redAccent,
        ),
      ),
      // El Home debe ser el Login (o el menú, si estamos probando sin login)
      home: const LoginScreen(),
    );
  }
}