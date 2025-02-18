using HrmsPayrollNewApp.DataAccessLayer.Data;
namespace HrmsPayrollNewApp.BusinessLogicLayer.Interfaces
{
    public interface IAccountService
    {
        Task<decimal> GetUserByLoginName(string loginName);
    }
}
