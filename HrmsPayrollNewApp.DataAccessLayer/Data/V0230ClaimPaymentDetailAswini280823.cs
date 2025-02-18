using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class V0230ClaimPaymentDetailAswini280823
{
    public string EmpFirstName { get; set; } = null!;

    public string? EmpFullName { get; set; }

    public string? AlphaEmpCode { get; set; }

    public decimal EmpId { get; set; }

    public DateTime? ClaimAprDate { get; set; }

    public decimal? DeptId { get; set; }

    public string? EmpLeft { get; set; }

    public decimal BranchId { get; set; }

    public string? EmpCode { get; set; }

    public decimal ClaimPayId { get; set; }

    public decimal ClaimAprId { get; set; }

    public decimal CmpId { get; set; }

    public decimal? SalTranId { get; set; }

    public string? ClaimPayCode { get; set; }

    public decimal ClaimPayAmount { get; set; }

    public string ClaimPayComments { get; set; } = null!;

    public DateTime ClaimPaymentDate { get; set; }

    public string ClaimPaymentType { get; set; } = null!;

    public string BankName { get; set; } = null!;

    public string ClaimChequeNo { get; set; } = null!;

    public decimal? TempSalTranId { get; set; }

    public string? VoucherNo { get; set; }

    public DateTime? VoucherDate { get; set; }

    public decimal? VerticalId { get; set; }

    public decimal? SubVerticalId { get; set; }
}
