using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class V0100BreakTime
{
    public decimal BreakId { get; set; }

    public decimal CmpId { get; set; }

    public decimal EmpId { get; set; }

    public DateTime EffectiveDate { get; set; }

    public string? EmpFullName { get; set; }

    public string? EmpFirstName { get; set; }

    public decimal? EmpCode { get; set; }

    public string? AlphaEmpCode { get; set; }

    public decimal? VerticalId { get; set; }

    public decimal? SubVerticalId { get; set; }

    public decimal? DeptId { get; set; }

    public decimal BranchId { get; set; }

    public decimal GrdId { get; set; }

    public decimal? TypeId { get; set; }

    public decimal? DesigId { get; set; }

    public decimal? SegmentId { get; set; }

    public decimal? CatId { get; set; }

    public decimal? SubBranchId { get; set; }

    public byte Type { get; set; }

    public string BreakStartTime { get; set; } = null!;

    public string BreakEndTime { get; set; } = null!;

    public string BreakDuration { get; set; } = null!;
}
