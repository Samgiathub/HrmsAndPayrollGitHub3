using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T0110ClaimApplicationDetail
{
    public decimal ClaimAppDetailId { get; set; }

    public decimal CmpId { get; set; }

    public decimal ClaimAppId { get; set; }

    public DateTime ForDate { get; set; }

    public decimal ApplicationAmount { get; set; }

    public string? ClaimDescription { get; set; }

    public decimal ClaimId { get; set; }

    public decimal? CurrId { get; set; }

    public decimal? CurrRate { get; set; }

    public decimal ClaimAmount { get; set; }

    public decimal PetrolKm { get; set; }

    public string? ClaimAttachment { get; set; }

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

    public decimal? ClaimSelfValue { get; set; }

    public string? ClaimDateLabel { get; set; }

    public decimal? ClaimFromLocId { get; set; }

    public decimal? ClaimToLocId { get; set; }

    public string? CityName { get; set; }
}
