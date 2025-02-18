using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class V0090EmpReportingManagerGet
{
    public decimal RowId { get; set; }

    public decimal EmpId { get; set; }

    public decimal? REmpId { get; set; }

    public decimal CmpId { get; set; }

    public string ReportingTo { get; set; } = null!;

    public string ReportingMethod { get; set; } = null!;

    public string? REmpFullName1 { get; set; }

    public string? AlphaEmpCode { get; set; }

    public string? EmpFullName { get; set; }

    public decimal BranchId { get; set; }

    public decimal? DeptId { get; set; }

    public decimal? DesigId { get; set; }

    public decimal GrdId { get; set; }

    public decimal CatId { get; set; }

    public string? BranchName { get; set; }

    public decimal? VerticalId { get; set; }

    public decimal? SubVerticalId { get; set; }

    public decimal? SalCycleId { get; set; }

    public decimal? SegmentId { get; set; }

    public decimal? SubBranchId { get; set; }

    public decimal? BandId { get; set; }

    public decimal? TypeId { get; set; }

    public DateTime? EffectDate { get; set; }

    public decimal? RCmpId { get; set; }

    public string? CompanyName { get; set; }

    public string? REmpFullName { get; set; }
}
