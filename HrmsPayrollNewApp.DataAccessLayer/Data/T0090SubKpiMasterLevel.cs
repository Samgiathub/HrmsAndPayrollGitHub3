using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T0090SubKpiMasterLevel
{
    public decimal RowId { get; set; }

    public decimal CmpId { get; set; }

    public decimal TranId { get; set; }

    public decimal? KpiId { get; set; }

    public string? SubKpi { get; set; }

    public decimal? Weightage { get; set; }

    public virtual T0010CompanyMaster Cmp { get; set; } = null!;

    public virtual T0040KpiMaster? Kpi { get; set; }

    public virtual T0090EmpKpiApproval Tran { get; set; } = null!;
}
