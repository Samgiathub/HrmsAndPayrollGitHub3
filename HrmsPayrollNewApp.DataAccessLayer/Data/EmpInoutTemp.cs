using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class EmpInoutTemp
{
    public decimal TranId { get; set; }

    public decimal EmpId { get; set; }

    public DateTime ForDate { get; set; }

    public decimal? DeptId { get; set; }

    public decimal? GrdId { get; set; }

    public decimal? TypeId { get; set; }

    public decimal? DesigId { get; set; }

    public decimal? ShiftId { get; set; }

    public DateTime? InTime { get; set; }

    public DateTime? OutTime { get; set; }

    public string? Duration { get; set; }

    public decimal? DurationSec { get; set; }

    public string? LateIn { get; set; }

    public string? LateOut { get; set; }

    public string? EarlyIn { get; set; }

    public string? EarlyOut { get; set; }

    public string? Leave { get; set; }

    public decimal? ShiftSec { get; set; }

    public string? ShiftDur { get; set; }

    public string? TotalWork { get; set; }

    public string? LessWork { get; set; }

    public string? MoreWork { get; set; }

    public string? Reason { get; set; }

    public string? AbLeave { get; set; }

    public decimal? LateInSec { get; set; }

    public decimal? LateInCount { get; set; }

    public decimal? EarlyOutSec { get; set; }

    public decimal? EarlyOutCount { get; set; }

    public decimal? TotalLessWorkSec { get; set; }

    public DateTime? ShiftStDatetime { get; set; }

    public DateTime? ShiftEnDatetime { get; set; }

    public decimal? WorkingSecAfterShift { get; set; }

    public decimal? WorkingAfterShiftCount { get; set; }

    public string? LeaveReason { get; set; }

    public string? InoutReason { get; set; }

    public DateTime? SysDate { get; set; }

    public decimal? TotalWorkSec { get; set; }

    public decimal? LateOutSec { get; set; }

    public decimal? EarlyInSec { get; set; }

    public decimal? TotalMoreWorkSec { get; set; }

    public byte? IsOtApplicable { get; set; }

    public byte? MonthlyDeficitAdjustOtHrs { get; set; }

    public decimal? LateCommSec { get; set; }

    public decimal? BranchId { get; set; }
}
