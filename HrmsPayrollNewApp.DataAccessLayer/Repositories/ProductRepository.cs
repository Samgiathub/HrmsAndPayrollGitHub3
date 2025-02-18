using HrmsPayrollNewApp.DataAccessLayer.Data;
using HrmsPayrollNewApp.DataAccessLayer.Interfaces;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.DependencyInjection;

namespace HrmsPayrollNewApp.DataAccessLayer.Repositories
{
    public class ProductRepository : IProductRepository
    {
        private readonly AppDbContext _context;

        public ProductRepository(AppDbContext context)
        => (_context) = (context);

        public async Task<IEnumerable<Product>> GetAllAsync()
        {
            return await _context.Products.ToListAsync();
        }

        public async Task<Product> GetByIdAsync(int id)
        {
            var product = await _context.Products.FirstOrDefaultAsync(p => p.Id == id)
                ?? throw new InvalidOperationException($"Product with ID {id} not found.");

            return product;


            ////var query = from p in _context.Products
            ////            where p.Id == id
            ////            select p;
            ////return await query.FirstOrDefaultAsync();
        }

        public async Task AddAsync(Product product)
        {
            await _context.Products.AddAsync(product);
        }

        public async Task SaveAsync()
        {
            await _context.SaveChangesAsync();
        }
        public async Task UpdateAsync(Product product)
        {
            using var transaction = await _context.Database.BeginTransactionAsync();

            try
            {
                _context.Products.Update(product);
                await _context.SaveChangesAsync();
                await transaction.CommitAsync();
            }
            catch
            {
                await transaction.RollbackAsync();
                throw;
            }
        }
        public async Task UpdateProductAsync(Product product)
        {
            var existingProduct = await _context.Products
                                 .Where(p => p.Id == product.Id)
                                 .FirstOrDefaultAsync()
                                 ?? throw new KeyNotFoundException("Product not found.");

            existingProduct.ProductName = product.ProductName;
            existingProduct.Price = product.Price;

            // Save changes with transaction
            using var transaction = await _context.Database.BeginTransactionAsync();
            try
            {
                _context.Products.Update(product);
                await _context.SaveChangesAsync();
                await transaction.CommitAsync();
            }
            catch
            {
                await transaction.RollbackAsync();
            }
        }

        public async Task DeleteAsync(int id)
        {
            using var transaction = await _context.Database.BeginTransactionAsync();
            try
            {
                var product = await _context.Products.FindAsync(id);
                if (product != null)
                {
                    _context.Products.Remove(product);
                    await _context.SaveChangesAsync();
                    await transaction.CommitAsync();
                }
            }
            catch
            {
                await transaction.RollbackAsync();
                throw;
            }
        }
    }
}
