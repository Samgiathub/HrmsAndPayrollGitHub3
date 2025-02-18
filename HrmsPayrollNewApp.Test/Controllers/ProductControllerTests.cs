using HrmsPayrollNewApp.BusinessLogicLayer.Interfaces;
using HrmsPayrollNewApp.Controllers;
using HrmsPayrollNewApp.DataAccessLayer.Data;
using Microsoft.AspNetCore.Mvc;
using Moq;

namespace HrmsPayrollNewApp.Test.Controllers
{
    public class ProductControllerTests
    {
        [Fact]
        public async Task Details_ReturnsViewResult_WithProduct()
        {
            // Arrange
            var mockService = new Mock<IProductService>();
            var testProduct = new Product { Id = 1, ProductName = "Test Product" };
            mockService.Setup(service => service.GetProductByIdAsync(1))
                       .ReturnsAsync(testProduct);

            var controller = new ProductsController(mockService.Object);

            // Act
            var result = await controller.Details(1);

            // Assert
            var viewResult = Assert.IsType<ViewResult>(result);
            var model = Assert.IsAssignableFrom<Product>(viewResult.Model);
            Assert.Equal(testProduct, model);
        }

        [Fact]
        public async Task Details_ReturnsNotFound_WhenProductDoesNotExist()
        {
            // Arrange
            var mockService = new Mock<IProductService>();
            mockService.Setup(service => service.GetProductByIdAsync(1))
                       .ReturnsAsync((Product)null);

            var controller = new ProductsController(mockService.Object);

            // Act
            var result = await controller.Details(1);

            // Assert
            Assert.IsType<NotFoundResult>(result);
        }
    }
}
