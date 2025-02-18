using HrmsPayrollNewApp.BusinessLogicLayer.Interfaces;
using HrmsPayrollNewApp.DataAccessLayer.Data;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using System.Security.Cryptography;
using System.Text;

namespace HrmsPayrollNewApp.Controllers
{
  public class AccountController : Controller
  {
    private readonly IAccountService _accountService;

    public AccountController(IAccountService accountService)
    {
      _accountService = accountService;
    }
    public IActionResult Index()
    {
      return View();
    }
    /// <summary>
    /// Here will be do login / logout / forwoard password / remember me features, right now just redirection 
    /// </summary>
    /// <returns></returns>
    [HttpPost]
    public async Task<IActionResult> Login()
    {
      string? email = !string.IsNullOrEmpty(Request.Form["email-username"]) ? Request.Form["email-username"] : string.Empty;
      string? password = !string.IsNullOrEmpty(Request.Form["password"]) ? Request.Form["password"] : string.Empty;

      if (!string.IsNullOrEmpty(email) && !string.IsNullOrEmpty(password))
      {
        var getIsDefault = await _accountService.GetUserByLoginName(email);
        if (getIsDefault == 1)
        {
          return RedirectToAction(actionName: "index", controllerName: "admindashboard", new { area = "admin" });
        }
        else if (getIsDefault == 2)
        {
          return RedirectToAction(actionName: "Index", controllerName: "EssDashboard", new { area = "ESS" });
        }
        else
        {
          return RedirectToAction(actionName: "Index", controllerName: "Account");
        }
      }
      return RedirectToAction(actionName: "Index", controllerName: "Account");
    }
  }
}
