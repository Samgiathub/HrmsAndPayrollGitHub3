using HrmsPayrollNewApp.BusinessLogicLayer.Interfaces;
using HrmsPayrollNewApp.DataAccessLayer.Data;
using Microsoft.AspNetCore.Cors;
using Microsoft.AspNetCore.Mvc;
using System;
using System.Text.Json;

namespace HrmsPayrollNewApp.WebApi.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    public class ProductsApiController : ControllerBase
    {        
        private readonly IProductService _productService;
        public ProductsApiController(IProductService productService)
        {            
            _productService = productService;
        }

        // GET: api/products
        [HttpGet]
        public IActionResult GetProducts()
        {
            var products = _productService.GetAllProductsAsync();            
            var jsonProductsString = JsonSerializer.Serialize(products);

            return Ok(jsonProductsString);  
        }

        // GET: api/products/{id}
        [HttpGet("{id}")]
        public IActionResult GetProduct(int id)
        {
            var product = _productService.GetProductByIdAsync(id);
            var jsonProductString = JsonSerializer.Serialize(product);
            if (jsonProductString == null)
                return NotFound();

            return Ok(jsonProductString);
        }

        // POST: api/products
        [HttpPost]
        public IActionResult AddProduct([FromBody] Product product)
        {
            if (product == null)
                return BadRequest("Invalid product data");
            var createdProduct = _productService.CreateProductAsync(product);
            return CreatedAtAction(nameof(GetProduct), new { id = product.Id }, product);
        }

        //PUT: api/products/{id}
        //[HttpPut("{id}")]
        //public IActionResult UpdateProduct(int id, [FromBody] Product updatedProduct)
        //{
        //    if (updatedProduct == null)
        //        return BadRequest("Invalid product data");

        //    try
        //    {
        //        //_productService.UpdateAsync(updatedProduct);
        //        _productService.UpdateProductAsync(updatedProduct);
        //        return NoContent();
        //    }
        //    catch (Exception ex)
        //    {
        //        return NotFound(ex.Message);
        //    }
        //}

        // DELETE: api/products/{id}
        //[HttpDelete("{id}")]
        //public IActionResult DeleteProduct(int id)
        //{
        //    try
        //    {
        //        _productService.DeleteAsync(id);
        //        return NoContent();
        //    }
        //    catch (Exception ex)
        //    {
        //        return NotFound(ex.Message);
        //    }
        //}
    }
}
