// Archivo: /lib/modules/attendance/attendance_module_screen.dart

import 'package:flutter/material.dart';
import 'package:ihc_project/modules/attendance/tabs/attendance_tab.dart';
import 'package:ihc_project/modules/attendance/tabs/list_tab.dart'; 
import 'package:ihc_project/modules/attendance/tabs/stats_tab.dart';
import 'package:ihc_project/providers/participant_provider.dart';
import 'package:provider/provider.dart';

// Convertimos a StatefulWidget
class AttendanceModuleScreen extends StatefulWidget {
  const AttendanceModuleScreen({super.key});

  @override
  State<AttendanceModuleScreen> createState() => _AttendanceModuleScreenState();
}

// Creamos la clase de estado
class _AttendanceModuleScreenState extends State<AttendanceModuleScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    
    // 1. Añadir el listener al controlador de pestañas
    _tabController.addListener(_handleTabChange);
  }
  
  // 2. Método para manejar el cambio de pestaña
  void _handleTabChange() {
    // Si el usuario deja de arrastrar y se posiciona en una nueva pestaña...
    if (!_tabController.indexIsChanging) {
      // Obtenemos el provider sin escuchar cambios (listen: false) para solo llamar al método
      final participantProvider = Provider.of<ParticipantProvider>(context, listen: false);
      
      // Limpiamos cualquier filtro activo al cambiar de pestaña
      participantProvider.clearSearchQueries();
    }
  }

  @override
  void dispose() {
    _tabController.removeListener(_handleTabChange);
    _tabController.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      // 3. Asignar el controller al TabBar y TabBarView
      child: Scaffold(
        body: NestedScrollView(
          headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
            return <Widget>[
              SliverAppBar(
                title: const Text(
                  'Módulo de Asistencia',
                  style: TextStyle(color: Colors.white),
                ),
                backgroundColor: Colors.red,
                pinned: true,
                floating: true,
                centerTitle: true,
                bottom: TabBar( // Usamos el TabBar sin 'const' porque ahora tiene controller
                  controller: _tabController, // Asignamos el controller
                  indicatorColor: Colors.white,
                  labelColor: Colors.white,
                  unselectedLabelColor: Colors.black,
                  tabs: const [
                    Tab(text: 'Asistencia'),
                    // CAMBIO APLICADO AQUÍ
                    Tab(text: 'Participantes'), 
                    Tab(text: 'Estadísticas'),
                  ],
                ),
                leading: IconButton(
                  icon: const Icon(Icons.home, color: Colors.white),
                  onPressed: () => Navigator.pop(context),
                ),
                actions: [
                  Padding(
                    padding: const EdgeInsets.only(right: 16.0),
                    child: Image.asset(
                      'lib/assets/images/logo.png',
                      height: 32,
                    ),
                  ),
                ],
              ),
            ];
          },
          body: TabBarView( // Usamos TabBarView sin 'const' porque ahora tiene controller
            controller: _tabController, // Asignamos el controller
            children: const [
              AttendanceTab(),
              ListTab(),
              StatsTab(),
            ],
          ),
        ),
      ),
    );
  }
}