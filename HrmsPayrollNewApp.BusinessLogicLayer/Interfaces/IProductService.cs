using HrmsPayrollNewApp.DataAccessLayer.Data;

namespace HrmsPayrollNewApp.BusinessLogicLayer.Interfaces
{
    public interface IProductService
    {
        Task<IEnumerable<Product>> GetAllProductsAsync();
        Task<Product> GetProductByIdAsync(int id);
        Task CreateProductAsync(Product product);
        Task UpdateAsync(Product product);
        Task UpdateProductAsync(Product product);
        Task DeleteAsync(int id);
    }
}
