// Archivo: /lib/modules/finances/tabs/stats_tab.dart

import 'package:flutter/material.dart';
import 'package:ihc_project/providers/finances_provider.dart';
import 'package:provider/provider.dart';

class FinancesStatsTab extends StatelessWidget {
  const FinancesStatsTab({super.key});

  @override
  Widget build(BuildContext context) {
    // El Consumer garantiza que la pantalla se actualice cuando cambie dailyRevenue
    return Consumer<FinancesProvider>(
      builder: (context, financeProvider, child) {
        final revenue = financeProvider.dailyRevenue;
        
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              // --- Resumen General ---
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Text(
                        'Resumen General',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const Divider(height: 20, thickness: 1),
                      
                      const Text('Ingresos del Día', textAlign: TextAlign.center, style: TextStyle(fontSize: 16)),
                      const SizedBox(height: 10),
                      Text(
                        '\$${revenue.toStringAsFixed(2)}',
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 36, fontWeight: FontWeight.bold, color: Colors.green),
                      ),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 50),
              
              // Logo (Simulación del diseño de reloj)
              Image.asset(
                'lib/assets/images/logo2.png',
                height: 120,
                color: const Color(0xFFC62828), 
              ),
            ],
          ),
        );
      },
    );
  }
}