using Microsoft.AspNetCore.Mvc;
using Prueba.Contexts;
using Prueba.Models;
using System.Data.Common;
using System.Data;

namespace Prueba.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    public class TiempoController : ControllerBase
    {
        private readonly ConexionSQLServer _conexion;

        public TiempoController(ConexionSQLServer conexion)
        {
            _conexion = conexion;
        }

        // POST: Guardar tiempo de rutina
        [HttpPost]
        public async Task<IActionResult> GuardarTiempo([FromBody] TiempoUsuario tiempo)
        {
            if (tiempo.UsuarioId <= 0 || string.IsNullOrEmpty(tiempo.Rutina))
                return BadRequest(new { success = false, error = "UsuarioId y Rutina son requeridos" });

            try
            {
                using var connection = _conexion.GetConnection();
                await connection.OpenAsync();

                // Verificar si ya existe un registro previo para el mismo usuario y rutina
                using (var checkCommand = connection.CreateCommand())
                {
                    checkCommand.CommandText = "SELECT COUNT(*) FROM TiempoUsuario WHERE UsuarioId = @usuarioId AND Rutina = @rutina";
                    checkCommand.Parameters.Add(CreateParameter(checkCommand, "@usuarioId", tiempo.UsuarioId));
                    checkCommand.Parameters.Add(CreateParameter(checkCommand, "@rutina", tiempo.Rutina));

                    int count = Convert.ToInt32(await checkCommand.ExecuteScalarAsync());

                    if (count > 0)
                    {
                        // Actualizar el tiempo existente sumando segundos
                        using var updateCommand = connection.CreateCommand();
                        updateCommand.CommandText = "UPDATE TiempoUsuario SET Segundos = Segundos + @segundos, FechaRegistro = @fecha WHERE UsuarioId = @usuarioId AND Rutina = @rutina";
                        updateCommand.Parameters.Add(CreateParameter(updateCommand, "@segundos", tiempo.Segundos));
                        updateCommand.Parameters.Add(CreateParameter(updateCommand, "@fecha", DateTime.Now));
                        updateCommand.Parameters.Add(CreateParameter(updateCommand, "@usuarioId", tiempo.UsuarioId));
                        updateCommand.Parameters.Add(CreateParameter(updateCommand, "@rutina", tiempo.Rutina));

                        await updateCommand.ExecuteNonQueryAsync();
                    }
                    else
                    {
                        // Insertar nuevo registro
                        using var insertCommand = connection.CreateCommand();
                        insertCommand.CommandText = "INSERT INTO TiempoUsuario (UsuarioId, Rutina, Segundos, FechaRegistro) VALUES (@usuarioId, @rutina, @segundos, @fecha)";
                        insertCommand.Parameters.Add(CreateParameter(insertCommand, "@usuarioId", tiempo.UsuarioId));
                        insertCommand.Parameters.Add(CreateParameter(insertCommand, "@rutina", tiempo.Rutina));
                        insertCommand.Parameters.Add(CreateParameter(insertCommand, "@segundos", tiempo.Segundos));
                        insertCommand.Parameters.Add(CreateParameter(insertCommand, "@fecha", DateTime.Now));

                        await insertCommand.ExecuteNonQueryAsync();
                    }
                }

                return Ok(new { success = true, message = "Tiempo guardado correctamente" });
            }
            catch (Exception ex)
            {
                return StatusCode(500, new { success = false, error = $"Error al guardar tiempo: {ex.Message}" });
            }
        }

        // GET: Obtener tiempo de un usuario para una rutina
        [HttpGet("{usuarioId}/{rutina}")]
        public async Task<IActionResult> ObtenerTiempo(int usuarioId, string rutina)
        {
            try
            {
                using var connection = _conexion.GetConnection();
                await connection.OpenAsync();

                using var command = connection.CreateCommand();
                command.CommandText = "SELECT Segundos FROM TiempoUsuario WHERE UsuarioId = @usuarioId AND Rutina = @rutina";
                command.Parameters.Add(CreateParameter(command, "@usuarioId", usuarioId));
                command.Parameters.Add(CreateParameter(command, "@rutina", rutina));

                var result = await command.ExecuteScalarAsync();
                int segundos = result != null ? Convert.ToInt32(result) : 0;

                return Ok(new { segundos });
            }
            catch (Exception ex)
            {
                return StatusCode(500, new { success = false, error = $"Error al obtener tiempo: {ex.Message}" });
            }
        }

        // GET: Obtener todos los tiempos de un usuario
        [HttpGet("{usuarioId}")]
        public async Task<IActionResult> ObtenerTodosLosTiempos(int usuarioId)
        {
            try
            {
                using var connection = _conexion.GetConnection();
                await connection.OpenAsync();

                using var command = connection.CreateCommand();
                command.CommandText = "SELECT Rutina, Segundos FROM TiempoUsuario WHERE UsuarioId = @usuarioId";
                command.Parameters.Add(CreateParameter(command, "@usuarioId", usuarioId));

                using var reader = await command.ExecuteReaderAsync();
                var tiempos = new Dictionary<string, int>();

                while (await reader.ReadAsync())
                {
                    string rutina = reader["Rutina"].ToString();
                    int segundos = Convert.ToInt32(reader["Segundos"]);
                    tiempos[rutina] = segundos;
                }

                return Ok(tiempos);
            }
            catch (Exception ex)
            {
                return StatusCode(500, new { success = false, error = $"Error al obtener tiempos: {ex.Message}" });
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