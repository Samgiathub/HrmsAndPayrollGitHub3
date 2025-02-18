using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class V0040LeaveDetail
{
    public decimal? GrdId { get; set; }

    public string? GrdName { get; set; }

    public string LeaveName { get; set; } = null!;

    public decimal LeaveId { get; set; }

    public decimal LeaveDays { get; set; }

    public decimal RowId { get; set; }

    public decimal CmpId { get; set; }

    public byte? IsLateAdj { get; set; }

    public string LeavePaidUnpaid { get; set; } = null!;

    public byte DisplayLeaveBalance { get; set; }

    public decimal? LeaveStatus { get; set; }

    public DateTime? InActiveEffectiveDate { get; set; }

    public string? LeaveClubWith { get; set; }

    public string? DefaultShortName { get; set; }

    public int ApplyHourly { get; set; }

    public string? MultiBranchId { get; set; }

    public string LeaveType { get; set; } = null!;

    public decimal LeaveSortingNo { get; set; }
}
