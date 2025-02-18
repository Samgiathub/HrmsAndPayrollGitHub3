using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class MonthlyEmpBankPayment
{
    public decimal EmpId { get; set; }

    public decimal CmpId { get; set; }

    public DateTime ForDate { get; set; }

    public DateTime PaymentDate { get; set; }

    public decimal? EmpBankId { get; set; }

    public string? PaymentMode { get; set; }

    public decimal? NetAmount { get; set; }

    public string? EmpBankAcNo { get; set; }

    public decimal? CmpBankId { get; set; }

    public string? EmpChequeNo { get; set; }

    public string? CmpBankChequeNo { get; set; }

    public string? CmpBankAcNo { get; set; }

    public string? EmpLeft { get; set; }

    public string? Status { get; set; }

    public string ProcessType { get; set; } = null!;

    public decimal AdId { get; set; }

    public decimal ProcessTypeId { get; set; }

    public decimal PaymentProcessId { get; set; }

    public virtual T0010CompanyMaster Cmp { get; set; } = null!;

    public virtual T0080EmpMaster Emp { get; set; } = null!;
}
