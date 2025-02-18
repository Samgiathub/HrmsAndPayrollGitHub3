using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class DtBusiness1
{
    public decimal? DtDeptId { get; set; }

    public decimal? DtSegmentId { get; set; }

    public decimal? DtShiftId { get; set; }

    public decimal Total { get; set; }

    public decimal TotalPresent { get; set; }

    public decimal TotalLeave { get; set; }

    public decimal TotalOd { get; set; }

    public decimal TotalAbsent { get; set; }

    public decimal TotalWeekoff { get; set; }

    public string DeptName { get; set; } = null!;

    public string? SegmentName { get; set; }

    public string CmpName { get; set; } = null!;

    public string CmpAddress { get; set; } = null!;

    public DateTime? FromDate { get; set; }

    public string ShiftName { get; set; } = null!;
}
