using HrmsPayrollNewApp.BusinessLogicLayer.InterfacesMobileApiServices;
using System.Text.Json;

namespace HrmsPayrollNewApp.BusinessLogicLayer.MobileApiServices
{
    public class MobileApiService : IMobileApiService
    {
        private readonly HttpClient _httpClient;
        private readonly IConfiguration _configuration;

        public MobileApiService(HttpClient httpClient, IConfiguration configuration)
        => (_httpClient, _configuration) = (httpClient, configuration);        

        public async Task<TResponse> CallApiAsync<TResponse>(string endpoint)
        {
            string? token = _configuration["ApiSettings:ApiMobileToken"];
            _httpClient.DefaultRequestHeaders.Authorization =
                new System.Net.Http.Headers.AuthenticationHeaderValue("Bearer", token);

            var response = await _httpClient.GetAsync(endpoint);
            response.EnsureSuccessStatusCode();

            var content = await response.Content.ReadAsStringAsync();
            return JsonSerializer.Deserialize<TResponse>(content)!;
        }
        public async Task<TResponse> GetAsync<TResponse>(string url, string token)
        {
            if (!string.IsNullOrEmpty(token))
            {
                _httpClient.DefaultRequestHeaders.Authorization =
                    new System.Net.Http.Headers.AuthenticationHeaderValue("Bearer", token.Replace("Bearer ", ""));
            }

            var response = await _httpClient.GetAsync(url);
            response.EnsureSuccessStatusCode();

            var content = await response.Content.ReadAsStringAsync();
            return JsonSerializer.Deserialize<TResponse>(content)!;
        }
    }
}
