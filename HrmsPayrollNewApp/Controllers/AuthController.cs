using System.Diagnostics;
using Microsoft.AspNetCore.Mvc;
using HrmsPayrollNewApp.Models;

namespace HrmsPayrollNewApp.Controllers;

public class AuthController : Controller
{
  public IActionResult ForgotPasswordBasic() => View();
  public IActionResult LoginBasic() => View();
  public IActionResult RegisterBasic() => View();
}
