using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T0230MonthlyClaimPaymentDetail
{
    public decimal ClaimPayDtlId { get; set; }

    public decimal ClaimPayId { get; set; }

    public decimal CmpId { get; set; }

    public decimal ClaimAprId { get; set; }

    public decimal ClaimAprDtlId { get; set; }

    public decimal? SalTranId { get; set; }

    public string? ClaimStatus { get; set; }

    public decimal? ClaimId { get; set; }

    public DateTime? ClaimAprDate { get; set; }

    public decimal? ClaimPetrolKm { get; set; }

    public decimal? ClaimAprAmnt { get; set; }

    public string? ClaimPurpose { get; set; }

    public decimal EmpId { get; set; }

    public decimal? SEmpId { get; set; }

    public decimal? ClaimAppAmount { get; set; }

    public virtual T0120ClaimApproval ClaimApr { get; set; } = null!;

    public virtual T0130ClaimApprovalDetail ClaimAprDtl { get; set; } = null!;

    public virtual T0010CompanyMaster Cmp { get; set; } = null!;

    public virtual T0080EmpMaster Emp { get; set; } = null!;
}
