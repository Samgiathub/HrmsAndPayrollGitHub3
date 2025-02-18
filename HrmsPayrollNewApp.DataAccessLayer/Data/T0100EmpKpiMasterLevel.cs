using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T0100EmpKpiMasterLevel
{
    public decimal RowId { get; set; }

    public decimal? CmpId { get; set; }

    public decimal? TranId { get; set; }

    public decimal? SubKpiid { get; set; }

    public decimal? EmpId { get; set; }

    public string? Kpi { get; set; }

    public decimal? Weightage { get; set; }

    public virtual T0010CompanyMaster? Cmp { get; set; }

    public virtual T0080EmpMaster? Emp { get; set; }

    public virtual T0080SubKpiMaster? SubKpi { get; set; }

    public virtual T0090EmpKpiApproval? Tran { get; set; }
}
