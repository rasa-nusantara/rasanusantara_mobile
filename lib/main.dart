import 'package:flutter/material.dart';
import 'package:rasanusantara_mobile/favorite/favorite_provider.dart';
import 'package:rasanusantara_mobile/home.dart';
import 'package:rasanusantara_mobile/navbar.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';
import 'package:rasanusantara_mobile/authentication/screens/login.dart';
import 'package:rasanusantara_mobile/admin/navigation_provider.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => NavigationProvider()),
        Provider<CookieRequest>(
          create: (_) => CookieRequest(),
        ),
        ChangeNotifierProvider(
          create: (_) => FavoriteProvider(),
        ),
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
      title: 'Rasa Nusantara',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSwatch(
          primarySwatch: Colors.brown,
        ).copyWith(secondary: Colors.brown[900]),
        useMaterial3: true,
      ),
      debugShowCheckedModeBanner: false,
      initialRoute: '/', // Rute awal
      routes: {
        '/': (context) => const Navbar(), // Rute homepage utama
        '/login': (context) => const LoginPage(), // Rute ke halaman login
      },
    );
  }
}
