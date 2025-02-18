using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class V0040LeaveMasterGetBackupMehul09032023
{
    public decimal LeaveId { get; set; }

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

    public byte? LeaveBalResetMonth { get; set; }

    public byte? LeaveNegativeAllow { get; set; }

    public string LeaveAutoGeneration { get; set; } = null!;

    public decimal? LeaveCfMonth { get; set; }

    public byte SalaryOnLeave { get; set; }

    public byte IsLateAdj { get; set; }

    public byte IsHoWo { get; set; }

    public byte WeekoffAsLeave { get; set; }

    public byte HolidayAsLeave { get; set; }

    public decimal LeaveSortingNo { get; set; }

    public decimal NoDaysToCancelWoho { get; set; }

    public byte DisplayLeaveBalance { get; set; }

    public byte IsLeaveCfRounding { get; set; }

    public byte IsLeaveCfProrata { get; set; }

    public byte IsLeaveClubbed { get; set; }

    public byte CanApplyFraction { get; set; }

    public byte IsCfOnSalDays { get; set; }

    public byte DaysAsPerSalDays { get; set; }

    public decimal MaxAccumulateBalance { get; set; }

    public decimal MinPresentDays { get; set; }

    public decimal MaxNoOfApplication { get; set; }

    public decimal LEncPercentageOfCurrentBalance { get; set; }

    public decimal EncashmentAfterMonths { get; set; }

    public decimal LeaveStatus { get; set; }

    public DateTime InActiveEffectiveDate { get; set; }

    public string LeaveClubWith { get; set; } = null!;

    public byte IsDocumentRequired { get; set; }

    public int EffectOfLta { get; set; }

    public int ApplyHourly { get; set; }

    public int BalanceToSalary { get; set; }

    public int AllowNightHalt { get; set; }

    public decimal AttachmentDays { get; set; }

    public int HalfPaid { get; set; }

    public decimal LeaveNegativeMaxLimit { get; set; }

    public byte MinPdaysType { get; set; }

    public decimal TransLeaveId { get; set; }

    public decimal IncludingHoliday { get; set; }

    public decimal IncludingWeekOff { get; set; }

    public string? IncludingLeaveType { get; set; }

    public decimal LvEncaseCalculationDay { get; set; }

    public string MultiBranchId { get; set; } = null!;

    public byte MedicalLeave { get; set; }

    public byte LeaveEncashDayHalfPayment { get; set; }

    public decimal MaxCfFromLastYrBalance { get; set; }

    public int PunchRequired { get; set; }

    public int PunchBothRequired { get; set; }

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

    public byte CalculateOnPreviousMonth { get; set; }

    public byte NoOfAllowedLeaveCfYrs { get; set; }

    public decimal PaternityLeaveBalance { get; set; }

    public decimal PaternityLeaveValidity { get; set; }

    public byte AllowedCfJoinAfterDay { get; set; }

    public byte FirstMinBalThenPercentCurrBalance { get; set; }

    public byte AddInWorkingHour { get; set; }

    public byte RestrictLeaveAfterExitNotice { get; set; }

    public string? AdvBalanceRoundOff { get; set; }

    public decimal AdvBalanceRoundOffType { get; set; }

    public decimal MaxLeaveLifetime { get; set; }

    public byte IsAutoLeaveFromSalary { get; set; }

    public int IsDoubleDeduct { get; set; }

    public string MultiAllowanceId { get; set; } = null!;
}
