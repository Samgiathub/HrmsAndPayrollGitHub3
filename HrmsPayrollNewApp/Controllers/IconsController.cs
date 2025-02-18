using System.Diagnostics;
using Microsoft.AspNetCore.Mvc;
using HrmsPayrollNewApp.Models;

namespace HrmsPayrollNewApp.Controllers;

public class IconsController : Controller
{
  public IActionResult Boxicons() => View();
}
