using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T0120ClaimApproval
{
    public decimal ClaimAprId { get; set; }

    public decimal CmpId { get; set; }

    public decimal? ClaimAppId { get; set; }

    public decimal EmpId { get; set; }

    public decimal? ClaimId { get; set; }

    public DateTime ClaimAprDate { get; set; }

    public string ClaimAprCode { get; set; } = null!;

    public decimal ClaimAprAmount { get; set; }

    public string ClaimAprComments { get; set; } = null!;

    public string ClaimAprBy { get; set; } = null!;

    public decimal? ClaimAprDeductFromSal { get; set; }

    public decimal? ClaimAprPendingAmount { get; set; }

    public string? ClaimAprStatus { get; set; }

    public DateTime? ClaimAppDate { get; set; }

    public decimal? ClaimAppAmount { get; set; }

    public decimal? CurrId { get; set; }

    public decimal? CurrRate { get; set; }

    public string? Purpose { get; set; }

    public decimal? ClaimAppTotalAmount { get; set; }

    public decimal? SEmpId { get; set; }

    public decimal PetrolKm { get; set; }

    public byte? IsMobileEntry { get; set; }

    public virtual T0040ClaimMaster? Claim { get; set; }

    public virtual T0100ClaimApplication? ClaimApp { get; set; }

    public virtual T0010CompanyMaster Cmp { get; set; } = null!;

    public virtual T0080EmpMaster Emp { get; set; } = null!;

    public virtual ICollection<T0130ClaimApprovalDetail> T0130ClaimApprovalDetails { get; set; } = new List<T0130ClaimApprovalDetail>();

    public virtual ICollection<T0210MonthlyClaimPayment> T0210MonthlyClaimPayments { get; set; } = new List<T0210MonthlyClaimPayment>();

    public virtual ICollection<T0230MonthlyClaimPaymentDetail> T0230MonthlyClaimPaymentDetails { get; set; } = new List<T0230MonthlyClaimPaymentDetail>();
}
