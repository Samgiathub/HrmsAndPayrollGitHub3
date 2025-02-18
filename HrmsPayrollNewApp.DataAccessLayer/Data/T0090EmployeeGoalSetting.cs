using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T0090EmployeeGoalSetting
{
    public decimal EmpGoalSettingId { get; set; }

    public decimal CmpId { get; set; }

    public decimal EmpId { get; set; }

    public decimal EgsStatus { get; set; }

    public int FinYear { get; set; }

    public DateTime CreatedDate { get; set; }

    public decimal CreatedBy { get; set; }

    public DateTime? ModifiedDate { get; set; }

    public decimal? ModifiedBy { get; set; }

    public string? EmpComment { get; set; }

    public string? ManagerComment { get; set; }

    public virtual T0010CompanyMaster Cmp { get; set; } = null!;

    public virtual T0080EmpMaster Emp { get; set; } = null!;

    public virtual ICollection<T0095EmployeeGoalSettingDetail> T0095EmployeeGoalSettingDetails { get; set; } = new List<T0095EmployeeGoalSettingDetail>();

    public virtual ICollection<T0110EmployeeGoalSettingApproval> T0110EmployeeGoalSettingApprovals { get; set; } = new List<T0110EmployeeGoalSettingApproval>();
}
