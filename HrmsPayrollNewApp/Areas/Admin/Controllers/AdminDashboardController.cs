using Microsoft.AspNetCore.Mvc;

namespace HrmsPayrollNewApp.Areas.Admin.Controllers
{
  [Area("Admin")]
  public class AdminDashboardController : Controller
  {
    public AdminDashboardController()
    {

    }
    public IActionResult Index()
    {
      return View();
    }
  }
}
