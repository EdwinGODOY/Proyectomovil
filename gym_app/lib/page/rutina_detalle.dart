import 'package:flutter/material.dart';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../video/video_pyayer.dart'; 

class RutinaDetallePage extends StatefulWidget {
  final Map<String, dynamic> rutina;
  final Map<String, dynamic> userData;
  
  const RutinaDetallePage({
    Key? key,
    required this.rutina,
    required this.userData,
  }) : super(key: key);

  @override
  _RutinaDetallePageState createState() => _RutinaDetallePageState();
}

class _RutinaDetallePageState extends State<RutinaDetallePage> {
  Timer? _timer;
  int _seconds = 0;
  bool _isRunning = false;
  int _currentExerciseIndex = 0;
  bool _workoutStarted = false;

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        _seconds++;
      });
    });
    setState(() {
      _isRunning = true;
    });
  }

  void _pauseTimer() {
    _timer?.cancel();
    setState(() {
      _isRunning = false;
    });
  }

  void _resetTimer() {
    _timer?.cancel();
    setState(() {
      _seconds = 0;
      _isRunning = false;
      _currentExerciseIndex = 0;
      _workoutStarted = false;
    });
  }

  void _startWorkout() {
    setState(() {
      _workoutStarted = true;
      _seconds = 0;
      _currentExerciseIndex = 0;
    });
    _startTimer();
  }

  void _nextExercise() {
    setState(() {
      if (_currentExerciseIndex < _obtenerEjerciciosPorRutina(widget.rutina['nombre']).length - 1) {
        _currentExerciseIndex++;
      } else {
        _pauseTimer();
        _guardarTiempoEnBaseDeDatos();
        _showWorkoutCompletedDialog();
      }
    });
  }

  void _previousExercise() {
    setState(() {
      if (_currentExerciseIndex > 0) {
        _currentExerciseIndex--;
      }
    });
  }

  // Función para guardar el tiempo en la base de datos
  Future<void> _guardarTiempoEnBaseDeDatos() async {
    try {
      final url = Uri.parse('http://10.0.2.2:5238/api/Tiempo');
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'usuarioId': widget.userData['id'], 
          'rutina': widget.rutina['nombre'],
          'segundos': _seconds,
        }),
      );

      final data = jsonDecode(response.body);
      if (data['success']) {
        print('Tiempo guardado correctamente: ${_formatTime(_seconds)}');
      } else {
        print('Error al guardar tiempo: ${data['error']}');
      }
    } catch (e) {
      print('Error de conexión al guardar tiempo: $e');
    }
  }

  void _showWorkoutCompletedDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Color(0xFF1A1A2E),
        title: Text(
          '¡Entrenamiento Completado!',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        content: Text(
          'Has completado la rutina ${widget.rutina['nombre']} en ${_formatTime(_seconds)}.\n\nEl tiempo ha sido guardado en tu historial.',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _resetTimer();
            },
            child: Text('Cerrar', style: TextStyle(color: Colors.blueAccent)),
          ),
        ],
      ),
    );
  }

  String _formatTime(int seconds) {
    int hours = seconds ~/ 3600;
    int minutes = (seconds % 3600) ~/ 60;
    int secs = seconds % 60;
    
    return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    List<Map<String, dynamic>> ejercicios = _obtenerEjerciciosPorRutina(widget.rutina['nombre']);

    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 0, 0, 74),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          widget.rutina['nombre'],
          style: const TextStyle(
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
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // aqui en cronometro 
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(15),
                border: Border.all(color: Colors.blueAccent.withOpacity(0.3)),
              ),
              child: Column(
                children: [
                  Text(
                    'Cronómetro',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 15),
                  
                  // Display del tiempo
                  Container(
                    padding: EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.blueAccent),
                    ),
                    child: Text(
                      _formatTime(_seconds),
                      style: TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                        color: Colors.blueAccent,
                        fontFamily: 'monospace',
                      ),
                    ),
                  ),
                  
                  SizedBox(height: 20),
                  
                  
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (!_workoutStarted)
                        ElevatedButton(
                          onPressed: _startWorkout,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            padding: EdgeInsets.symmetric(horizontal: 25, vertical: 12),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.play_arrow, color: Colors.white),
                              SizedBox(width: 8),
                              Text('Iniciar Rutina', style: TextStyle(color: Colors.white)),
                            ],
                          ),
                        )
                      else ...[
                        if (!_isRunning)
                          ElevatedButton(
                            onPressed: _startTimer,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                              padding: EdgeInsets.symmetric(horizontal: 25, vertical: 12),
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.play_arrow, color: Colors.white),
                                SizedBox(width: 8),
                                Text('Continuar', style: TextStyle(color: Colors.white)),
                              ],
                            ),
                          )
                        else
                          ElevatedButton(
                            onPressed: _pauseTimer,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.orange,
                              padding: EdgeInsets.symmetric(horizontal: 25, vertical: 12),
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.pause, color: Colors.white),
                                SizedBox(width: 8),
                                Text('Pausar', style: TextStyle(color: Colors.white)),
                              ],
                            ),
                          ),
                        
                        SizedBox(width: 15),
                        
                        ElevatedButton(
                          onPressed: _resetTimer,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            padding: EdgeInsets.symmetric(horizontal: 25, vertical: 12),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.stop, color: Colors.white),
                              SizedBox(width: 8),
                              Text('Reiniciar', style: TextStyle(color: Colors.white)),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 25),

         
            if (_workoutStarted) ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.blueAccent.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.blueAccent),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Ejercicio Actual:',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    SizedBox(height: 15),
                  
                    if (ejercicios[_currentExerciseIndex]['video'] != null)
                      VideoPlayerWidget(
                        videoPath: ejercicios[_currentExerciseIndex]['video']!,
                      ),
                    SizedBox(height: 15),
                    
                    Text(
                      ejercicios[_currentExerciseIndex]['nombre'],
                      style: TextStyle(
                        color: Colors.blueAccent,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    SizedBox(height: 5),
                    Text(
                      ejercicios[_currentExerciseIndex]['repeticiones'],
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                    ),
                    SizedBox(height: 5),
                    Text(
                      ejercicios[_currentExerciseIndex]['descripcion'],
                      style: TextStyle(
                        color: Colors.white60,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: 15),

              // Navegacion entre ejercicios
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ElevatedButton(
                    onPressed: _currentExerciseIndex > 0 ? _previousExercise : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blueAccent,
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.arrow_back, color: Colors.white),
                        SizedBox(width: 8),
                        Text('Anterior', style: TextStyle(color: Colors.white)),
                      ],
                    ),
                  ),
                  
                  ElevatedButton(
                    onPressed: _nextExercise,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                    ),
                    child: Row(
                      children: [
                        Text(
                          _currentExerciseIndex < ejercicios.length - 1 ? 'Siguiente' : 'Finalizar',
                          style: TextStyle(color: Colors.white),
                        ),
                        SizedBox(width: 8),
                        Icon(
                          _currentExerciseIndex < ejercicios.length - 1 ? 
                          Icons.arrow_forward : Icons.check,
                          color: Colors.white,
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              SizedBox(height: 20),
            ],

            const Text(
              'Ejercicios de la Rutina:',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 10),

            Column(
              children: ejercicios.asMap().entries.map((entry) {
                int index = entry.key;
                Map<String, dynamic> ejercicio = entry.value;
                return _buildEjercicioSimple(ejercicio, index);
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  List<Map<String, dynamic>> _obtenerEjerciciosPorRutina(String nombreRutina) {
    switch (nombreRutina) {
      case 'Rutina Fuerza Básica':
        return [
          {
            'nombre': 'Sentadillas',
            'repeticiones': '20 repeticiones',
            'descripcion': 'Pies al ancho de hombros, baja flexionando rodillas',
            'video': 'assets/videos/Sentadillas.mp4',
          },
          {
            'nombre': 'Flexiones',
            'repeticiones': '15 repeticiones', 
            'descripcion': 'Mantén el cuerpo recto, pecho cerca del suelo',
            'video': 'assets/videos/Flexiones.mp4',
          },
          {
            'nombre': 'Fondos en Silla',
            'repeticiones': '12 repeticiones',
            'descripcion': 'Apoya manos en silla, baja y sube el cuerpo',
            'video': 'assets/videos/fondos.mp4',
          },
          {
            'nombre': 'Plancha',
            'repeticiones': '30 segundos',
            'descripcion': 'Mantén posición de flexión con antebrazos',
            'video': 'assets/videos/plancha.mp4',
          },
        ];

      case 'Rutina Volumen Muscular':
        return [
          {
            'nombre': 'Press Banca',
            'repeticiones': '12 repeticiones',
            'descripcion': 'Acostado en banco, empuja la barra hacia arriba',
            'video': 'assets/videos/press_banca.mp4',
          },
          {
            'nombre': 'Sentadillas con Peso',
            'repeticiones': '10 repeticiones',
            'descripcion': 'Con barra en espalda, baja como sentándote',
            'video': 'assets/videos/sentadillas_peso.mp4',
          },
          {
            'nombre': 'Dominadas',
            'repeticiones': '8 repeticiones',
            'descripcion': 'Cuelga de la barra y eleva tu cuerpo',
            'video': 'assets/videos/dominadas.mp4',
          },
          {
            'nombre': 'Press Militar',
            'repeticiones': '10 repeticiones',
            'descripcion': 'De pie, empuja la barra sobre la cabeza',
            'video': 'assets/videos/press_militar.mp4',
          },
        ];

      case 'Rutina Quema Grasa':
        return [
          {
            'nombre': 'Burpees',
            'repeticiones': '15 repeticiones',
            'descripcion': 'Sentadilla, flexión, salto - todo en uno',
            'video': 'assets/videos/burpees.mp4',
          },
          {
            'nombre': 'Saltos Giratorio',
            'repeticiones': '40 segundos',
            'descripcion': 'Salta y gira tus pies hacia un lado y , al mismo tiempo, gira tu torso hacia el lado opuesto',
            'video': 'assets/videos/saltos_giratorios.mp4',
          },
          {
            'nombre': 'Mountain Climbers',
            'repeticiones': '30 segundos',
            'descripcion': 'En posición de plancha, lleva rodillas al pecho',
            'video': 'assets/videos/mountain.mp4',
          },
          {
            'nombre': 'Saltos de Cuerda',
            'repeticiones': '1 minuto',
            'descripcion': 'Salta la cuerda manteniendo ritmo constante',
            'video': 'assets/videos/saltos_cuerda.mp4',
          },
        ];

      case 'Rutina Fuerza Avanzada':
        return [
          {
            'nombre': 'Peso Muerto',
            'repeticiones': '8 repeticiones',
            'descripcion': 'Levanta la barra manteniendo espalda recta',
            'video': 'assets/videos/peso_muerto.mp4',
          },
          {
            'nombre': 'Sentadillas Profundas',
            'repeticiones': '6 repeticiones',
            'descripcion': 'Baja hasta donde tu flexibilidad permita',
            'video': 'assets/videos/sentadillas_profundas.mp4',
          },
          {
            'nombre': 'Press Banca con Mancuernas',
            'repeticiones': '8 repeticiones',
            'descripcion': 'Mayor rango de movimiento que con barra',
            'video': 'assets/videos/press_mancuernas.mp4',
          },
          {
            'nombre': 'Dominadas con Peso',
            'repeticiones': '6 repeticiones',
            'descripcion': 'Añade peso extra para mayor intensidad',
            'video': 'assets/videos/dominadas_peso.mp4',
          },
        ];

      default:
        return [
          {
            'nombre': 'Ejercicio Básico',
            'repeticiones': '10 repeticiones',
            'descripcion': 'Ejercicio de ejemplo',
            'video': 'assets/videos/ejemplo.mp4',
          },
        ];
    }
  }

  Widget _buildEjercicioSimple(Map<String, dynamic> ejercicio, int index) {
    bool isCurrentExercise = _workoutStarted && index == _currentExerciseIndex;
    
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isCurrentExercise ? Colors.blueAccent.withOpacity(0.2) : Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isCurrentExercise ? Colors.blueAccent : Colors.blueAccent.withOpacity(0.3),
          width: isCurrentExercise ? 2 : 1,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
       
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: isCurrentExercise ? Colors.blueAccent : Colors.blueAccent.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Text(
              '${index + 1}',
              style: TextStyle(
                color: isCurrentExercise ? Colors.white : Colors.blueAccent,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          
          const SizedBox(width: 12),
          
        
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  ejercicio['nombre'],
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  ejercicio['repeticiones'],
                  style: TextStyle(
                    color: Colors.blueAccent,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  ejercicio['descripcion'],
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          
          
          if (isCurrentExercise)
            Icon(Icons.play_arrow, color: Colors.blueAccent),
        ],
      ),
    );
  }
}