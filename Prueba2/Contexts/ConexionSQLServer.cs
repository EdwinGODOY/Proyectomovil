using Microsoft.Data.SqlClient;
using System.Data.Common;

namespace Prueba.Contexts
{
    public class ConexionSQLServer  // Solo un 'public'
    {
        private readonly string _connectionString;

        public ConexionSQLServer(string connectionString)  // Solo un 'public'
        {
            _connectionString = connectionString ?? throw new ArgumentNullException(nameof(connectionString));
        }

        public DbConnection GetConnection()  // Solo un 'public'
        {
            return new SqlConnection(_connectionString);
        }
    }
}