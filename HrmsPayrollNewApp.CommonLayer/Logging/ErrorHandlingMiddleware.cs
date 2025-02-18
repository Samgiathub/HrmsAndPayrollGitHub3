using Serilog;

namespace HrmsPayrollNewApp.CommonLayer.Logging
{
    public class ErrorHandlingMiddleware
    {
        private readonly RequestDelegate _next;
        private readonly ILogger<ErrorHandlingMiddleware> _logger;

        public ErrorHandlingMiddleware(RequestDelegate next, ILogger<ErrorHandlingMiddleware> logger)
        => (_next, _logger) = (next, logger);

        public async Task InvokeAsync(HttpContext context)
        {
            try
            {
                await _next(context);
            }
            catch (Exception ex)
            {
                if (!ex.Data.Contains("Logged"))
                {
                    _logger.LogError(ex, "An unhandled exception occurred");
                    Log.Error(ex, "An unhandled exception occurred");
                    ex.Data["Logged"] = true;
                }

                throw;
            }
        }

    }

}
