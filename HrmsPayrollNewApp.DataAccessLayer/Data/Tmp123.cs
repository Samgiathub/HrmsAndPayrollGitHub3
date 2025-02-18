using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class Tmp123
{
    public long? SrNo { get; set; }

    public decimal? EmpId { get; set; }

    public DateTime? ForDate { get; set; }

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

    public string? OtherReason { get; set; }

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

    public decimal? PDays { get; set; }

    public decimal? VerticalId { get; set; }

    public decimal? SubverticalId { get; set; }

    public DateTime? LeaveFromDate { get; set; }

    public DateTime? LeaveToDate { get; set; }

    public DateTime? BreakStartTime { get; set; }

    public DateTime? BreakEndTime { get; set; }

    public string? BreakDuration { get; set; }

    public decimal? RestDurationSec { get; set; }

    public string? RestDuration { get; set; }

    public decimal? ADays { get; set; }

    public decimal? LeaveDays { get; set; }

    public decimal? WeekOffDays { get; set; }

    public decimal? TempLvDays { get; set; }

    public string? EmpFullName { get; set; }

    public string? AlphaEmpCode { get; set; }

    public decimal EmpCode { get; set; }

    public string GrdName { get; set; } = null!;

    public string? ShiftName { get; set; }

    public string? DeptName { get; set; }

    public string? TypeName { get; set; }

    public string? DesigName { get; set; }

    public string CmpName { get; set; } = null!;

    public string CmpAddress { get; set; } = null!;

    public string PFromDate { get; set; } = null!;

    public string PToDate { get; set; } = null!;

    public string? ShiftStartTime { get; set; }

    public string? ShiftEndTime { get; set; }

    public string? ActualInTime { get; set; }

    public string? ActualOutTime { get; set; }

    public string? OnDate { get; set; }

    public string LeaveFooter { get; set; } = null!;

    public string? BranchName { get; set; }

    public string? CompName { get; set; }

    public string? BranchAddress { get; set; }

    public decimal? DesigDisNo { get; set; }

    public string? VerticalName { get; set; }

    public string? SubVerticalName { get; set; }

    public string? Designation { get; set; }

    public string? Department { get; set; }

    public string? BusinessUnit { get; set; }

    public string? CostCenter { get; set; }

    public string? Function { get; set; }

    public string? ManagerDetails { get; set; }

    public string? HodDetails { get; set; }

    public string? BrnchName { get; set; }

    public string? ImmSupervisor { get; set; }
}
