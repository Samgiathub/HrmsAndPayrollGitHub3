using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class V0000MonthlyEmpBankPaymentBackupMehul16122021
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

    public string? AlphaEmpCode { get; set; }

    public string? EmpFullName { get; set; }

    public string BankName { get; set; } = null!;

    public decimal BranchId { get; set; }

    public string? BranchName { get; set; }

    public string? ProcessType { get; set; }

    public decimal AdId { get; set; }

    public decimal? VerticalId { get; set; }

    public decimal? SubVerticalId { get; set; }

    public decimal? DeptId { get; set; }

    public decimal ProcessTypeId { get; set; }

    public decimal PaymentProcessId { get; set; }

    public decimal? DesigId { get; set; }

    public decimal GrdId { get; set; }

    public decimal? CatId { get; set; }

    public decimal? TypeId { get; set; }

    public decimal? SubBranchId { get; set; }

    public decimal? BondId { get; set; }

    public decimal? BondAprId { get; set; }
}
