using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T0080KpiDevelopmentPlan
{
    public decimal KpiDevelopmentId { get; set; }

    public decimal CmpId { get; set; }

    public decimal? KpipmsId { get; set; }

    public decimal? EmpId { get; set; }

    public string? Strengths { get; set; }

    public string? DevelopmentAreas { get; set; }

    public string? ImprovementAction { get; set; }

    public string? Timeline { get; set; }

    public string? Status { get; set; }

    public virtual T0010CompanyMaster Cmp { get; set; } = null!;

    public virtual T0080EmpMaster? Emp { get; set; }

    public virtual T0080KpipmsEval? Kpipms { get; set; }
}
