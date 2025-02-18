using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T0200MonthlySalaryDailyDaily
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
}
