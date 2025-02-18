using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class V0090EmpReportingDetailGetBackup22032022
{
    public decimal RowId { get; set; }

    public decimal EmpId { get; set; }

    public decimal? REmpId { get; set; }

    public decimal CmpId { get; set; }

    public string ReportingTo { get; set; } = null!;

    public string ReportingMethod { get; set; } = null!;

    public string? AlphaEmpCode { get; set; }

    public string? EmpFullName { get; set; }

    public string? REmpFullName { get; set; }

    public decimal BranchId { get; set; }

    public string? BranchName { get; set; }

    public string? DateOfJoin { get; set; }

    public string ECmp { get; set; } = null!;

    public string CmpName { get; set; } = null!;

    public string ReportingManagerDesignation { get; set; } = null!;

    public string? EffectDate { get; set; }

    public DateTime? EffectDateOrder { get; set; }
}
