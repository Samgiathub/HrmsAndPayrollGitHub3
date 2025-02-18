using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T0100KpiDevelopmentPlanLevel
{
    public decimal RowId { get; set; }

    public decimal CmpId { get; set; }

    public decimal? TranId { get; set; }

    public string? Strengths { get; set; }

    public string? DevelopmentAreas { get; set; }

    public string? ImprovementAction { get; set; }

    public string? Timeline { get; set; }

    public string? Status { get; set; }

    public virtual T0010CompanyMaster Cmp { get; set; } = null!;

    public virtual T0090KpipmsEvalApproval? Tran { get; set; }
}
