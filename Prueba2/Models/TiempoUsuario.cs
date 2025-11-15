using System;

namespace Prueba.Models
{
    public class TiempoUsuario
    {
        public int Id { get; set; } // Opcional, si quieres auto-incrementar en SQL Server
        public int UsuarioId { get; set; }
        public string Rutina { get; set; } = string.Empty;
        public int Segundos { get; set; }
        public DateTime FechaRegistro { get; set; } = DateTime.Now;
    }
}
