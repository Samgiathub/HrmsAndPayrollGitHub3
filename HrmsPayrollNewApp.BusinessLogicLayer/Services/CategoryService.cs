using HrmsPayrollNewApp.BusinessLogicLayer.Interfaces;
using HrmsPayrollNewApp.DataAccessLayer.Data;
using HrmsPayrollNewApp.DataAccessLayer.Interfaces;

namespace HrmsPayrollNewApp.BusinessLogicLayer.Services
{
    public class CategoryService : ICategoryService
    {
        private readonly ICategoryRepository _categoryRepository;
        public CategoryService(ICategoryRepository categoryRepository) 
        { 
            _categoryRepository = categoryRepository;
        }
        public async Task<List<Category>> GetCategoriesAsync()
        {
            return await _categoryRepository.GetCategoriesAsync();
        }
    }
}
