using HrmsPayrollNewApp.BusinessLogicLayer.Interfaces;
using HrmsPayrollNewApp.DataAccessLayer.Data;
using Microsoft.AspNetCore.Mvc;

namespace HrmsPayrollNewApp.Controllers
{
    public class CategoryController : Controller
    {
        private readonly ICategoryService _categoryService;
        public CategoryController(ICategoryService categoryService)
        { 
            _categoryService = categoryService;
        }
        public async Task<IActionResult> Index()
        {
            var categories= await _categoryService.GetCategoriesAsync();
            return View(categories);
        }
    }
}
