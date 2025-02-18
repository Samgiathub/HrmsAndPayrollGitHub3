using HrmsPayrollNewApp.BusinessLogicLayer.InterfacesMobileApiServices;
using HrmsPayrollNewApp.CommonLayer.ViewModels;
using Microsoft.AspNetCore.Mvc;
using Newtonsoft.Json;
using Newtonsoft.Json.Linq;

namespace HrmsPayrollNewApp.WebApi.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    public class MobileApiController : ControllerBase
    {
        private readonly IMobileApiService _mobileApiService;
        private readonly IConfiguration _configuration;

        public MobileApiController(IMobileApiService mobileApiService, IConfiguration configuration)
        => (_mobileApiService, _configuration) = (mobileApiService, configuration);        

        ////public MobileApiController(IMobileApiService mobileApiService, IConfiguration configuration)
        ////{            
        ////    _mobileApiService = mobileApiService;
        ////    _configuration = configuration;
        ////}
        
        [HttpGet("Mobile-EmployeeDetails")]
        public async Task<IActionResult> CallMobileApplication()
        {   
            try
            {
                var token = _configuration["AppSettings:ApiMobileToken"] ?? throw new InvalidOperationException("API token is missing.");
                var response = await _mobileApiService.GetAsync<dynamic>(
                    _configuration["AppSettings:ApiMobileBaseUrl"] + "EmployeeDetails",
                    token
                );

                string strResponse = Convert.ToString(response);
                
                JObject jsonObject = JObject.Parse(strResponse);
                int code = jsonObject["code"]?.ToObject<int>() ?? 0;
                bool status = jsonObject["status"]?.ToObject<bool>() ?? false;
                string message = jsonObject["message"]?.ToObject<string>() ?? string.Empty;                

                ResponseViewModel responseViewModel = new ResponseViewModel();
                if (code == 200)
                {
                    responseViewModel.code = code;
                    responseViewModel.status = status;
                    responseViewModel.message = message;
                    
                    return Ok(strResponse);
                }
                else
                {
                    return StatusCode((int)response.StatusCode, "Error calling Application A");
                }
            }
            catch (Exception ex)
            {                
                return StatusCode(500, $"Internal server error: {ex.Message}");
            }
        }
    }
}
