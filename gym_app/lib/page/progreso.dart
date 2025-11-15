import 'package:flutter/material.dart';
import '../service/tiempo_service.dart';

class ProgresoPage extends StatefulWidget {
  final Map<String, dynamic> userData;
  
  const ProgresoPage({Key? key, required this.userData}) : super(key: key);

  @override
  _ProgresoPageState createState() => _ProgresoPageState();
}

class _ProgresoPageState extends State<ProgresoPage> {
  Map<String, int> _tiempos = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _cargarTiempos();
  }

  Future<void> _cargarTiempos() async {
    try {
      final tiempos = await TiempoService.obtenerTodosLosTiempos(widget.userData['id']);
      setState(() {
        _tiempos = tiempos;
        _isLoading = false;
      });
    } catch (e) {
      print('Error cargando tiempos: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  String _formatTime(int seconds) {
    int hours = seconds ~/ 3600;
    int minutes = (seconds % 3600) ~/ 60;
    int secs = seconds % 60;
    
    if (hours > 0) {
      return '${hours}h ${minutes}m ${secs}s';
    } else if (minutes > 0) {
      return '${minutes}m ${secs}s';
    } else {
      return '${secs}s';
    }
  }

  Widget _buildRutinaCard(String rutina, int segundos) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF0F3460), Color(0xFF16213E)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 10,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            rutina,
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 10),
          Row(
            children: [
              Icon(Icons.timer, color: Colors.blueAccent, size: 20),
              SizedBox(width: 8),
              Text(
                'Tiempo total:',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                ),
              ),
              Spacer(),
              Text(
                _formatTime(segundos),
                style: TextStyle(
                  color: Colors.blueAccent,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          SizedBox(height: 8),
          LinearProgressIndicator(
            value: segundos > 0 ? (segundos / 3600.0).clamp(0.0, 1.0) : 0.0,
            backgroundColor: Colors.white.withOpacity(0.2),
            valueColor: AlwaysStoppedAnimation<Color>(Colors.blueAccent),
          ),
          SizedBox(height: 5),
          Text(
            'Progreso: ${(segundos / 3600.0 * 100).toStringAsFixed(1)}%',
            style: TextStyle(
              color: Colors.white60,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEstadisticas() {
    int totalSegundos = _tiempos.values.fold(0, (sum, segundos) => sum + segundos);
    int rutinasCompletadas = _tiempos.values.where((segundos) => segundos > 0).length;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.green.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Text(
            'Estadísticas Generales',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 15),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatItem(Icons.fitness_center, 'Rutinas', '${rutinasCompletadas}/${_tiempos.length}'),
              _buildStatItem(Icons.timer, 'Tiempo Total', _formatTime(totalSegundos)),
              _buildStatItem(Icons.emoji_events, 'Nivel', _calcularNivel(totalSegundos)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(IconData icon, String title, String value) {
    return Column(
      children: [
        Icon(icon, color: Colors.green, size: 30),
        SizedBox(height: 5),
        Text(
          title,
          style: TextStyle(
            color: Colors.white70,
            fontSize: 12,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            color: Colors.green,
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  String _calcularNivel(int totalSegundos) {
    if (totalSegundos >= 7200) return 'Avanzado';
    if (totalSegundos >= 3600) return 'Intermedio';
    if (totalSegundos >= 1800) return 'Principiante';
    return 'Novato';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 0, 0, 74),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Mi Progreso',
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
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.blueAccent),
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Resumen de estadísticas
                  _buildEstadisticas(),

                  const SizedBox(height: 25),

                  const Text(
                    'Progreso por Rutina',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 15),

                  
                  ..._tiempos.entries.map((entry) => 
                    _buildRutinaCard(entry.key, entry.value)
                  ).toList(),

                  const SizedBox(height: 20),

               
                ],
              ),
            ),
    );
  }
}