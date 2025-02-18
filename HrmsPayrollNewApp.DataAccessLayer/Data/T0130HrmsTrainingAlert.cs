using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T0130HrmsTrainingAlert
{
    public decimal TranAlertId { get; set; }

    public decimal TrainingAprId { get; set; }

    public decimal? DeptId { get; set; }

    public decimal? EmpId { get; set; }

    public string? Comments { get; set; }

    public decimal? AlertsStartDays { get; set; }

    public decimal? AlertsDays { get; set; }

    public decimal CmpId { get; set; }

    public virtual T0010CompanyMaster Cmp { get; set; } = null!;

    public virtual T0040DepartmentMaster? Dept { get; set; }

    public virtual T0080EmpMaster? Emp { get; set; }
}
