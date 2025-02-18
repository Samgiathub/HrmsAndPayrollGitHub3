using HrmsPayrollNewApp.BusinessLogicLayer.Interfaces;
using HrmsPayrollNewApp.BusinessLogicLayer.Services;
using HrmsPayrollNewApp.DataAccessLayer;
using HrmsPayrollNewApp.DataAccessLayer.Interfaces;
using HrmsPayrollNewApp.DataAccessLayer.Repositories;
using Microsoft.AspNetCore.Server.Kestrel.Core;
using Microsoft.EntityFrameworkCore;
using Microsoft.AspNetCore.Authentication.JwtBearer;
using Microsoft.IdentityModel.Tokens;
using Microsoft.EntityFrameworkCore.Metadata.Internal;
using System.Text;
using Microsoft.Extensions.Configuration;
using HrmsPayrollNewApp.CommonLayer.Common;
using HrmsPayrollNewApp.WebApi.Controllers;
using HrmsPayrollNewApp.BusinessLogicLayer.MobileApiServices;
using HrmsPayrollNewApp.BusinessLogicLayer.Handler;
using HrmsPayrollNewApp.BusinessLogicLayer.InterfacesMobileApiServices;

var builder = WebApplication.CreateBuilder(args);

// Add services to the container.

// Add CORS service
builder.Services.AddCors(options =>
{
    options.AddPolicy("AllowLocalhost",
        policy => policy.WithOrigins("*") // Your Angular app URL
                        .AllowAnyMethod()
                        .AllowAnyHeader()                        
                        .AllowAnyOrigin());
});
builder.Services.AddHttpClient();

builder.Services.AddTransient<AuthMessageHandler>();
builder.Services.AddHttpClient<MobileApiService>()
    .AddHttpMessageHandler<AuthMessageHandler>();

builder.Services.AddHttpContextAccessor();
builder.Services.AddScoped<IMobileApiService, MobileApiService>();
builder.Services.AddControllers();
builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen();

// Register DbContext
builder.Services.AddDbContext<AppDbContext>(options =>
    options.UseSqlServer(builder.Configuration.GetConnectionString("DefaultConnection")));

builder.Services.AddScoped<IProductRepository, ProductRepository>();
builder.Services.AddScoped<IProductService, ProductService>();

builder.Services.Configure<KestrelServerOptions>(options =>
{
    options.Limits.KeepAliveTimeout = TimeSpan.FromMinutes(5);
    options.Limits.RequestHeadersTimeout = TimeSpan.FromMinutes(5);
});
var appSettingsSection = builder.Configuration.GetSection("AppSettings");
builder.Services.Configure<AppSettings>(appSettingsSection);
// Retrieve the settings to use them directly in the Program.cs
var appSettings = appSettingsSection.Get<AppSettings>();

var key = string.IsNullOrEmpty(appSettings?.JWTTokenGenKey)
    ? Encoding.ASCII.GetBytes("default-secret-key")  // fallback to a default key
    : Encoding.ASCII.GetBytes(appSettings.JWTTokenGenKey);

// Configure JWT Authentication
builder.Services.AddAuthentication(options =>
{
    options.DefaultAuthenticateScheme = JwtBearerDefaults.AuthenticationScheme;
    options.DefaultChallengeScheme = JwtBearerDefaults.AuthenticationScheme;
})
.AddJwtBearer(options =>
{
    options.TokenValidationParameters = new TokenValidationParameters
    {
        ValidateIssuerSigningKey = true,
        IssuerSigningKey = new SymmetricSecurityKey(key),
        ValidateIssuer = false,
        ValidateAudience = false,
        ValidateLifetime = true,
        RequireExpirationTime = true,
        ClockSkew = TimeSpan.Zero

        //ValidateIssuer = true,
        //ValidateAudience = true,
        //ValidateLifetime = true,
        //ValidateIssuerSigningKey = true,
        //ValidIssuer = "your-issuer",  // Replace with your issuer
        //ValidAudience = "your-audience",  // Replace with your audience
        //IssuerSigningKey = new SymmetricSecurityKey(System.Text.Encoding.UTF8.GetBytes("your-secret-key"))
    };
});

var app = builder.Build();

// Configure the HTTP request pipeline.
if (app.Environment.IsDevelopment())
{
    app.UseSwagger();
    app.UseSwaggerUI();
}

app.UseHttpsRedirection();

app.UseAuthorization();

app.UseCors(x => x
            .AllowAnyOrigin()
            .AllowAnyMethod()
            .AllowAnyHeader());


app.MapControllers();

app.Run();
