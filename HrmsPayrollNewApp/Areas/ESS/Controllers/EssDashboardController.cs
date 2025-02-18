using Microsoft.AspNetCore.Mvc;

namespace HrmsPayrollNewApp.Areas.ESS.Controllers
{
  [Area("ESS")]
  public class EssDashboardController : Controller
  {
    public IActionResult Index()
    {
      return View();
    }
  }
}
