import 'package:flutter/material.dart';
import 'features/mapa_tiempo_real/presentation/pages/mapa_tiempo_real_page.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'App con Features',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const MainMenuPage(),
      routes: {MapaTiempoRealPage.routeName: (_) => const MapaTiempoRealPage()},
    );
  }
}

class MainMenuPage extends StatelessWidget {
  const MainMenuPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Menú principal')),
      body: ListView(
        children: [
          ListTile(
            leading: const Icon(Icons.map),
            title: const Text('Mapa en tiempo real'),
            subtitle: const Text('Ver mi ubicación actual y movimiento'),
            onTap: () {
              Navigator.pushNamed(context, MapaTiempoRealPage.routeName);
            },
          ),
          // Aquí luego agregas más features:
          // ListTile( title: Text('Otra Feature'), onTap: ... )
        ],
      ),
    );
  }
}
