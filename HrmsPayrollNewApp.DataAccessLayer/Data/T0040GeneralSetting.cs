using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T0040GeneralSetting
{
    public decimal GenId { get; set; }

    public decimal CmpId { get; set; }

    public decimal BranchId { get; set; }

    public DateTime ForDate { get; set; }

    public decimal IncWeekoff { get; set; }

    public decimal IsOt { get; set; }

    public decimal ExOtSetting { get; set; }

    public string LateLimit { get; set; } = null!;

    public decimal LateAdjDay { get; set; }

    public decimal IsPt { get; set; }

    public decimal IsLwf { get; set; }

    public decimal IsRevenue { get; set; }

    public decimal IsPf { get; set; }

    public decimal IsEsic { get; set; }

    public decimal IsLateMark { get; set; }

    public decimal IsCredit { get; set; }

    public decimal LwfAmount { get; set; }

    public string LwfMonth { get; set; } = null!;

    public decimal RevenueAmount { get; set; }

    public decimal RevenueOnAmount { get; set; }

    public decimal CreditLimit { get; set; }

    public decimal ChkServerDate { get; set; }

    public decimal IsCancelWeekoff { get; set; }

    public decimal IsCancelHoliday { get; set; }

    public decimal IsDailyOt { get; set; }

    public string InPunchDuration { get; set; } = null!;

    public string LastEntryDuration { get; set; } = null!;

    public string OtAppLimit { get; set; } = null!;

    public string OtMaxLimit { get; set; } = null!;

    public decimal OtFixWorkDay { get; set; }

    public string OtFixShiftHours { get; set; } = null!;

    public decimal OtIncSalary { get; set; }

    public decimal? EsicUpperLimit { get; set; }

    public decimal? EsicEmployerContribution { get; set; }

    public decimal? SkipOut { get; set; }

    public decimal? LvEncashWDay { get; set; }

    public byte? LvSalaryEffectOnPt { get; set; }

    public decimal? LateFixWorkDays { get; set; }

    public string? LateFixShiftHours { get; set; }

    public decimal? LateDeductionDays { get; set; }

    public decimal? LateExtraDeduction { get; set; }

    public byte? IsLateCalcOnHoWo { get; set; }

    public byte? IsLateCf { get; set; }

    public string? LateCfResetOn { get; set; }

    public decimal? InoutDays { get; set; }

    public DateTime? SalStDate { get; set; }

    public decimal? SalFixDays { get; set; }

    public decimal? IsInoutSal { get; set; }

    public byte? GrMinYear { get; set; }

    public byte? GrCalMonth { get; set; }

    public byte? GrProRataCal { get; set; }

    public decimal? GrMinPDays { get; set; }

    public decimal? GrAbsentDays { get; set; }

    public decimal? ShortFallDays { get; set; }

    public decimal? GrDays { get; set; }

    public decimal? GrPercentage { get; set; }

    public decimal? ShortFallWDays { get; set; }

    public DateTime? BonusLastPaidDate { get; set; }

    public byte? IsGrYearlyPaid { get; set; }

    public decimal? LeaveSms { get; set; }

    public decimal? CtcAutoCal { get; set; }

    public decimal? IncHoliday { get; set; }

    public decimal? Probation { get; set; }

    public decimal LvMonth { get; set; }

    public byte IsShortfallGradewise { get; set; }

    public decimal? ActualGross { get; set; }

    public decimal? WagesAmount { get; set; }

    public decimal DepReimDays { get; set; }

    public decimal ConReimDays { get; set; }

    public decimal? LateWithLeave { get; set; }

    public decimal? LateWithLeaeve { get; set; }

    public byte? TrasWeekOt { get; set; }

    public decimal? BonusMinLimit { get; set; }

    public decimal? BonusMaxLimit { get; set; }

    public decimal? BonusPer { get; set; }

    public byte? IsOrganiseChart { get; set; }

    public byte? IsZeroDaySalary { get; set; }

    public byte? IsOtAutoCalc { get; set; }

    public byte? OtPresentDays { get; set; }

    public int? IsNegativeOt { get; set; }

    public decimal? IsPresent { get; set; }

    public decimal? IsAmount { get; set; }

    public decimal? MidIncrement { get; set; }

    public decimal? AdRounding { get; set; }

    public string? LvEncashCalOn { get; set; }

    public int? InOutLogin { get; set; }

    public decimal LwfOverAmount { get; set; }

    public decimal LwfMaxAmount { get; set; }

    public byte? FirstInLastOutForAttRegularization { get; set; }

    public byte? FirstInLastOutForInOutCalculation { get; set; }

    public decimal? LateCountExemption { get; set; }

    public string? EarlyLimit { get; set; }

    public decimal? EarlyAdjDay { get; set; }

    public decimal? EarlyDeductionDays { get; set; }

    public decimal? EarlyExtraDeduction { get; set; }

    public string? EarlyCfResetOn { get; set; }

    public byte? IsEarlyCalcOnHoWo { get; set; }

    public byte? IsEarlyCf { get; set; }

    public decimal? EarlyWithLeave { get; set; }

    public decimal? EarlyCountExemption { get; set; }

    public string? DeficitLimit { get; set; }

    public decimal? DeficitAdjDay { get; set; }

    public decimal? DeficitDeductionDays { get; set; }

    public decimal? DeficitExtraDeduction { get; set; }

    public string? DeficitCfResetOn { get; set; }

    public byte? IsDeficitCalcOnHoWo { get; set; }

    public byte? IsDeficitCf { get; set; }

    public decimal? DeficitWithLeave { get; set; }

    public decimal? DeficitCountExemption { get; set; }

    public byte? InOutLoginPopup { get; set; }

    public byte? IsZeroBasicSalary { get; set; }

    public decimal LateHourUpperRounding { get; set; }

    public byte IsLateCalcSlabwise { get; set; }

    public string? LateCalculateType { get; set; }

    public decimal EarlyHourUpperRounding { get; set; }

    public byte IsEarlyCalcSlabwise { get; set; }

    public string? EarlyCalculateType { get; set; }

    public string? LateExemptionLimit { get; set; }

    public string EarlyExemptionLimit { get; set; } = null!;

    public byte? IsPreQuestion { get; set; }

    public byte IsCompOff { get; set; }

    public decimal CompOffDaysLimit { get; set; }

    public string CompOffMinHours { get; set; } = null!;

    public byte IsCompOffWd { get; set; }

    public byte IsCompOffWoho { get; set; }

    public byte? IsCfOnSalDays { get; set; }

    public byte? DaysAsPerSalDays { get; set; }

    public string? MaxLateLimit { get; set; }

    public string? MaxEarlyLimit { get; set; }

    public int ManualInout { get; set; }

    public byte AllowNegativeSalary { get; set; }

    public byte EffectOtAmount { get; set; }

    public decimal CompOffAvailDays { get; set; }

    public byte PaidWeekOffDailyWages { get; set; }

    public byte AllowedFullWeekOfMidJoining { get; set; }

    public byte IsWeekoffHour { get; set; }

    public string? WeekoffHours { get; set; }

    public byte IsAllEmpProb { get; set; }

    public int ManualSalaryPeriod { get; set; }

    public decimal MaxBonusSalaryAmount { get; set; }

    public decimal? OptionalHolidayDays { get; set; }

    public byte IsOdTransferToOt { get; set; }

    public byte IsCoHourEditable { get; set; }

    public decimal? AttendanceSms { get; set; }

    public decimal BonusEntitleLimit { get; set; }

    public byte AllowedFullWeekOfMidJoiningDayRate { get; set; }

    public byte MonthlyDeficitAdjustOtHrs { get; set; }

    public decimal HalfDayExceptedCount { get; set; }

    public decimal HalfDayExceptedMaxCount { get; set; }

    public decimal NetSalaryRound { get; set; }

    public decimal IsHoCompOff { get; set; }

    public decimal HCompOffDaysLimit { get; set; }

    public string HCompOffMinHours { get; set; } = null!;

    public decimal HCompOffAvailDays { get; set; }

    public decimal IsWCompOff { get; set; }

    public decimal WCompOffDaysLimit { get; set; }

    public string WCompOffMinHours { get; set; } = null!;

    public decimal WCompOffAvailDays { get; set; }

    public decimal AllowShowOdoptInCompOff { get; set; }

    public decimal IsHCoHourEditable { get; set; }

    public decimal IsWCoHourEditable { get; set; }

    public string? TypeNetSalaryRound { get; set; }

    public decimal? DayForSecurityDeposit { get; set; }

    public decimal OtRoundingOffTo { get; set; }

    public decimal OtRoundingOffLower { get; set; }

    public decimal MinWodays { get; set; }

    public decimal MaxWodays { get; set; }

    public byte ChkOtLimitBeforeAfterShiftTime { get; set; }

    public byte ChkLvOnWorking { get; set; }

    public DateTime? CutoffdateSalary { get; set; }

    public decimal? AttndncRegMaxCnt { get; set; }

    public byte IsWdOd { get; set; }

    public byte IsWoOd { get; set; }

    public byte IsHoOd { get; set; }

    public byte DayRateWoCancel { get; set; }

    public decimal? TrainingMonth { get; set; }

    public decimal DepReimDaysTraning { get; set; }

    public decimal FnfFixDay { get; set; }

    public decimal IsCancelHolidayWoHoSameDay { get; set; }

    public string? LateEarlyExemptionMaxLimit { get; set; }

    public decimal? LateEarlyExemptionCount { get; set; }

    public string RestrictPresentDays { get; set; } = null!;

    public decimal EmpWeekDayOtRate { get; set; }

    public decimal EmpWeekOffOtRate { get; set; }

    public decimal EmpHolidayOtRate { get; set; }

    public decimal FullPf { get; set; }

    public decimal CompanyFullPf { get; set; }

    public byte IsPresentOnHoliday { get; set; }

    public decimal? RateOfNationalHoliday { get; set; }

    public decimal LateAdjAgainOt { get; set; }

    public decimal LateMarkScenario { get; set; }

    public byte AllowedFullWeekOfMidLeft { get; set; }

    public byte AllowedFullWeekOfMidLeftDayRate { get; set; }

    public decimal AuditDailyOtLimit { get; set; }

    public decimal AuditDailyExemptionOtLimit { get; set; }

    public decimal AuditDailyFinalOtLimit { get; set; }

    public decimal AuditWeeklyOtLimit { get; set; }

    public decimal AuditWeeklyExemptionOtLimit { get; set; }

    public decimal AuditWeeklyFinalOtLimit { get; set; }

    public decimal AuditMonthlyOtLimit { get; set; }

    public decimal AuditMonthlyExemptionOtLimit { get; set; }

    public decimal AuditMonthlyFinalOtLimit { get; set; }

    public decimal AuditQuarterlyOtLimit { get; set; }

    public decimal AuditQuarterlyExemptionOtLimit { get; set; }

    public decimal AuditQuarterlyFinalOtLimit { get; set; }

    public byte ValidityPeriodType { get; set; }

    public byte IsCustomerAudit { get; set; }

    public byte? IsBonusInc { get; set; }

    public byte? IsRegularBon { get; set; }

    public decimal Traning { get; set; }

    public decimal CophAvailLimit { get; set; }

    public decimal CondAvailLimit { get; set; }

    public decimal IsLatemarkPercentage { get; set; }

    public decimal IsLatemarkCalOn { get; set; }

    public string ProbationReview { get; set; } = null!;

    public string TraineeReview { get; set; } = null!;

    public string LateLimitRegularization { get; set; } = null!;

    public byte ShowPtInPayslipIfZero { get; set; }

    public byte ShowLwfInPayslipIfZero { get; set; }

    public byte OtrateType { get; set; }

    public byte OtslabType { get; set; }

    public byte IsChkLateEarlyMark { get; set; }

    public byte ChkLastLateEarlyMonth { get; set; }

    public decimal GlobalSalaryDays { get; set; }

    public bool IsOtAdjAgainstAbsent { get; set; }

    public byte IsProbationMonthDays { get; set; }

    public byte IsTraineeMonthDays { get; set; }

    public byte EarlyMarkScenario { get; set; }

    public byte IsEarlymarkPercentage { get; set; }

    public byte IsEarlyMarkCalOn { get; set; }

    public decimal? HolidayCompOffAvailAfterDays { get; set; }

    public decimal? WeekOffCompOffAvailAfterDays { get; set; }

    public decimal? WeekDayCompOffAvailAfterDays { get; set; }

    public string AttendanceRegWeekday { get; set; } = null!;

    public byte ApprovalUpToDate { get; set; }

    public byte? LateEarlyCombine { get; set; }

    public string? MonthlyExemptionLimit { get; set; }

    public int? IsCancelHolidayIfOneSideAbsent { get; set; }

    public int? IsCancelWeekoffIfOneSideAbsent { get; set; }

    public byte? DailyMonthly { get; set; }

    public byte? LateEarlyMonthWise { get; set; }

    public bool? IsDeficit { get; set; }
}
