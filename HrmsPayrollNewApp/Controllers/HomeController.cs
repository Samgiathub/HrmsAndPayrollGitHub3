using HrmsPayrollNewApp.Models;
using Microsoft.AspNetCore.Mvc;
using System.Diagnostics;

namespace HrmsPayrollNewApp.Controllers
{
  public class HomeController : Controller
  {
    private readonly ILogger<HomeController> _logger;
    public HomeController(ILogger<HomeController> logger)
    => (_logger) = (logger);

    public IActionResult Index()
    {
      return View();
    }

    #region Error handling using the Log

    ////public IActionResult Index()
    ////{

    ////  try
    ////  {
    ////    // Simulate an error
    ////    ////throw new Exception("Test exception");

    ////    // Simulate a divide by zero error :: DivideByZeroException
    ////    ////int numerator = 10;
    ////    ////int denominator = 0;
    ////    ////int result = numerator / denominator;

    ////    // Simulate a SQL error by executing a malformed query :: SqlException 
    ////    string connectionString = "Server=192.168.1.200;Database=Orange_Hrms_QA_312;User Id=sa;Password=orange505;Encrypt=False;TrustServerCertificate=True;";
    ////    using (var connection = new SqlConnection(connectionString))
    ////    {
    ////      connection.Open();
    ////      string invalidQuery = "SELECT * FROM NonExistentTable"; // This will throw a SQL error
    ////      using (var command = new SqlCommand(invalidQuery, connection))
    ////      {
    ////         command.ExecuteReader(); // This line will throw a SqlException
    ////      }
    ////    }
    ////  }
    ////  catch (Exception ex)
    ////  {
    ////    Log.Error(ex, "An error occurred while accessing the Index page");
    ////  }

    ////  return View();
    ////}    

    #endregion

    ////public IActionResult Privacy()
    ////{
    ////  return View();
    ////}

    [ResponseCache(Duration = 0, Location = ResponseCacheLocation.None, NoStore = true)]
    public IActionResult Error()
    {
      return View(new ErrorViewModel { RequestId = Activity.Current?.Id ?? HttpContext.TraceIdentifier });
    }
  }
}
