using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T0095EmployeeGoalSettingDetail
{
    public decimal EmpGoalSettingDetailId { get; set; }

    public decimal CmpId { get; set; }

    public decimal EmpGoalSettingId { get; set; }

    public decimal EmpId { get; set; }

    public string? Kra { get; set; }

    public string? Kpi { get; set; }

    public string? Target { get; set; }

    public decimal? Weight { get; set; }

    public int KpaTypeId { get; set; }

    public virtual T0010CompanyMaster Cmp { get; set; } = null!;

    public virtual T0080EmpMaster Emp { get; set; } = null!;

    public virtual T0090EmployeeGoalSetting EmpGoalSetting { get; set; } = null!;

    public virtual ICollection<T0100EmployeeGoalSettingEvaluationDetail> T0100EmployeeGoalSettingEvaluationDetails { get; set; } = new List<T0100EmployeeGoalSettingEvaluationDetail>();

    public virtual ICollection<T0115EmployeeGoalSettingDetailsLevel> T0115EmployeeGoalSettingDetailsLevels { get; set; } = new List<T0115EmployeeGoalSettingDetailsLevel>();

    public virtual ICollection<T0115EmployeeGoalSettingEvaluationDetailsLevel> T0115EmployeeGoalSettingEvaluationDetailsLevels { get; set; } = new List<T0115EmployeeGoalSettingEvaluationDetailsLevel>();
}
