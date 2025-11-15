
import 'dart:convert';
import 'package:http/http.dart' as http;

class TiempoService {
  static const String baseUrl = 'http://10.0.2.2:5238/api/Tiempo';

  
  static Future<int> obtenerTiempo(int usuarioId, String rutina) async {
    try {
      final url = Uri.parse('$baseUrl/$usuarioId/${Uri.encodeComponent(rutina)}');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['segundos'] ?? 0;
      }
      return 0;
    } catch (e) {
      print('Error al obtener tiempo: $e');
      return 0;
    }
  }


  static Future<Map<String, int>> obtenerTodosLosTiempos(int usuarioId) async {
    final rutinas = [
      'Rutina Fuerza Básica',
      'Rutina Volumen Muscular', 
      'Rutina Quema Grasa',
      'Rutina Fuerza Avanzada'
    ];

    Map<String, int> tiempos = {};

    for (String rutina in rutinas) {
      final tiempo = await obtenerTiempo(usuarioId, rutina);
      tiempos[rutina] = tiempo;
    }

    return tiempos;
  }
}