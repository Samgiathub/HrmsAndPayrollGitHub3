using HrmsPayrollNewApp.DataAccessLayer.Data;

namespace HrmsPayrollNewApp.DataAccessLayer.Interfaces
{
    public interface IProductRepository
    {
        Task<IEnumerable<Product>> GetAllAsync();
        Task<Product> GetByIdAsync(int id);
        Task AddAsync(Product product);
        Task UpdateAsync(Product product);
        Task UpdateProductAsync(Product product);
        Task DeleteAsync(int id);
        Task SaveAsync();        
    }
}
