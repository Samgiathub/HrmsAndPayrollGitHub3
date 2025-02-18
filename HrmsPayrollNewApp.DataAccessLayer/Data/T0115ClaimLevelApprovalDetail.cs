using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T0115ClaimLevelApprovalDetail
{
    public decimal ClaimTranId { get; set; }

    public decimal ClaimAprId { get; set; }

    public decimal? ClaimAppId { get; set; }

    public decimal CmpId { get; set; }

    public decimal EmpId { get; set; }

    public decimal SEmpId { get; set; }

    public decimal? ClaimId { get; set; }

    public DateTime? ClaimAprDate { get; set; }

    public decimal ClaimAprCode { get; set; }

    public decimal ClaimAprAmnt { get; set; }

    public string? ClaimStatus { get; set; }

    public decimal? ClaimAppAmnt { get; set; }

    public decimal? CurrId { get; set; }

    public decimal? CurrRate { get; set; }

    public string? Purpose { get; set; }

    public decimal? ClaimAppTotalAmnt { get; set; }

    public decimal? PetrolKm { get; set; }

    public decimal? LoginId { get; set; }

    public decimal? RptLevel { get; set; }

    public DateTime? ForDate { get; set; }

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

    public virtual T0115ClaimLevelApproval ClaimApr { get; set; } = null!;

    public virtual T0010CompanyMaster Cmp { get; set; } = null!;

    public virtual T0080EmpMaster Emp { get; set; } = null!;
}
