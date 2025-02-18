using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class V0210MonthlyClaimPayment
{
    public decimal EmpId { get; set; }

    public decimal? ClaimId { get; set; }

    public decimal? ClaimAppId { get; set; }

    public string ClaimAprCode { get; set; } = null!;

    public decimal? ClaimAprDeductFromSal { get; set; }

    public decimal? ClaimAprPendingAmount { get; set; }

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

    public string EmpFirstName { get; set; } = null!;

    public string? MobileNo { get; set; }

    public string? OtherEmail { get; set; }

    public string? EmpFullName { get; set; }

    public string? EmpLeft { get; set; }

    public string ClaimChequeNo { get; set; } = null!;

    public decimal EmpCode { get; set; }

    public decimal BranchId { get; set; }
}
