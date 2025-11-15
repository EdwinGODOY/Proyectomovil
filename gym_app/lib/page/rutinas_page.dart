import 'package:flutter/material.dart';
import 'package:gym_app/page/rutina_detalle.dart';


class RutinasPage extends StatelessWidget {
  final Map<String, dynamic> userData;
  
  const RutinasPage({Key? key, required this.userData}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 0, 0, 74),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Mis Rutinas',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
          
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF0F3460), Color(0xFF16213E)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(15),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Tus Rutinas de Entrenamiento',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Elige una rutina para comenzar, ${userData['nombre']}',
                    style: const TextStyle(
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 25),
            
          
            const Text(
              'Rutinas Disponibles',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 15),
            
            _buildRutinaCard(
              context,
              'Rutina Fuerza Básica',
              'Perfecta para principiantes. Enfocada en ganar fuerza fundamental.',
             
              Colors.blueAccent,
              Icons.fitness_center,
            ),
            
            const SizedBox(height: 15),
            
            _buildRutinaCard(
              context,
              'Rutina Volumen Muscular',
              'Aumenta tu masa muscular con ejercicios compuestos.',
              
              Colors.greenAccent,
              Icons.trending_up,
            ),
            
            const SizedBox(height: 15),
            
            _buildRutinaCard(
              context,
              'Rutina Quema Grasa',
              'Cardio y entrenamiento de alta intensidad para definir.',
              
              Colors.orangeAccent,
              Icons.fireplace,
            ),
            
            const SizedBox(height: 15),
            
            _buildRutinaCard(
              context,
              'Rutina Fuerza Avanzada',
              'Para atletas experimentados. Enfocada en fuerza máxima.',
              
              Colors.purpleAccent,
              Icons.emoji_events,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRutinaCard(
    BuildContext context,
    String titulo,
    String descripcion,
     Color color,
    IconData icon,
  ) {
    return GestureDetector(
      onTap: () {
        
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => RutinaDetallePage(
              rutina: {
                'nombre': titulo,
                'descripcion': descripcion,
                
              },
              userData: userData,
            ),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Row(
          children: [
          
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            
            const SizedBox(width: 15),
            
          
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    titulo,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    descripcion,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 12,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                
                ],
              ),
            ),
            
         
            const Icon(Icons.arrow_forward_ios, color: Colors.white54, size: 16),
          ],
        ),
      ),
    );
  }

 
}