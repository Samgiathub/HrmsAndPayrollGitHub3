using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class V0120ClaimApprovalDetailMultiPayment
{
    public decimal? ClaimAppId { get; set; }

    public decimal? ClaimAprId { get; set; }

    public string ClaimName { get; set; } = null!;

    public decimal ClaimMaxLimit { get; set; }

    public string EmpFirstName { get; set; } = null!;

    public string? MobileNo { get; set; }

    public string? EmpFullName { get; set; }

    public string? EmpLeft { get; set; }

    public DateTime ClaimAppDate { get; set; }

    public string ClaimAppCode { get; set; } = null!;

    public decimal? CmpId { get; set; }

    public decimal EmpId { get; set; }

    public decimal? ClaimId { get; set; }

    public DateTime ClaimAprDate { get; set; }

    public string ClaimAprCode { get; set; } = null!;

    public decimal? ClaimAprAmount { get; set; }

    public string ClaimAprComments { get; set; } = null!;

    public string ClaimAprBy { get; set; } = null!;

    public decimal? ClaimAprDeductFromSal { get; set; }

    public decimal? ClaimAprPendingAmount { get; set; }

    public string? ClaimStatus { get; set; }

    public string? ClaimAppStatus { get; set; }

    public decimal BranchId { get; set; }

    public decimal EmpCode1 { get; set; }

    public string? OtherEmail { get; set; }

    public string? EmpCode { get; set; }
}
