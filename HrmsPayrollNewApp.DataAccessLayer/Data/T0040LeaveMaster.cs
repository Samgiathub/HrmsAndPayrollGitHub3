using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T0040LeaveMaster
{
    public decimal LeaveId { get; set; }

    public decimal CmpId { get; set; }

    public string LeaveCode { get; set; } = null!;

    public string LeaveName { get; set; } = null!;

    public string LeaveType { get; set; } = null!;

    public decimal LeaveCount { get; set; }

    public string LeavePaidUnpaid { get; set; } = null!;

    public decimal LeaveMin { get; set; }

    public decimal LeaveMax { get; set; }

    public decimal LeaveMinBal { get; set; }

    public decimal LeaveMaxBal { get; set; }

    public decimal LeaveMinEncash { get; set; }

    public decimal LeaveMaxEncash { get; set; }

    public decimal LeaveNoticePeriod { get; set; }

    public decimal LeaveApplicable { get; set; }

    public string LeaveCfType { get; set; } = null!;

    public decimal LeavePdays { get; set; }

    public decimal LeaveGetAgainstPdays { get; set; }

    public string LeaveAutoGeneration { get; set; } = null!;

    public decimal? LeaveStatus { get; set; }

    public decimal? LeaveCfMonth { get; set; }

    public decimal? LeavePrecision { get; set; }

    public decimal? LeaveDefId { get; set; }

    public byte? IsLateAdj { get; set; }

    public byte? LeaveBalResetMonth { get; set; }

    public byte? LeaveNegativeAllow { get; set; }

    public byte? SalaryOnLeave { get; set; }

    public byte? IsHoWo { get; set; }

    public byte WeekoffAsLeave { get; set; }

    public byte HolidayAsLeave { get; set; }

    public decimal LeaveSortingNo { get; set; }

    public decimal NoDaysToCancelWoho { get; set; }

    public byte IsLeaveCfRounding { get; set; }

    public byte IsLeaveCfProrata { get; set; }

    public byte DisplayLeaveBalance { get; set; }

    public byte IsLeaveClubbed { get; set; }

    public byte CanApplyFraction { get; set; }

    public byte? IsCfOnSalDays { get; set; }

    public byte? DaysAsPerSalDays { get; set; }

    public decimal? MaxAccumulateBalance { get; set; }

    public decimal? MinPresentDays { get; set; }

    public string? DefaultShortName { get; set; }

    public decimal MaxNoOfApplication { get; set; }

    public decimal LEncPercentageOfCurrentBalance { get; set; }

    public decimal EncashmentAfterMonths { get; set; }

    public DateTime? InActiveEffectiveDate { get; set; }

    public string? LeaveClubWith { get; set; }

    public byte IsDocumentRequired { get; set; }

    public int? EffectOfLta { get; set; }

    public int ApplyHourly { get; set; }

    public int CarryForwardHours { get; set; }

    public int BalanceToSalary { get; set; }

    public int AllowNightHalt { get; set; }

    public decimal? AttachmentDays { get; set; }

    public int HalfPaid { get; set; }

    public decimal LeaveNegativeMaxLimit { get; set; }

    public byte MinPdaysType { get; set; }

    public decimal TransLeaveId { get; set; }

    public decimal LvEncaseCalculationDay { get; set; }

    public decimal IncludingHoliday { get; set; }

    public decimal IncludingWeekOff { get; set; }

    public string? IncludingLeaveType { get; set; }

    public string? MultiBranchId { get; set; }

    public byte MedicalLeave { get; set; }

    public byte LeaveEncashDayHalfPayment { get; set; }

    public decimal MaxCfFromLastYrBalance { get; set; }

    public int PunchRequired { get; set; }

    public byte IsAdvanceLeaveBalance { get; set; }

    public byte IsInOutShowInEmail { get; set; }

    public byte EffectSalaryCycle { get; set; }

    public decimal MonthlyMaxLeave { get; set; }

    public byte NoticePeriodType { get; set; }

    public decimal WorkingDays { get; set; }

    public decimal ConsecutiveDays { get; set; }

    public byte MinLeaveNotMandatory { get; set; }

    public decimal ConsecutiveClubDays { get; set; }

    public decimal WorkingClubDays { get; set; }

    public string? GujaratiAlias { get; set; }

    public byte CalculateOnPreviousMonth { get; set; }

    public byte NoOfAllowedLeaveCfYrs { get; set; }

    public decimal PaternityLeaveBalance { get; set; }

    public decimal PaternityLeaveValidity { get; set; }

    public byte? AllowedCfJoinAfterDay { get; set; }

    public byte FirstMinBalThenPercentCurrBalance { get; set; }

    public byte AddInWorkingHour { get; set; }

    public byte RestrictLeaveAfterExitNotice { get; set; }

    public byte LeavePaidAsAllowance { get; set; }

    public byte? NotAllowCfAfterJoining { get; set; }

    public string? AdvBalanceRoundOff { get; set; }

    public decimal AdvBalanceRoundOffType { get; set; }

    public decimal MaxLeaveLifetime { get; set; }

    public byte AddAltWoCarryFwd { get; set; }

    public byte? IsAutoLeaveFromSalary { get; set; }

    public int? IsDoubleDeduct { get; set; }

    public int? PunchBothRequired { get; set; }

    public string? MultiAllowanceId { get; set; }

    public byte? CountWeekOffNoticePeriod { get; set; }

    public byte? LeaveContinuity { get; set; }

    public virtual ICollection<T0050LeaveCfMonthlySetting> T0050LeaveCfMonthlySettings { get; set; } = new List<T0050LeaveCfMonthlySetting>();

    public virtual ICollection<T0050LeaveCfSetting> T0050LeaveCfSettings { get; set; } = new List<T0050LeaveCfSetting>();

    public virtual ICollection<T0050LeaveDetail> T0050LeaveDetails { get; set; } = new List<T0050LeaveDetail>();

    public virtual ICollection<T0095LeaveOpening> T0095LeaveOpenings { get; set; } = new List<T0095LeaveOpening>();

    public virtual ICollection<T0100EmpLateDetail> T0100EmpLateDetails { get; set; } = new List<T0100EmpLateDetail>();

    public virtual ICollection<T0100LeaveCfDetail> T0100LeaveCfDetails { get; set; } = new List<T0100LeaveCfDetail>();

    public virtual ICollection<T0100LeaveEncashApplication> T0100LeaveEncashApplications { get; set; } = new List<T0100LeaveEncashApplication>();

    public virtual ICollection<T0115LeaveLevelApproval> T0115LeaveLevelApprovals { get; set; } = new List<T0115LeaveLevelApproval>();

    public virtual ICollection<T0120LeaveEncashApproval> T0120LeaveEncashApprovals { get; set; } = new List<T0120LeaveEncashApproval>();

    public virtual ICollection<T0135LeaveCancelation> T0135LeaveCancelations { get; set; } = new List<T0135LeaveCancelation>();

    public virtual ICollection<T0140LeaveTransaction> T0140LeaveTransactions { get; set; } = new List<T0140LeaveTransaction>();

    public virtual ICollection<T0200SalaryLeaveEncashment> T0200SalaryLeaveEncashments { get; set; } = new List<T0200SalaryLeaveEncashment>();

    public virtual ICollection<T0210MonthlyLeaveDetail> T0210MonthlyLeaveDetails { get; set; } = new List<T0210MonthlyLeaveDetail>();
}
