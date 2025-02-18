using HrmsPayrollNewApp.BusinessLogicLayer.Interfaces;
using HrmsPayrollNewApp.DataAccessLayer;
using HrmsPayrollNewApp.DataAccessLayer.Data;
using HrmsPayrollNewApp.DataAccessLayer.Interfaces;

namespace HrmsPayrollNewApp.BusinessLogicLayer.Services
{
    public class ProductService : IProductService
    {        
        private readonly IProductRepository _productRepository;                 
        public ProductService(IProductRepository productRepository)
        {     
            _productRepository = productRepository;            
        }

        public async Task<IEnumerable<Product>> GetAllProductsAsync()
        {
            return await _productRepository.GetAllAsync();
        }

        public async Task<Product> GetProductByIdAsync(int id)
        {
            return await _productRepository.GetByIdAsync(id);
        }

        public async Task CreateProductAsync(Product product)
        {
            await _productRepository.AddAsync(product);
            await _productRepository.SaveAsync();
        }
        public async Task UpdateAsync(Product product)
        {
            await _productRepository.UpdateAsync(product);
        }
        public async Task UpdateProductAsync(Product product)
        {
            await _productRepository.UpdateProductAsync(product);
        }
        public async Task DeleteAsync(int id)
        { 
            await _productRepository.DeleteAsync(id);
        }
    }
}
