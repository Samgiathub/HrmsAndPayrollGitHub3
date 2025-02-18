using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T0090EmpReportingDetail
{
    public decimal RowId { get; set; }

    public decimal EmpId { get; set; }

    public decimal? REmpId { get; set; }

    public decimal CmpId { get; set; }

    public string ReportingTo { get; set; } = null!;

    public string ReportingMethod { get; set; } = null!;

    public DateTime? EffectDate { get; set; }

    public virtual T0010CompanyMaster Cmp { get; set; } = null!;

    public virtual T0080EmpMaster Emp { get; set; } = null!;

    public virtual T0080EmpMaster? REmp { get; set; }
}
