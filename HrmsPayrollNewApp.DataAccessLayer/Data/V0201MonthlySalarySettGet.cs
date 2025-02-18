using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class V0201MonthlySalarySettGet
{
    public decimal SSalTranId { get; set; }

    public decimal SSalReceiptNo { get; set; }

    public decimal EmpId { get; set; }

    public decimal CmpId { get; set; }

    public decimal IncrementId { get; set; }

    public DateTime SMonthStDate { get; set; }

    public DateTime SMonthEndDate { get; set; }

    public DateTime SSalGenerateDate { get; set; }

    public decimal SSalCalDays { get; set; }

    public decimal? SShiftDaySec { get; set; }

    public string? SShiftDayHour { get; set; }

    public decimal? SBasicSalary { get; set; }

    public decimal? SDaySalary { get; set; }

    public decimal? SHourSalary { get; set; }

    public decimal? SSalaryAmount { get; set; }

    public decimal? SAllowAmount { get; set; }

    public decimal? SOtAmount { get; set; }

    public decimal? SOtherAllowAmount { get; set; }

    public decimal? SGrossSalary { get; set; }

    public decimal? SDeduAmount { get; set; }

    public decimal? SLoanAmount { get; set; }

    public decimal? SLoanIntrestAmount { get; set; }

    public decimal? SAdvanceAmount { get; set; }

    public decimal? SOtherDeduAmount { get; set; }

    public decimal? STotalDeduAmount { get; set; }

    public decimal? SDueLoanAmount { get; set; }

    public decimal? SNetAmount { get; set; }

    public decimal? SActuallyGrossSalary { get; set; }

    public decimal? SPtAmount { get; set; }

    public decimal? SPtCalculatedAmount { get; set; }

    public decimal? STotalClaimAmount { get; set; }

    public decimal? SMOtHours { get; set; }

    public decimal? SMAdvAmount { get; set; }

    public decimal? SMLoanAmount { get; set; }

    public decimal? SMItTax { get; set; }

    public decimal? SLwfAmount { get; set; }

    public decimal? SRevenueAmount { get; set; }

    public string? SPtFTLimit { get; set; }

    public decimal? DeptId { get; set; }

    public decimal GrdId { get; set; }

    public decimal BranchId { get; set; }

    public string? EmpFullName { get; set; }

    public string? BranchName { get; set; }

    public string? OtherEmail { get; set; }

    public decimal EmpCode1 { get; set; }

    public string? EmpCode { get; set; }

    public DateTime SEffDate { get; set; }

    public decimal? VerticalId { get; set; }

    public decimal? SubVerticalId { get; set; }

    public byte EffectOnSalary { get; set; }
}
