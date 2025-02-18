using HrmsPayrollNewApp.DataAccessLayer.Data;
namespace HrmsPayrollNewApp.DataAccessLayer.Interfaces
{
    public interface IAccountRepository
    {
        Task<decimal> GetUserIdByLoginName(string loginName);
    }
}
