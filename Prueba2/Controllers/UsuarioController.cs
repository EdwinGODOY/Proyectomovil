/*using Microsoft.AspNetCore.Mvc;
using Prueba.Contexts;
using Prueba.Models;
using System.Data.Common;

namespace Prueba.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    public class UsuarioController : ControllerBase
    {
        private readonly ConexionSQLServer _conexion;

        public UsuarioController(ConexionSQLServer conexion)
        {
            _conexion = conexion;
        }

        /// <summary>
       
        /// </summary>
        /// <returns>Lista de usuarios</returns>
        [HttpGet]
        public async Task<IActionResult> GetUsuarios()
        {
            var usuarios = new List<Usuarios>();

            using (var connection = _conexion.GetConnection())
            {
                await connection.OpenAsync();
                using (var command = connection.CreateCommand())
                {
                    command.CommandText = "SELECT Id, Nombre FROM Usuario";

                    using (var reader = await command.ExecuteReaderAsync())
                    {
                        while (await reader.ReadAsync())
                        {
                            usuarios.Add(new Usuarios
                            {
                                Id = reader.GetInt32(0),
                                Nombre = reader.GetString(1)
                            });
                        }
                    }
                }
            }

            return Ok(usuarios);
        }

        /// <summary>
      
        /// </summary>
        /// <param name="usuario">Datos del nuevo usuario</param>
        /// <returns>Mensaje de confirmación</returns>
        [HttpPost]
        public async Task<IActionResult> CrearUsuario([FromBody] Usuarios usuario)
        {
         
            if (usuario == null || string.IsNullOrWhiteSpace(usuario.Nombre))
            {
                return BadRequest("El nombre del usuario es requerido");
            }

            using (var connection = _conexion.GetConnection())
            {
                await connection.OpenAsync();
                using (var command = connection.CreateCommand())
                {
                    command.CommandText = "INSERT INTO Usuario (Nombre) VALUES (@nombre)";

                    var paramNombre = command.CreateParameter();
                    paramNombre.ParameterName = "@nombre";
                    paramNombre.Value = usuario.Nombre;
                    command.Parameters.Add(paramNombre);

                    await command.ExecuteNonQueryAsync();
                }
            }

            return Ok("Usuario creado correctamente");
        }

        /// <summary>
        /// Actualiza un usuario existente
        /// </summary>
        /// <param name="id">ID del usuario a actualizar</param>
        /// <param name="usuario">Nuevos datos del usuario</param>
        /// <returns>Mensaje de confirmación</returns>
        [HttpPut("{id}")]
        public async Task<IActionResult> ActualizarUsuario(int id, [FromBody] Usuarios usuario)
        {
            if (usuario == null || string.IsNullOrWhiteSpace(usuario.Nombre))
            {
                return BadRequest("El nombre del usuario es requerido");
            }

            using (var connection = _conexion.GetConnection())
            {
                await connection.OpenAsync();
                using (var command = connection.CreateCommand())
                {
                    command.CommandText = "UPDATE Usuario SET Nombre = @nombre WHERE Id = @id";

                    var paramNombre = command.CreateParameter();
                    paramNombre.ParameterName = "@nombre";
                    paramNombre.Value = usuario.Nombre;
                    command.Parameters.Add(paramNombre);

                    var paramId = command.CreateParameter();
                    paramId.ParameterName = "@id";
                    paramId.Value = id;
                    command.Parameters.Add(paramId);

                    int filasAfectadas = await command.ExecuteNonQueryAsync();

                    if (filasAfectadas == 0)
                        return NotFound($"No se encontró un usuario con Id {id}");
                }
            }

            return Ok("Usuario actualizado correctamente");
        }

        /// <summary>
        /// Elimina un usuario
        /// </summary>
        /// <param name="id">ID del usuario a eliminar</param>
        /// <returns>Mensaje de confirmación</returns>
        [HttpDelete("{id}")]
        public async Task<IActionResult> EliminarUsuario(int id)
        {
            using (var connection = _conexion.GetConnection())
            {
                await connection.OpenAsync();
                using (var command = connection.CreateCommand())
                {
                    command.CommandText = "DELETE FROM Usuario WHERE Id = @id";

                    var paramId = command.CreateParameter();
                    paramId.ParameterName = "@id";
                    paramId.Value = id;
                    command.Parameters.Add(paramId);

                    int filasAfectadas = await command.ExecuteNonQueryAsync();

                    if (filasAfectadas == 0)
                        return NotFound($"No se encontró un usuario con Id {id}");
                }
            }

            return Ok("Usuario eliminado correctamente");
        }
    }
}*/