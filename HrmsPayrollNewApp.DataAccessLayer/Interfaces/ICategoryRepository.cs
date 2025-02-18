using HrmsPayrollNewApp.DataAccessLayer.Data;

namespace HrmsPayrollNewApp.DataAccessLayer.Interfaces
{
    public interface ICategoryRepository
    {
        Task<List<Category>> GetCategoriesAsync();
    }
}
