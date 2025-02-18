using Microsoft.EntityFrameworkCore;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using HrmsPayrollNewApp.DataAccessLayer;

namespace HrmsPayrollNewApp.Test.Repositories
{
    public class ProductRepositoryTests
    {
        [Fact]
        public async Task GetByIdAsync_ReturnsProduct_WhenProductExists()
        {
            // Arrange
            var options = new DbContextOptionsBuilder<AppDbContext>()
                //.UseInMemoryDatabase(databaseName: "HrmsPayrollDb")
                .Options;

            using var context = new AppDbContext(options);
            await context.Database.ExecuteSqlRawAsync("SET IDENTITY_INSERT Products ON;");
            var repository = new HrmsPayrollNewApp.DataAccessLayer.Repositories.ProductRepository(context);            
            var testProduct = new DataAccessLayer.Data.Product { ProductName = "Product PPP",Price= 55.5m};
            context.Products.Add(testProduct);
            await context.SaveChangesAsync();
            await context.Database.ExecuteSqlRawAsync("SET IDENTITY_INSERT Products OFF;");
            // Act
            var result = await repository.GetByIdAsync(testProduct.Id);

            // Assert
            Assert.NotNull(result);
            Assert.Equal(testProduct, result);
        }

        ////[Fact]
        ////public async Task GetByIdAsync_ReturnsNull_WhenProductDoesNotExist()
        ////{
        ////    // Arrange
        ////    var options = new DbContextOptionsBuilder<AppDbContext>()
        ////        //.UseInMemoryDatabase(databaseName: "HrmsPayrollDb")
        ////        .Options;

        ////    using var context = new AppDbContext(options);
        ////    var repository = new HrmsPayrollNewApp.DataAccessLayer.Repositories.ProductRepository(context);

        ////    // Act
        ////    var result = await repository.GetByIdAsync(1);

        ////    // Assert
        ////    Assert.Null(result);
        ////}
    }
}
