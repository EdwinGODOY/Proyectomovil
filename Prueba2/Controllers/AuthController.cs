using Microsoft.AspNetCore.Mvc;
using Prueba.Contexts;
using System.Data.Common;
using System.Security.Cryptography;
using System.Text;
using System.Text.Json;

namespace Prueba.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    public class AuthController : ControllerBase
    {
        private readonly ConexionSQLServer _conexion;

        public AuthController(ConexionSQLServer conexion)
        {
            _conexion = conexion;
        }

        // Helper para encriptar contraseña
        private string HashPassword(string password)
        {
            using (var sha256 = SHA256.Create())
            {
                var bytes = Encoding.UTF8.GetBytes(password);
                var hash = sha256.ComputeHash(bytes);
                return Convert.ToBase64String(hash);
            }
        }

        // POST: Login de usuario
        [HttpPost("login")]
        public async Task<IActionResult> Login([FromBody] JsonElement request)
        {
            try
            {
                // Extraer datos del JSON de forma segura
                string usuario = request.TryGetProperty("usuario", out JsonElement usuarioElement) 
                    ? usuarioElement.GetString() ?? "" 
                    : "";

                string password = request.TryGetProperty("password", out JsonElement passwordElement) 
                    ? passwordElement.GetString() ?? "" 
                    : "";

                if (string.IsNullOrEmpty(usuario) || string.IsNullOrEmpty(password))
                {
                    return Ok(new { 
                        success = false, 
                        error = "Usuario y contraseña son requeridos" 
                    });
                }

                using (var connection = _conexion.GetConnection())
                {
                    await connection.OpenAsync();
                    using (var command = connection.CreateCommand())
                    {
                        command.CommandText = "SELECT Id, Nombre, Apellido, Email, Usuario FROM UsuariosGym WHERE Usuario = @usuario AND Password = @password";
                        
                        command.Parameters.Add(CreateParameter(command, "@usuario", usuario));
                        command.Parameters.Add(CreateParameter(command, "@password", HashPassword(password)));

                        using (var reader = await command.ExecuteReaderAsync())
                        {
                            if (await reader.ReadAsync())
                            {
                                var userData = new
                                {
                                    Id = reader.GetInt32(0),
                                    Nombre = reader.GetString(1),
                                    Apellido = reader.GetString(2),
                                    Email = reader.GetString(3),
                                    Usuario = reader.GetString(4)
                                };

                                return Ok(new { 
                                    success = true, 
                                    message = "Login exitoso", 
                                    data = userData 
                                });
                            }
                            else
                            {
                                return Ok(new { 
                                    success = false, 
                                    error = "Usuario o contraseña incorrectos" 
                                });
                            }
                        }
                    }
                }
            }
            catch (Exception ex)
            {
                return StatusCode(500, new { 
                    success = false, 
                    error = $"Error interno: {ex.Message}" 
                });
            }
        }

        // POST: Registrar nuevo usuario
        [HttpPost("register")]
        public async Task<IActionResult> Register([FromBody] JsonElement request)
        {
            try
            {
                // Extraer datos del JSON de forma segura
                string nombre = request.TryGetProperty("nombre", out JsonElement nombreElement) 
                    ? nombreElement.GetString() ?? "" 
                    : "";

                string apellido = request.TryGetProperty("apellido", out JsonElement apellidoElement) 
                    ? apellidoElement.GetString() ?? "" 
                    : "";

                string email = request.TryGetProperty("email", out JsonElement emailElement) 
                    ? emailElement.GetString() ?? "" 
                    : "";

                string usuario = request.TryGetProperty("usuario", out JsonElement usuarioElement) 
                    ? usuarioElement.GetString() ?? "" 
                    : "";

                string password = request.TryGetProperty("password", out JsonElement passwordElement) 
                    ? passwordElement.GetString() ?? "" 
                    : "";

                // Validaciones básicas
                if (string.IsNullOrWhiteSpace(usuario) || string.IsNullOrWhiteSpace(password))
                {
                    return Ok(new { 
                        success = false, 
                        error = "Usuario y contraseña son requeridos" 
                    });
                }

                using (var connection = _conexion.GetConnection())
                {
                    await connection.OpenAsync();

                    // Verificar si el usuario ya existe
                    using (var checkCommand = connection.CreateCommand())
                    {
                        checkCommand.CommandText = "SELECT COUNT(*) FROM UsuariosGym WHERE Usuario = @usuario OR Email = @email";
                        
                        checkCommand.Parameters.Add(CreateParameter(checkCommand, "@usuario", usuario));
                        checkCommand.Parameters.Add(CreateParameter(checkCommand, "@email", email));

                        var count = (int)await checkCommand.ExecuteScalarAsync();
                        if (count > 0)
                        {
                            return Ok(new { 
                                success = false, 
                                error = "El usuario o email ya existen" 
                            });
                        }
                    }

                    // Insertar nuevo usuario
                    using (var command = connection.CreateCommand())
                    {
                        command.CommandText = @"INSERT INTO UsuariosGym (Nombre, Apellido, Email, Usuario, Password) 
                                              VALUES (@nombre, @apellido, @email, @usuario, @password)";

                        command.Parameters.Add(CreateParameter(command, "@nombre", nombre));
                        command.Parameters.Add(CreateParameter(command, "@apellido", apellido));
                        command.Parameters.Add(CreateParameter(command, "@email", email));
                        command.Parameters.Add(CreateParameter(command, "@usuario", usuario));
                        command.Parameters.Add(CreateParameter(command, "@password", HashPassword(password)));

                        await command.ExecuteNonQueryAsync();

                        return Ok(new { 
                            success = true, 
                            message = "Usuario registrado exitosamente" 
                        });
                    }
                }
            }
            catch (Exception ex)
            {
                return StatusCode(500, new { 
                    success = false, 
                    error = $"Error al registrar usuario: {ex.Message}" 
                });
            }
        }

        // GET: Obtener todos los usuarios
        [HttpGet("usuarios")]
        public async Task<IActionResult> GetAllUsuarios()
        {
            try
            {
                var usuarios = new List<object>();
                using (var connection = _conexion.GetConnection())
                {
                    await connection.OpenAsync();
                    using (var command = connection.CreateCommand())
                    {
                        command.CommandText = "SELECT Id, Nombre, Apellido, Email, Usuario, FechaRegistro FROM UsuariosGym";

                        using (var reader = await command.ExecuteReaderAsync())
                        {
                            while (await reader.ReadAsync())
                            {
                                usuarios.Add(new
                                {
                                    Id = reader.GetInt32(0),
                                    Nombre = reader.GetString(1),
                                    Apellido = reader.GetString(2),
                                    Email = reader.GetString(3),
                                    Usuario = reader.GetString(4),
                                    FechaRegistro = reader.GetDateTime(5)
                                });
                            }
                        }
                    }
                }

                return Ok(new { success = true, data = usuarios });
            }
            catch (Exception ex)
            {
                return StatusCode(500, new { success = false, error = $"Error al obtener usuarios: {ex.Message}" });
            }
        }

        // GET: Obtener un usuario específico por ID
        [HttpGet("usuario/{id}")]
        public async Task<IActionResult> GetUsuarioById(int id)
        {
            try
            {
                using (var connection = _conexion.GetConnection())
                {
                    await connection.OpenAsync();
                    using (var command = connection.CreateCommand())
                    {
                        command.CommandText = "SELECT Id, Nombre, Apellido, Email, Usuario, FechaRegistro FROM UsuariosGym WHERE Id = @id";
                        command.Parameters.Add(CreateParameter(command, "@id", id));

                        using (var reader = await command.ExecuteReaderAsync())
                        {
                            if (await reader.ReadAsync())
                            {
                                var usuario = new
                                {
                                    Id = reader.GetInt32(0),
                                    Nombre = reader.GetString(1),
                                    Apellido = reader.GetString(2),
                                    Email = reader.GetString(3),
                                    Usuario = reader.GetString(4),
                                    FechaRegistro = reader.GetDateTime(5)
                                };

                                return Ok(new { success = true, data = usuario });
                            }
                            else
                            {
                                return NotFound(new { success = false, error = "Usuario no encontrado" });
                            }
                        }
                    }
                }
            }
            catch (Exception ex)
            {
                return StatusCode(500, new { success = false, error = $"Error al obtener usuario: {ex.Message}" });
            }
        }

        // PUT: Actualizar información del usuario
        [HttpPut("usuario/{id}")]
        public async Task<IActionResult> UpdateUsuario(int id, [FromBody] JsonElement request)
        {
            try
            {
                // Extraer datos del JSON de forma segura
                string nombre = request.TryGetProperty("nombre", out JsonElement nombreElement) 
                    ? nombreElement.GetString() ?? "" 
                    : "";

                string apellido = request.TryGetProperty("apellido", out JsonElement apellidoElement) 
                    ? apellidoElement.GetString() ?? "" 
                    : "";

                string email = request.TryGetProperty("email", out JsonElement emailElement) 
                    ? emailElement.GetString() ?? "" 
                    : "";

                string usuario = request.TryGetProperty("usuario", out JsonElement usuarioElement) 
                    ? usuarioElement.GetString() ?? "" 
                    : "";

                string password = request.TryGetProperty("password", out JsonElement passwordElement) 
                    ? passwordElement.GetString() ?? "" 
                    : "";

                using (var connection = _conexion.GetConnection())
                {
                    await connection.OpenAsync();

                    // Verificar si el usuario existe
                    using (var checkCommand = connection.CreateCommand())
                    {
                        checkCommand.CommandText = "SELECT COUNT(*) FROM UsuariosGym WHERE Id = @id";
                        checkCommand.Parameters.Add(CreateParameter(checkCommand, "@id", id));

                        var count = (int)await checkCommand.ExecuteScalarAsync();
                        if (count == 0)
                        {
                            return NotFound(new { success = false, error = "Usuario no encontrado" });
                        }
                    }

                    // Verificar si el nuevo usuario o email ya existen (excluyendo el actual)
                    using (var checkCommand = connection.CreateCommand())
                    {
                        checkCommand.CommandText = "SELECT COUNT(*) FROM UsuariosGym WHERE (Usuario = @usuario OR Email = @email) AND Id != @id";
                        
                        checkCommand.Parameters.Add(CreateParameter(checkCommand, "@usuario", usuario));
                        checkCommand.Parameters.Add(CreateParameter(checkCommand, "@email", email));
                        checkCommand.Parameters.Add(CreateParameter(checkCommand, "@id", id));

                        var count = (int)await checkCommand.ExecuteScalarAsync();
                        if (count > 0)
                        {
                            return Ok(new { 
                                success = false, 
                                error = "El usuario o email ya están en uso por otro usuario" 
                            });
                        }
                    }

                    // Actualizar usuario
                    using (var command = connection.CreateCommand())
                    {
                        if (!string.IsNullOrEmpty(password))
                        {
                            // Si se proporciona nueva contraseña, actualizar todo
                            command.CommandText = @"UPDATE UsuariosGym 
                                                  SET Nombre = @nombre, Apellido = @apellido, 
                                                      Email = @email, Usuario = @usuario, 
                                                      Password = @password 
                                                  WHERE Id = @id";
                            command.Parameters.Add(CreateParameter(command, "@password", HashPassword(password)));
                        }
                        else
                        {
                            // Si no se proporciona contraseña, mantener la actual
                            command.CommandText = @"UPDATE UsuariosGym 
                                                  SET Nombre = @nombre, Apellido = @apellido, 
                                                      Email = @email, Usuario = @usuario 
                                                  WHERE Id = @id";
                        }

                        command.Parameters.Add(CreateParameter(command, "@nombre", nombre));
                        command.Parameters.Add(CreateParameter(command, "@apellido", apellido));
                        command.Parameters.Add(CreateParameter(command, "@email", email));
                        command.Parameters.Add(CreateParameter(command, "@usuario", usuario));
                        command.Parameters.Add(CreateParameter(command, "@id", id));

                        int filasAfectadas = await command.ExecuteNonQueryAsync();

                        if (filasAfectadas > 0)
                        {
                            return Ok(new { 
                                success = true, 
                                message = "Usuario actualizado exitosamente" 
                            });
                        }
                        else
                        {
                            return StatusCode(500, new { 
                                success = false, 
                                error = "Error al actualizar usuario" 
                            });
                        }
                    }
                }
            }
            catch (Exception ex)
            {
                return StatusCode(500, new { 
                    success = false, 
                    error = $"Error al actualizar usuario: {ex.Message}" 
                });
            }
        }

        // DELETE: Eliminar usuario (eliminar cuenta)
        [HttpDelete("usuario/{id}")]
        public async Task<IActionResult> DeleteUsuario(int id)
        {
            try
            {
                using (var connection = _conexion.GetConnection())
                {
                    await connection.OpenAsync();

                    // Verificar si el usuario existe
                    using (var checkCommand = connection.CreateCommand())
                    {
                        checkCommand.CommandText = "SELECT COUNT(*) FROM UsuariosGym WHERE Id = @id";
                        checkCommand.Parameters.Add(CreateParameter(checkCommand, "@id", id));

                        var count = (int)await checkCommand.ExecuteScalarAsync();
                        if (count == 0)
                        {
                            return NotFound(new { success = false, error = "Usuario no encontrado" });
                        }
                    }

                    // Eliminar usuario
                    using (var command = connection.CreateCommand())
                    {
                        command.CommandText = "DELETE FROM UsuariosGym WHERE Id = @id";
                        command.Parameters.Add(CreateParameter(command, "@id", id));

                        int filasAfectadas = await command.ExecuteNonQueryAsync();

                        if (filasAfectadas > 0)
                        {
                            return Ok(new { 
                                success = true, 
                                message = "Usuario eliminado exitosamente" 
                            });
                        }
                        else
                        {
                            return StatusCode(500, new { 
                                success = false, 
                                error = "Error al eliminar usuario" 
                            });
                        }
                    }
                }
            }
            catch (Exception ex)
            {
                return StatusCode(500, new { 
                    success = false, 
                    error = $"Error al eliminar usuario: {ex.Message}" 
                });
            }
        }

        private DbParameter CreateParameter(DbCommand command, string name, object value)
        {
            var param = command.CreateParameter();
            param.ParameterName = name;
            param.Value = value ?? DBNull.Value;
            return param;
        }
    }
}