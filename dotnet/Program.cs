using Microsoft.AspNetCore.Builder;
using Microsoft.Extensions.Hosting;

var builder = WebApplication.CreateBuilder(args);
var app = builder.Build();

app.MapGet("/", () => "Hello from LangRace .NET!");

app.MapGet("/benchmark", () =>
{
    var start = DateTime.UtcNow;
    double total = 0;
    for (int i = 0; i < 100_000_000; i++)
        total += Math.Sqrt(i);
    var elapsed = DateTime.UtcNow - start;
    return new { language = ".NET", duration_ms = elapsed.TotalMilliseconds, result = total };
});

app.Run("http://0.0.0.0:8084");
