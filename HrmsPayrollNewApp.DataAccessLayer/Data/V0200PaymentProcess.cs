using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class V0200PaymentProcess
{
    public decimal CmpId { get; set; }

    public decimal EmpId { get; set; }

    public string? AlphaEmpCode { get; set; }

    public string? EmpFullName { get; set; }

    public DateTime? MonthStDate { get; set; }

    public DateTime? MonthEndDate { get; set; }

    public string? BankName { get; set; }

    public string? IncBankAcNo { get; set; }

    public string? PaymentMode { get; set; }

    public decimal? BankIdTwo { get; set; }

    public string? PaymentModeTwo { get; set; }

    public string? IncBankAcNoTwo { get; set; }

    public string? CmpBankAcNo { get; set; }

    public string? CmpBankName { get; set; }

    public decimal? CmpBankId { get; set; }

    public decimal? NetAmount { get; set; }

    public decimal BranchId { get; set; }

    public decimal DeptId { get; set; }

    public decimal CatId { get; set; }

    public decimal TypeId { get; set; }

    public decimal DesigId { get; set; }

    public string? EmpLeft { get; set; }

    public decimal? BankId { get; set; }

    public decimal? ItMEdCessAmount { get; set; }

    public string? SalaryStatus { get; set; }

    public string ProcessType { get; set; } = null!;

    public decimal AdId { get; set; }
}
