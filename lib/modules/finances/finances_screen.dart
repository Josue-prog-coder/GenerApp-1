// Archivo: /lib/modules/finances/finances_screen.dart

import 'package:flutter/material.dart';
import 'package:ihc_project/modules/finances/tabs/products_tab.dart';
import 'package:ihc_project/modules/finances/tabs/sales_tab.dart';
import 'package:ihc_project/modules/finances/tabs/stats_tab.dart';

const Color kPrimaryRed = Color(0xFFC62828);

class FinancesScreen extends StatefulWidget {
  const FinancesScreen({super.key});

  @override
  State<FinancesScreen> createState() => _FinancesScreenState();
}

class _FinancesScreenState extends State<FinancesScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        body: NestedScrollView(
          headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
            return <Widget>[
              SliverAppBar(
                title: const Text('Módulo de Finanzas', style: TextStyle(color: Colors.white)),
                backgroundColor: Colors.red,
                pinned: true,
                floating: true,
                centerTitle: true,
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
                      color: Colors.white,
                    ),
                  ),
                ],
                bottom: TabBar(
                  controller: _tabController,
                  indicatorColor: Colors.white,
                  labelColor: Colors.white,
                  unselectedLabelColor: Colors.white70,
                  tabs: const [
                    Tab(text: 'Venta'),
                    Tab(text: 'Productos'),
                    Tab(text: 'Estadísticas'),
                  ],
                ),
              ),
            ];
          },
          body: TabBarView(
            controller: _tabController,
            children: const [
              SalesTab(),      // Pestaña de Punto de Venta
              ProductsTab(),   // Pestaña de Gestión de Productos
              FinancesStatsTab(), // Pestaña de Estadísticas
            ],
          ),
        ),
      ),
    );
  }
}