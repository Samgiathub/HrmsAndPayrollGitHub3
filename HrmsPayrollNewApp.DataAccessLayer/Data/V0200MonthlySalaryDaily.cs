using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class V0200MonthlySalaryDaily
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

    public decimal? DaySalary { get; set; }

    public decimal? HourSalary { get; set; }

    public decimal? BasicSalary { get; set; }

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

    public decimal? DeptId { get; set; }

    public decimal GrdId { get; set; }

    public decimal BranchId { get; set; }

    public string? EmpFullName { get; set; }

    public string? BranchName { get; set; }

    public string? OtherEmail { get; set; }

    public byte IsFnf { get; set; }

    public byte? IsEmpFnf { get; set; }

    public string EmpFirstName { get; set; } = null!;

    public decimal EmpCode1 { get; set; }

    public string? EmpCode { get; set; }
}
