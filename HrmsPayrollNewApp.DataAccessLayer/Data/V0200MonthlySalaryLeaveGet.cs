using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class V0200MonthlySalaryLeaveGet
{
    public decimal LSalTranId { get; set; }

    public decimal LSalReceiptNo { get; set; }

    public decimal EmpId { get; set; }

    public decimal CmpId { get; set; }

    public decimal IncrementId { get; set; }

    public DateTime LMonthStDate { get; set; }

    public DateTime LMonthEndDate { get; set; }

    public DateTime LSalGenerateDate { get; set; }

    public decimal LSalCalDays { get; set; }

    public decimal LWorkingDays { get; set; }

    public decimal? LOutofDays { get; set; }

    public decimal? LShiftDaySec { get; set; }

    public string? LShiftDayHour { get; set; }

    public decimal? LBasicSalary { get; set; }

    public decimal? LDaySalary { get; set; }

    public decimal? LHourSalary { get; set; }

    public decimal? LSalaryAmount { get; set; }

    public decimal? LAllowAmount { get; set; }

    public decimal? LOtherAllowAmount { get; set; }

    public decimal? LGrossSalary { get; set; }

    public decimal? LDeduAmount { get; set; }

    public decimal? LLoanAmount { get; set; }

    public decimal? LLoanIntrestAmount { get; set; }

    public decimal? LAdvanceAmount { get; set; }

    public decimal? LOtherDeduAmount { get; set; }

    public decimal? LTotalDeduAmount { get; set; }

    public decimal? LDueLoanAmount { get; set; }

    public decimal? LNetAmount { get; set; }

    public decimal? LActuallyGrossSalary { get; set; }

    public decimal? LPtAmount { get; set; }

    public decimal? LPtCalculatedAmount { get; set; }

    public decimal? LMAdvAmount { get; set; }

    public decimal? LMLoanAmount { get; set; }

    public decimal? LMItTax { get; set; }

    public decimal? LLwfAmount { get; set; }

    public decimal? LRevenueAmount { get; set; }

    public string? LPtFTLimit { get; set; }

    public decimal? DeptId { get; set; }

    public decimal GrdId { get; set; }

    public string? EmpFullName { get; set; }

    public string? BranchName { get; set; }

    public string? OtherEmail { get; set; }

    public decimal Expr1 { get; set; }
}
