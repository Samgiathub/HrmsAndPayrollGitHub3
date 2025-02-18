using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class V0140AdvanceSummary
{
    public decimal EmpId { get; set; }

    public decimal CmpId { get; set; }

    public string? AlphaEmpCode { get; set; }

    public string? EmpFullName { get; set; }

    public string? BranchName { get; set; }

    public string Grade { get; set; } = null!;

    public string? Department { get; set; }

    public string Designation { get; set; } = null!;

    public string? VerticalName { get; set; }

    public string? SubVerticalName { get; set; }

    public string? BusinessSegment { get; set; }

    public string? MobileNo { get; set; }

    public decimal AdvanceTillDate { get; set; }

    public DateTime AdvanceApprovedDate { get; set; }

    public decimal BranchId { get; set; }

    public decimal? VerticalId { get; set; }
}
