using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T0115ClaimLevelApproval
{
    public decimal TranId { get; set; }

    public decimal? ClaimAppId { get; set; }

    public decimal CmpId { get; set; }

    public decimal EmpId { get; set; }

    public decimal? SEmpId { get; set; }

    public DateTime ApprovalDate { get; set; }

    public string? ClaimAprStatus { get; set; }

    public string? ClaimAprComments { get; set; }

    public decimal LoginId { get; set; }

    public DateTime SystemDate { get; set; }

    public decimal RptLevel { get; set; }

    public decimal? ClaimAprAmount { get; set; }

    public decimal? ClaimAprPendingAmnt { get; set; }

    public decimal ClaimAppAmount { get; set; }

    public decimal? CurrId { get; set; }

    public decimal? CurrRate { get; set; }

    public decimal ClaimAppTotalAmount { get; set; }

    public string? AttachedDocFile { get; set; }

    public decimal? ClaimId { get; set; }

    public decimal? DeductFromSalary { get; set; }

    public DateTime? ForDate { get; set; }

    public string? ClaimAppPurpose { get; set; }

    public decimal ApprovedPetrolKm { get; set; }

    public byte? IsMobileEntry { get; set; }

    public string? ClaimModel { get; set; }

    public string? ClaimImei { get; set; }

    public string? ClaimNoofPerson { get; set; }

    public DateTime? ClaimDateOfPurchase { get; set; }

    public string? ClaimBookName { get; set; }

    public string? ClaimSubject { get; set; }

    public double? ClaimActualPrice { get; set; }

    public double? ClaimPriceAfterDiscount { get; set; }

    public string? ClaimFamilyMember { get; set; }

    public string? ClaimRelation { get; set; }

    public double? ClaimAge { get; set; }

    public double? ClaimLimit { get; set; }

    public int? ClaimFamilyMeberId { get; set; }

    public string? ClaimUnitName { get; set; }

    public int? ClaimUnitFlag { get; set; }

    public double? ClaimConversionRate { get; set; }

    public string? ClaimComments { get; set; }

    public string? LabelString { get; set; }

    public virtual T0100ClaimApplication? ClaimApp { get; set; }

    public virtual T0010CompanyMaster Cmp { get; set; } = null!;

    public virtual T0080EmpMaster Emp { get; set; } = null!;

    public virtual ICollection<T0115ClaimLevelApprovalDetail> T0115ClaimLevelApprovalDetails { get; set; } = new List<T0115ClaimLevelApprovalDetail>();
}
