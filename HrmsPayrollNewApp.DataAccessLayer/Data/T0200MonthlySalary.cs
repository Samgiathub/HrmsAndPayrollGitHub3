using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T0200MonthlySalary
{
    public decimal SalTranId { get; set; }

    public decimal SalReceiptNo { get; set; }

    public decimal EmpId { get; set; }

    public decimal CmpId { get; set; }

    public decimal IncrementId { get; set; }

    public DateTime MonthStDate { get; set; }

    public DateTime MonthEndDate { get; set; }

    public DateTime SalGenerateDate { get; set; }

    public decimal SalCalDays { get; set; }

    public decimal? PresentDays { get; set; }

    public decimal? AbsentDays { get; set; }

    public decimal? HolidayDays { get; set; }

    public decimal? WeekoffDays { get; set; }

    public decimal? CancelHoliday { get; set; }

    public decimal? CancelWeekoff { get; set; }

    public decimal? WorkingDays { get; set; }

    public decimal? OutofDays { get; set; }

    public decimal? TotalLeaveDays { get; set; }

    public decimal? PaidLeaveDays { get; set; }

    public string? ActualWorkingHours { get; set; }

    public string? WorkingHours { get; set; }

    public string? OutofHours { get; set; }

    public decimal? OtHours { get; set; }

    public string? TotalHours { get; set; }

    public decimal? ShiftDaySec { get; set; }

    public string? ShiftDayHour { get; set; }

    public decimal? BasicSalary { get; set; }

    public decimal? DaySalary { get; set; }

    public decimal? HourSalary { get; set; }

    public decimal? SalaryAmount { get; set; }

    public decimal? AllowAmount { get; set; }

    public decimal? OtAmount { get; set; }

    public decimal? OtherAllowAmount { get; set; }

    public decimal? GrossSalary { get; set; }

    public decimal? DeduAmount { get; set; }

    public decimal? LoanAmount { get; set; }

    public decimal? LoanIntrestAmount { get; set; }

    public decimal? AdvanceAmount { get; set; }

    public decimal? OtherDeduAmount { get; set; }

    public decimal? TotalDeduAmount { get; set; }

    public decimal? DueLoanAmount { get; set; }

    public decimal? NetAmount { get; set; }

    public decimal? ActuallyGrossSalary { get; set; }

    public decimal? PtAmount { get; set; }

    public decimal? PtCalculatedAmount { get; set; }

    public decimal? TotalClaimAmount { get; set; }

    public decimal? MOtHours { get; set; }

    public decimal? MAdvAmount { get; set; }

    public decimal? MLoanAmount { get; set; }

    public decimal? MItTax { get; set; }

    public decimal? LwfAmount { get; set; }

    public decimal? RevenueAmount { get; set; }

    public string? PtFTLimit { get; set; }

    public decimal? SettelementAmount { get; set; }

    public string? SettelementComments { get; set; }

    public decimal? LeaveSalaryAmount { get; set; }

    public string? LeaveSalaryComments { get; set; }

    public decimal? LateSec { get; set; }

    public decimal? LateDeduAmount { get; set; }

    public decimal? LateExtraDeduAmount { get; set; }

    public decimal? LateDays { get; set; }

    public decimal? ShortFallDays { get; set; }

    public decimal? ShortFallDeduAmount { get; set; }

    public decimal? GratuityAmount { get; set; }

    public byte? IsFnf { get; set; }

    public decimal? BonusAmount { get; set; }

    public decimal? IncentiveAmount { get; set; }

    public decimal? TravEarnAmount { get; set; }

    public decimal? CustResEarnAmount { get; set; }

    public decimal? TravRecAmount { get; set; }

    public decimal? MobileRecAmount { get; set; }

    public decimal? CustResRecAmount { get; set; }

    public decimal? UniformRecAmount { get; set; }

    public decimal? ICardRecAmount { get; set; }

    public decimal? ExcessSalaryRecAmount { get; set; }

    public string? SalaryStatus { get; set; }

    public decimal? PreMonthNetSalary { get; set; }

    public decimal? ItMEdCessAmount { get; set; }

    public decimal? ItMSurchargeAmount { get; set; }

    public decimal? EarlySec { get; set; }

    public decimal? EarlyDeduAmount { get; set; }

    public decimal? EarlyExtraDeduAmount { get; set; }

    public decimal? EarlyDays { get; set; }

    public decimal? DeficitSec { get; set; }

    public decimal? DeficitDeduAmount { get; set; }

    public decimal? DeficitExtraDeduAmount { get; set; }

    public decimal? DeficitDays { get; set; }

    public decimal TotalEarningFraction { get; set; }

    public decimal? LateEarlyPenaltyDays { get; set; }

    public decimal? MWoOtHours { get; set; }

    public decimal? MHoOtHours { get; set; }

    public decimal MWoOtAmount { get; set; }

    public decimal MHoOtAmount { get; set; }

    public byte IsMonthlySalary { get; set; }

    public decimal ArearBasic { get; set; }

    public decimal ArearGross { get; set; }

    public decimal ArearDay { get; set; }

    public decimal OdLeaveDays { get; set; }

    public decimal ExtraAbDays { get; set; }

    public decimal ExtraAbRate { get; set; }

    public decimal ExtraAbAmount { get; set; }

    public decimal AccessLeaveRecovery { get; set; }

    public decimal AccessLeaveRecoveryDay { get; set; }

    public decimal NetSalaryRoundDiffAmount { get; set; }

    public string? AccessLeaveRecoveryType { get; set; }

    public decimal ArearMonth { get; set; }

    public decimal ArearYear { get; set; }

    public decimal GatePassDeductDays { get; set; }

    public decimal GatePassAmount { get; set; }

    public DateTime? CutoffDate { get; set; }

    public decimal ArearDayPreviousMonth { get; set; }

    public decimal BasicSalaryArearCutoff { get; set; }

    public decimal GrossSalaryArearCutoff { get; set; }

    public decimal AssetInstallment { get; set; }

    public decimal FnfSubsidyRecoverAmount { get; set; }

    public decimal ExtraAbHolidayDaysDection { get; set; }

    public decimal TravelAmount { get; set; }

    public decimal TravelAdvanceAmount { get; set; }

    public string? FnfComments { get; set; }

    public decimal PresentOnHoliday { get; set; }

    public decimal FnfTrainingBndRecAmt { get; set; }

    public decimal UniformDeduAmount { get; set; }

    public decimal UniformRefundAmount { get; set; }

    public decimal OtAdjAgainstAbsent { get; set; }

    public string? OtAdjAgainstAbsentHours { get; set; }

    public decimal? BondAmount { get; set; }

    public decimal? RetainDays { get; set; }

    public decimal LateDaysArearCutoff { get; set; }

    public decimal EarlyDaysArearCutoff { get; set; }

    public virtual T0010CompanyMaster Cmp { get; set; } = null!;

    public virtual T0080EmpMaster Emp { get; set; } = null!;

    public virtual T0095Increment Increment { get; set; } = null!;

    public virtual ICollection<T0201MonthlySalarySett> T0201MonthlySalarySetts { get; set; } = new List<T0201MonthlySalarySett>();

    public virtual ICollection<T0210LtaMedicalPayment> T0210LtaMedicalPayments { get; set; } = new List<T0210LtaMedicalPayment>();

    public virtual ICollection<T0210LwpConsideredSameSalaryCutoff> T0210LwpConsideredSameSalaryCutoffs { get; set; } = new List<T0210LwpConsideredSameSalaryCutoff>();

    public virtual ICollection<T0210MonthlyAdDetail> T0210MonthlyAdDetails { get; set; } = new List<T0210MonthlyAdDetail>();

    public virtual ICollection<T0210MonthlyLoanPayment> T0210MonthlyLoanPayments { get; set; } = new List<T0210MonthlyLoanPayment>();

    public virtual ICollection<T0210MonthlyPresentCalculation> T0210MonthlyPresentCalculations { get; set; } = new List<T0210MonthlyPresentCalculation>();

    public virtual ICollection<T0210MonthlySalarySlipGradecount> T0210MonthlySalarySlipGradecounts { get; set; } = new List<T0210MonthlySalarySlipGradecount>();

    public virtual ICollection<T0210PayslipDatum> T0210PayslipData { get; set; } = new List<T0210PayslipDatum>();
}
