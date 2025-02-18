using HrmsPayrollNewApp.BusinessLogicLayer.Interfaces;
using HrmsPayrollNewApp.BusinessLogicLayer.Services;
using HrmsPayrollNewApp.CommonLayer.Logging;
using HrmsPayrollNewApp.DataAccessLayer;
using HrmsPayrollNewApp.DataAccessLayer.Interfaces;
using HrmsPayrollNewApp.DataAccessLayer.Repositories;
using Microsoft.EntityFrameworkCore;
using Serilog;
using Serilog.Events;
using Serilog.Sinks.MSSqlServer;
using static Serilog.Sinks.MSSqlServer.ColumnOptions;
var builder = WebApplication.CreateBuilder(args);
// Register IHttpContextAccessor :: Add Http Context Accessor
// Test comment for the testing purpose for git hub server repository

builder.Services.AddHttpContextAccessor();
// Add services to the container.
builder.Services.AddControllersWithViews();
builder.Services.AddDbContext<AppDbContext>(options =>
{
    var connectionString = builder.Configuration.GetConnectionString("DefaultConnection");
    options.UseSqlServer(connectionString);
});
builder.Services.AddMemoryCache();
builder.Services.AddScoped<IProductRepository, ProductRepository>();
builder.Services.AddScoped<IProductService, ProductService>();
builder.Services.AddScoped<ICategoryRepository, CategoryRepository>();
builder.Services.AddScoped<ICategoryService, CategoryService>();
builder.Services.AddScoped<IAccountRepository, AccountRepository>();
builder.Services.AddScoped<IAccountService, AccountService>();
// Configure Serilog
Log.Logger = new LoggerConfiguration()
    .WriteTo.Console() // Optional: Log to console
    .WriteTo.MSSqlServer(
        connectionString: builder.Configuration.GetConnectionString("DefaultConnection"), 
        sinkOptions: new MSSqlServerSinkOptions
        {
            TableName = "Logs",
            AutoCreateSqlTable = true // Creates table if it doesn't exist
        },
        columnOptions: new ColumnOptions(),
        restrictedToMinimumLevel: Serilog.Events.LogEventLevel.Error // Log only errors and above
    )
    .CreateLogger();

// Add Serilog to the logging pipeline
builder.Host.UseSerilog();
builder.Services.AddRazorPages();
builder.Services.AddLogging();
builder.Services.AddControllersWithViews();

var app = builder.Build();
if (app.Environment.IsDevelopment())
{
    app.UseDeveloperExceptionPage();
}
else
{
    app.UseExceptionHandler("/Home/Error");
    app.UseHsts();
}
app.UseSerilogRequestLogging();
app.UseHttpsRedirection();


// Middleware to prevent caching for all responses (including dynamic content)
app.Use(async (context, next) =>
{
  // Prevent caching for dynamic content
  context.Response.Headers["Cache-Control"] = "no-cache, no-store, must-revalidate";
  context.Response.Headers["Pragma"] = "no-cache";  // For HTTP/1.0
  context.Response.Headers["Expires"] = "0";        // Ensure the response is expired

  await next();
});

// Serve static files with custom cache-control headers
app.UseStaticFiles(new StaticFileOptions
{
  OnPrepareResponse = context =>
  {
    // Prevent caching for static files (CSS, JS, Images)
    context.Context.Response.Headers["Cache-Control"] = "no-cache, no-store, must-revalidate";
    context.Context.Response.Headers["Pragma"] = "no-cache";  // For HTTP/1.0
    context.Context.Response.Headers["Expires"] = "0";        // Ensure the response is expired
  }
});


app.UseRouting();
app.MapRazorPages();

app.UseAuthorization();

app.MapAreaControllerRoute(
        name: "Admin",
        areaName: "Admin",
        pattern: "Admin/{controller=AdminDashboard}/{action=Index}"
    );

app.MapAreaControllerRoute(
        name: "ESS",
        areaName: "ESS",
        pattern: "ESS/{controller=EssDashboard}/{action=Index}"
    );

app.MapControllerRoute(
    name: "areaRoute",
    pattern: "{area:exists}/{controller}/{action}"
);

app.MapControllerRoute(
    name: "default",
    pattern: "{controller=Account}/{action=Index}/{id?}"    
);

await app.RunAsync();
