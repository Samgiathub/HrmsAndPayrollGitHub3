using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T0100KpiobjectivesLevel
{
    public decimal RowId { get; set; }

    public decimal CmpId { get; set; }

    public decimal TranId { get; set; }

    public decimal? KpiAttId { get; set; }

    public string? Objective { get; set; }

    public string? Metric { get; set; }

    public virtual T0010CompanyMaster Cmp { get; set; } = null!;

    public virtual T0040EmpKpiMaster? KpiAtt { get; set; }

    public virtual T0090EmpKpiApproval Tran { get; set; } = null!;
}
