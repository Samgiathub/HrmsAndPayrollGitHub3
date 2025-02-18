using System.Diagnostics;
using Microsoft.AspNetCore.Mvc;
using HrmsPayrollNewApp.Models;

namespace HrmsPayrollNewApp.Controllers;

public class FormsController : Controller
{
  public IActionResult BasicInputs() => View();
  public IActionResult InputGroups() => View();
}
