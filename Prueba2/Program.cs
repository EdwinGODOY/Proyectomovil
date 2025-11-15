using Prueba.Contexts;

var builder = WebApplication.CreateBuilder(args);

// Add services to the container.
builder.Services.AddControllers();

// Configurar Swagger
builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen(c =>
{
    c.SwaggerDoc("v1", new Microsoft.OpenApi.Models.OpenApiInfo
    {
        Title = "Prueba API",
        Version = "v1",
        Description = "API para gestión de usuarios"
    });
});

// Registrar la conexión a SQL Server - USANDO EL NOMBRE CORRECTO
var connectionString = builder.Configuration.GetConnectionString("CadenaConexionSQLServer");

if (string.IsNullOrEmpty(connectionString))
{
    throw new InvalidOperationException("No se encontró la cadena de conexión 'CadenaConexionSQLServer'");
}

Console.WriteLine($"Cadena de conexión encontrada correctamente");
builder.Services.AddSingleton(new ConexionSQLServer(connectionString));

var app = builder.Build();

// Configure the HTTP request pipeline.
if (app.Environment.IsDevelopment())
{
    app.UseSwagger();
    app.UseSwaggerUI(c =>
    {
        c.SwaggerEndpoint("/swagger/v1/swagger.json", "Prueba API v1");
        c.RoutePrefix = "swagger";
    });
}

app.UseRouting();
app.MapControllers();

app.Run();