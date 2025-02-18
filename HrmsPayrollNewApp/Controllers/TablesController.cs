using System.Diagnostics;
using Microsoft.AspNetCore.Mvc;
using HrmsPayrollNewApp.Models;

namespace HrmsPayrollNewApp.Controllers;

public class TablesController : Controller
{
  public IActionResult Basic() => View();
}
