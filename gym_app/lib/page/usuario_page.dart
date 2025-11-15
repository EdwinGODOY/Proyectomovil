import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:gym_app/page/dashboard_page.dart';
import 'dart:convert';


class UsuarioPage extends StatefulWidget { 
  final Map<String, dynamic> userData;
  
  const UsuarioPage({Key? key, required this.userData}) : super(key: key);  
  @override
  _UsuarioPageState createState() => _UsuarioPageState(); 
}

class _UsuarioPageState extends State<UsuarioPage> {  
  final nombreController = TextEditingController();
  final apellidoController = TextEditingController();
  final emailController = TextEditingController();
  final usuarioController = TextEditingController();
  final passwordController = TextEditingController();
  
  bool _isLoading = false;
  bool _obscurePassword = true;

  @override
  void initState() {
    super.initState();
    
    nombreController.text = widget.userData['nombre'];
    apellidoController.text = widget.userData['apellido'];
    emailController.text = widget.userData['email'];
    usuarioController.text = widget.userData['usuario'];
  }

void _actualizarUsuario() async {
  if (nombreController.text.isEmpty || 
      apellidoController.text.isEmpty || 
      emailController.text.isEmpty || 
      usuarioController.text.isEmpty) {
    _mostrarMensaje('Por favor completa todos los campos', Colors.orange);
    return;
  }

  setState(() {
    _isLoading = true;
  });

  try {
    final url = Uri.parse('http://10.0.2.2:5238/api/Auth/usuario/${widget.userData['id']}');
    
    print(' URL: $url'); 
    print(' Datos enviados:'); 
    print('  - ID: ${widget.userData['id']}'); 
    print('  - Nombre: ${nombreController.text}');
    print('  - Usuario: ${usuarioController.text}');

    final response = await http.put(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'nombre': nombreController.text,
        'apellido': apellidoController.text,
        'email': emailController.text,
        'usuario': usuarioController.text,
        'password': passwordController.text.isEmpty ? '' : passwordController.text,
      }),
    );

    print(' Response status: ${response.statusCode}');
    print(' Response body: ${response.body}'); 

    final data = jsonDecode(response.body);
    if (data['success']) {
      _mostrarMensaje('🎉 ${data['message']}', Colors.green);
    
      setState(() {
        widget.userData['nombre'] = nombreController.text;
        widget.userData['apellido'] = apellidoController.text;
        widget.userData['email'] = emailController.text;
        widget.userData['usuario'] = usuarioController.text;
      });
      passwordController.clear();
    } else {
      _mostrarMensaje(' ${data['error']}', Colors.red);
    }
  } catch (e) {
    print('Error: $e'); 
    _mostrarMensaje('Error de conexión: $e', Colors.red);
  } finally {
    setState(() {
      _isLoading = false;
    });
  }
}

  void _eliminarCuenta() async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Eliminar Cuenta'),
        content: Text('¿Estás seguro de que quieres eliminar tu cuenta? Esta acción no se puede deshacer.'),
        actions: [
          TextButton(
            child: Text('Cancelar'),
            onPressed: () => Navigator.of(context).pop(),
          ),
          TextButton(
            child: Text('Eliminar', style: TextStyle(color: Colors.red)),
            onPressed: () async {
              Navigator.of(context).pop();
              await _confirmarEliminacion();
            },
          ),
        ],
      ),
    );
  }

  Future<void> _confirmarEliminacion() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final url = Uri.parse('http://10.0.2.2:5238/api/Auth/usuario/${widget.userData['id']}');
      final response = await http.delete(url);

      final data = jsonDecode(response.body);
      if (data['success']) {
        _mostrarMensaje('Cuenta eliminada exitosamente', Colors.green);
        
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) =>DashboardPage(userData: widget.userData)),
          (route) => false,
        );
      } else {
        _mostrarMensaje('${data['error']}', Colors.red);
      }
    } catch (e) {
      _mostrarMensaje('Error de conexión: $e', Colors.red);
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _mostrarMensaje(String mensaje, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(mensaje),
        backgroundColor: color,
      ),
    );
  }

  void _cerrarSesion() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Cerrar Sesión'),
        content: Text('¿Estás seguro de que quieres cerrar sesión?'),
        actions: [
          TextButton(
            child: Text('Cancelar'),
            onPressed: () => Navigator.of(context).pop(),
          ),
          TextButton(
            child: Text('Cerrar Sesión'),
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => DashboardPage(userData: widget.userData)),
                (route) => false,
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool obscureText = false,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.blueAccent.withOpacity(0.3)),
      ),
      child: TextField(
        controller: controller,
        obscureText: obscureText && _obscurePassword,
        keyboardType: keyboardType,
        style: TextStyle(color: Colors.white),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: Colors.white70),
          prefixIcon: Icon(icon, color: Colors.blueAccent),
          suffixIcon: obscureText
              ? IconButton(
                  icon: Icon(
                    _obscurePassword ? Icons.visibility : Icons.visibility_off,
                    color: Colors.blueAccent,
                  ),
                  onPressed: () {
                    setState(() {
                      _obscurePassword = !_obscurePassword;
                    });
                  },
                )
              : null,
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF1A1A2E),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Mi Perfil',  
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.logout, color: Colors.white),
            onPressed: _cerrarSesion,
          ),
        ],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: EdgeInsets.all(24),
              child: Column(
                children: [
                  
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      color: Colors.blueAccent.withOpacity(0.2),
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.blueAccent, width: 2),
                    ),
                    child: Icon(
                      Icons.person,
                      size: 50,
                      color: Colors.blueAccent,
                    ),
                  ),
                  SizedBox(height: 20),
                  Text(
                    '${widget.userData['nombre']} ${widget.userData['apellido']}',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    '@${widget.userData['usuario']}',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 16,
                    ),
                  ),
                  SizedBox(height: 40),

              
                  Text(
                    'Editar Información',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 20),

                  _buildTextField(
                    controller: nombreController,
                    label: 'Nombre',
                    icon: Icons.person_outline,
                  ),
                  SizedBox(height: 15),

                  _buildTextField(
                    controller: apellidoController,
                    label: 'Apellido',
                    icon: Icons.person_outline,
                  ),
                  SizedBox(height: 15),

                  _buildTextField(
                    controller: emailController,
                    label: 'Email',
                    icon: Icons.email_outlined,
                    keyboardType: TextInputType.emailAddress,
                  ),
                  SizedBox(height: 15),

                  _buildTextField(
                    controller: usuarioController,
                    label: 'Usuario',
                    icon: Icons.alternate_email,
                  ),
                  SizedBox(height: 15),

                  _buildTextField(
                    controller: passwordController,
                    label: 'Nueva Contraseña (opcional)',
                    icon: Icons.lock_outline,
                    obscureText: true,
                  ),
                  SizedBox(height: 30),

              
                  Container(
                    width: double.infinity,
                    height: 55,
                    child: ElevatedButton(
                      onPressed: _actualizarUsuario,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blueAccent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),
                      child: Text(
                        'ACTUALIZAR INFORMACIÓN',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 20),

            
                  Container(
                    width: double.infinity,
                    height: 55,
                    child: OutlinedButton(
                      onPressed: _eliminarCuenta,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.red,
                        side: BorderSide(color: Colors.red, width: 2),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),
                      child: Text(
                        'ELIMINAR CUENTA',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}