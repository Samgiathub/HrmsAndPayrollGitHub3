namespace HrmsPayrollNewApp.BusinessLogicLayer.InterfacesMobileApiServices
{
    public interface IMobileApiService
    {
        Task<TResponse> CallApiAsync<TResponse>(string endpoint);
        Task<TResponse> GetAsync<TResponse>(string url, string token);
    }
}
