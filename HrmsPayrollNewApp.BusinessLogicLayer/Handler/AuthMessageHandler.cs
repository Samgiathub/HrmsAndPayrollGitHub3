namespace HrmsPayrollNewApp.BusinessLogicLayer.Handler
{
    public class AuthMessageHandler : DelegatingHandler
    {
        private readonly IConfiguration _configuration;

        public AuthMessageHandler(IConfiguration configuration)
        {
            _configuration = configuration;
        }

        protected override async Task<HttpResponseMessage> SendAsync(HttpRequestMessage request, CancellationToken cancellationToken)
        {
            string token = _configuration["ApiSettings:ApiMobileToken"]; // Fetch token dynamically if needed
            request.Headers.Authorization = new System.Net.Http.Headers.AuthenticationHeaderValue("Bearer", token);

            return await base.SendAsync(request, cancellationToken);
        }
    }
}
