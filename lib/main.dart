import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart'; // <-- Nuevo Import para Firebase
import 'package:provider/provider.dart';

// Providers
import 'package:ihc_project/providers/participant_provider.dart';
import 'package:ihc_project/providers/attendance_provider.dart';
import 'package:ihc_project/providers/logistics_provider.dart'; 
import 'package:ihc_project/providers/auth_provider.dart'; 
import 'package:ihc_project/providers/materials_provider.dart'; 
import 'package:ihc_project/providers/finances_provider.dart'; 

// Screens
import 'package:ihc_project/modules/authentication/login_screen.dart'; 
import 'package:ihc_project/modules/home/home_menu_screen.dart'; // <-- Asegúrate de tener este import

void main() async {
  // 1. Aseguramos la inicialización de los widgets antes de llamar a Firebase
  WidgetsFlutterBinding.ensureInitialized();
  
  // 2. Inicializamos Firebase
  await Firebase.initializeApp();

  runApp(
    MultiProvider( 
      providers: [
        ChangeNotifierProvider(create: (context) => ParticipantProvider()),
        ChangeNotifierProvider(create: (context) => AttendanceProvider()),
        ChangeNotifierProvider(create: (context) => AuthProvider()),      
        ChangeNotifierProvider(create: (context) => LogisticsProvider()), 
        ChangeNotifierProvider(create: (context) => MaterialsProvider()), 
        ChangeNotifierProvider(create: (context) => FinancesProvider()), 
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
      // 3. El Home reacciona al estado del AuthProvider
      home: Consumer<AuthProvider>(
        builder: (context, auth, _) {
          if (auth.isAuthenticated) {
            return const HomeMenuScreen();
          } else {
            return const LoginScreen();
          }
        },
      ),
    );
  }
}