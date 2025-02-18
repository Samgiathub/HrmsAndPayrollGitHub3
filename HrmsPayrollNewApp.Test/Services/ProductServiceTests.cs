using HrmsPayrollNewApp.BusinessLogicLayer.Services;
using HrmsPayrollNewApp.DataAccessLayer.Data;
using HrmsPayrollNewApp.DataAccessLayer.Interfaces;
using Moq;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace HrmsPayrollNewApp.Test.Services
{
    public class ProductServiceTests
    {
        [Fact]
        public async Task GetProductByIdAsync_ReturnsProduct_WhenProductExists()
        {
            // Arrange
            var mockRepository = new Mock<IProductRepository>();
            var testProduct = new Product { Id = 1, ProductName = "Test Product" };
            mockRepository.Setup(repo => repo.GetByIdAsync(1))
                          .ReturnsAsync(testProduct);

            var service = new ProductService(mockRepository.Object);

            // Act
            var result = await service.GetProductByIdAsync(1);

            // Assert
            Assert.NotNull(result);
            Assert.Equal(testProduct, result);
        }

        [Fact]
        public async Task GetProductByIdAsync_ReturnsNull_WhenProductDoesNotExist()
        {
            // Arrange
            #nullable enable
            
            #pragma warning disable CS8620  // Disable the specific nullable warning
            
                        var mockRepository = new Mock<IProductRepository>();
                        mockRepository.Setup(repo => repo.GetByIdAsync(1))
                                      .ReturnsAsync((Product?)null);
            
            #pragma warning restore CS8620  // Re-enable the warning


            var service = new ProductService(mockRepository.Object);

            // Act
            var result = await service.GetProductByIdAsync(1);

            // Assert
            Assert.Null(result);
        }
    }
}
