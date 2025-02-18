using HrmsPayrollNewApp.DataAccessLayer.Data;

namespace HrmsPayrollNewApp.BusinessLogicLayer.Interfaces
{
    public interface ICategoryService
    {
        Task<List<Category>> GetCategoriesAsync();
    }
}
