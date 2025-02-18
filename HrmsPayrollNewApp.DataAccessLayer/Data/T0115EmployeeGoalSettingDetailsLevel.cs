using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T0115EmployeeGoalSettingDetailsLevel
{
    public decimal TranId { get; set; }

    public decimal? CmpId { get; set; }

    public decimal? EmpId { get; set; }

    public decimal? EmpGoalSettingDetailId { get; set; }

    public string? Kra { get; set; }

    public string? Kpi { get; set; }

    public string? Target { get; set; }

    public decimal? Weight { get; set; }

    public byte? RptLevel { get; set; }

    public decimal? EgsLevelId { get; set; }

    public virtual T0010CompanyMaster? Cmp { get; set; }

    public virtual T0110EmployeeGoalSettingApproval? EgsLevel { get; set; }

    public virtual T0080EmpMaster? Emp { get; set; }

    public virtual T0095EmployeeGoalSettingDetail? EmpGoalSettingDetail { get; set; }
}
