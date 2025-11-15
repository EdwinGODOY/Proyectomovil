import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ProfilePage extends StatefulWidget {
  final Map<String, dynamic> userData;
  
  const ProfilePage({Key? key, required this.userData}) : super(key: key);

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final _formKey = GlobalKey<FormState>();
  
  TextEditingController _edadController = TextEditingController();
  TextEditingController _pesoController = TextEditingController();
  TextEditingController _alturaController = TextEditingController();
  
  String _nivelExperiencia = 'Principiante';
  List<String> _objetivosSeleccionados = [];
  bool _guardando = false;
  bool _cargando = true;
  
  final List<String> _niveles = ['Principiante', 'Intermedio', 'Avanzado'];
  
  final String _apiUrl = 'http://10.0.2.2:5238/api/profile';

  @override
  void initState() {
    super.initState();
    _cargarPerfilFitness();
  }

  
  Future<void> _cargarPerfilFitness() async {
    try {
      final response = await http.get(
        Uri.parse('$_apiUrl/fitness/${widget.userData['id']}'),
      );

      final data = jsonDecode(response.body);
      if (data['success'] && data['data'] != null) {
        _cargarDatosExistentes(data['data']);
      }
    } catch (e) {
      print('Error cargando perfil fitness: $e');
    } finally {
      setState(() {
        _cargando = false;
      });
    }
  }

  void _cargarDatosExistentes(Map<String, dynamic> perfilData) {
    if (perfilData['edad'] != null) {
      _edadController.text = perfilData['edad'].toString();
    }
    if (perfilData['peso'] != null) {
      _pesoController.text = perfilData['peso'].toString();
    }
    if (perfilData['altura'] != null) {
      _alturaController.text = perfilData['altura'].toString();
    }
    if (perfilData['nivelExperiencia'] != null) {
      _nivelExperiencia = perfilData['nivelExperiencia'];
    }
    if (perfilData['objetivos'] != null && perfilData['objetivos'] is String) {
      _objetivosSeleccionados = (perfilData['objetivos'] as String)
          .split(',')
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty)
          .toList();
    }
  }


  Future<void> _guardarPerfilFitness() async {
    if (_formKey.currentState!.validate() && _objetivosSeleccionados.isNotEmpty) {
      setState(() {
        _guardando = true;
      });

      try {
        Map<String, dynamic> perfilData = {
          'edad': int.tryParse(_edadController.text) ?? 0,
          'peso': double.tryParse(_pesoController.text) ?? 0.0,
          'altura': double.tryParse(_alturaController.text) ?? 0.0,
          'nivelExperiencia': _nivelExperiencia,
          'objetivos': _objetivosSeleccionados.join(','),
        };

        
        final response = await http.post(
          Uri.parse('$_apiUrl/fitness/${widget.userData['id']}'),
          headers: {
            'Content-Type': 'application/json',
          },
          body: json.encode(perfilData),
        );

        final data = jsonDecode(response.body);
        if (data['success']) {
         
          widget.userData.addAll(perfilData);
          _mostrarMensajeExito(data['message'] ?? 'Perfil fitness guardado correctamente!');
          Navigator.pop(context);
        } else {
          _mostrarError(data['error'] ?? 'Error del servidor');
        }
      } catch (e) {
        _mostrarError('Error de conexión: $e');
      } finally {
        setState(() {
          _guardando = false;
        });
      }
    } else if (_objetivosSeleccionados.isEmpty) {
      _mostrarError('Por favor selecciona al menos un objetivo');
    }
  }

  void _mostrarMensajeExito(String mensaje) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.check_circle, color: Colors.white),
            SizedBox(width: 8),
            Text(mensaje),
          ],
        ),
        backgroundColor: Colors.green[600],
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }

  void _mostrarError(String mensaje) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.error, color: Colors.white),
            SizedBox(width: 8),
            Expanded(child: Text(mensaje)),
          ],
        ),
        backgroundColor: Colors.red[600],
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_cargando) {
      return Scaffold(
        backgroundColor: const Color.fromARGB(255, 0, 0, 74),
        body: Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Colors.blueAccent),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 0, 0, 74),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Mis datos',
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
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              _buildHeader(),
              const SizedBox(height: 30),
              
              if (widget.userData['nombre'] != null && widget.userData['apellido'] != null)
                Column(
                  children: [
                    Text(
                      '${widget.userData['nombre']} ${widget.userData['apellido']}',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 10),
                  ],
                ),
              
              _buildNumberField(
                'Edad',
                'Ingresa tu edad',
                _edadController,
                (value) {
                  if (value == null || value.isEmpty) return 'Ingresa tu edad';
                  final age = int.tryParse(value);
                  if (age == null || age < 15 || age > 100) {
                    return 'Edad válida entre 15-100 años';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              
              _buildNumberField(
                'Peso (kg)',
                'Ej: 70.5',
                _pesoController,
                (value) {
                  if (value == null || value.isEmpty) return 'Ingresa tu peso';
                  final weight = double.tryParse(value);
                  if (weight == null || weight < 30 || weight > 200) {
                    return 'Peso válido entre 30-200 kg';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              
              _buildNumberField(
                'Altura (cm)',
                'Ej: 175',
                _alturaController,
                (value) {
                  if (value == null || value.isEmpty) return 'Ingresa tu altura';
                  final height = double.tryParse(value);
                  if (height == null || height < 100 || height > 250) {
                    return 'Altura válida entre 100-250 cm';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              
              _buildDropdownField(),
              const SizedBox(height: 20),
              
              
              
              _buildSaveButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            shape: BoxShape.circle,
            border: Border.all(color: Colors.blueAccent.withOpacity(0.3)),
          ),
          child: Icon(
            Icons.person_add_alt_1,
            size: 50,
            color: Colors.blueAccent,
          ),
        ),
        const SizedBox(height: 20),
        const Text(
          'MIS DATOS',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 10),
        const Text(
          'Completa tu información para personalizar tu entrenamiento',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 16,
            color: Colors.white70,
            height: 1.4,
          ),
        ),
      ],
    );
  }

  Widget _buildNumberField(
    String label, 
    String hint, 
    TextEditingController controller, 
    FormFieldValidator<String> validator
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: TextInputType.number,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: Colors.white60),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.blueAccent.withOpacity(0.5)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.blueAccent.withOpacity(0.5)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.blueAccent),
            ),
            filled: true,
            fillColor: Colors.white.withOpacity(0.1),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          ),
          validator: validator,
        ),
      ],
    );
  }

  Widget _buildDropdownField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Nivel de Experiencia',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.blueAccent.withOpacity(0.5)),
          ),
          child: DropdownButtonFormField<String>(
            value: _nivelExperiencia,
            dropdownColor: const Color.fromARGB(255, 0, 0, 74),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
            ),
            decoration: const InputDecoration(
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            ),
            items: _niveles.map((String nivel) {
              return DropdownMenuItem<String>(
                value: nivel,
                child: Text(
                  nivel,
                  style: const TextStyle(color: Colors.white),
                ),
              );
            }).toList(),
            onChanged: (String? newValue) {
              setState(() {
                _nivelExperiencia = newValue!;
              });
            },
          ),
        ),
      ],
    );
  }

 

  Widget _buildSaveButton() {
    return Container(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: _guardando ? null : _guardarPerfilFitness, 
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blueAccent,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 2,
        ),
        child: _guardando
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : const Text(
                'MIS DATOS ',
                style: TextStyle(
                  fontSize: 16, 
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
              ),
      ),
    );
  }

  @override
  void dispose() {
    _edadController.dispose();
    _pesoController.dispose();
    _alturaController.dispose();
    super.dispose();
  }
}