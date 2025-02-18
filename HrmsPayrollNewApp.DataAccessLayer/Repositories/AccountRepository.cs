using HrmsPayrollNewApp.DataAccessLayer.Data;
using HrmsPayrollNewApp.DataAccessLayer.Interfaces;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Caching.Memory;
namespace HrmsPayrollNewApp.DataAccessLayer.Repositories
{
    public class AccountRepository : IAccountRepository
    {
        private readonly AppDbContext _context;
        private readonly IMemoryCache _cache;
        public AccountRepository(AppDbContext context, IMemoryCache cache)
        => (_context, _cache) = (context, cache);
        /// <summary>
        /// Here cache use for the check admin / ess redirection value of IsDefault
        /// </summary>
        /// <param name="loginName"></param>
        /// <returns></returns>
        /// <exception cref="InvalidOperationException"></exception>
        public async Task<decimal> GetUserIdByLoginName(string loginName)
        {
            var cacheKey = $"IsDefault_{loginName}";

            // Check if the value is in the cache
            if (_cache.TryGetValue(cacheKey, out decimal cachedIsDefault))
            {
                return cachedIsDefault;  // Return from cache if found
            }

            // If not in cache, query the database
            var isDetault = await _context.T0011Logins
                .Where(x => x.LoginName == loginName)
                .Select(x => x.IsDefault)  // Assuming you want the UserId
                .FirstOrDefaultAsync()
                ?? throw new InvalidOperationException($"Login name {loginName} not found.");

            // Store the result in the cache for future use
            _cache.Set(cacheKey, isDetault, TimeSpan.FromMinutes(30));  // Cache for 30 minutes

            return isDetault;
        }
    }
}
