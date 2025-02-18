using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T0095PerformanceImprovementPlanDetail
{
    public decimal EmpPipDetailId { get; set; }

    public decimal CmpId { get; set; }

    public decimal EmpId { get; set; }

    public decimal EmpPipId { get; set; }

    public string? ImprovementArea { get; set; }

    public string? Target { get; set; }

    public DateTime? StartDate { get; set; }

    public DateTime? EndDate { get; set; }

    public string? EmpFeedback { get; set; }

    public string? ManagerFeedback { get; set; }

    public virtual T0010CompanyMaster Cmp { get; set; } = null!;

    public virtual T0080EmpMaster Emp { get; set; } = null!;

    public virtual T0090PerformanceImprovementPlan EmpPip { get; set; } = null!;
}
