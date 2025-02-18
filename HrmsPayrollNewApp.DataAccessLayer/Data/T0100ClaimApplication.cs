using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T0100ClaimApplication
{
    public decimal ClaimAppId { get; set; }

    public decimal CmpId { get; set; }

    public decimal ClaimId { get; set; }

    public decimal EmpId { get; set; }

    public DateTime ClaimAppDate { get; set; }

    public string ClaimAppCode { get; set; } = null!;

    public decimal ClaimAppAmount { get; set; }

    public string ClaimAppDescription { get; set; } = null!;

    public string ClaimAppDoc { get; set; } = null!;

    public string? ClaimAppStatus { get; set; }

    public decimal? SEmpId { get; set; }

    public byte SubmitFlag { get; set; }

    public decimal? TransactionBy { get; set; }

    public DateTime? TransactionDate { get; set; }

    public byte? IsMobileEntry { get; set; }

    public bool? TermsIsAccepted { get; set; }

    public string? ClaimTermsCondition { get; set; }

    public virtual T0010CompanyMaster Cmp { get; set; } = null!;

    public virtual T0080EmpMaster Emp { get; set; } = null!;

    public virtual T0080EmpMaster? SEmp { get; set; }

    public virtual ICollection<T0115ClaimLevelApproval> T0115ClaimLevelApprovals { get; set; } = new List<T0115ClaimLevelApproval>();

    public virtual ICollection<T0120ClaimApproval> T0120ClaimApprovals { get; set; } = new List<T0120ClaimApproval>();
}
