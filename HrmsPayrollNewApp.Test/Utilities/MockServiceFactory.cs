using HrmsPayrollNewApp.BusinessLogicLayer.Interfaces;
using HrmsPayrollNewApp.DataAccessLayer.Data;
using Moq;
namespace HrmsPayrollNewApp.Test.Utilities
{
    public static class MockServiceFactory
    {
        public static Mock<IProductService> CreateMockProductService()
        {
            var mockService = new Mock<IProductService>();
            mockService.Setup(service => service.GetProductByIdAsync(It.IsAny<int>()))
                       .ReturnsAsync((int id) => new Product { Id = id, ProductName = $"Product {id}" });

            return mockService;
        }
    }
}
