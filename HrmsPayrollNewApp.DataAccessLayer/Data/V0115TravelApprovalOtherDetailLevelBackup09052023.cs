using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class V0115TravelApprovalOtherDetailLevelBackup09052023
{
    public decimal TravelAppOtherDetailId { get; set; }

    public decimal TranId { get; set; }

    public decimal TravelModeId { get; set; }

    public DateTime ForDate { get; set; }

    public string? Description { get; set; }

    public decimal? Amount { get; set; }

    public string SelfPay { get; set; } = null!;

    public DateTime? ModifyDate { get; set; }

    public string TravelModeName { get; set; } = null!;

    public string? FromTime { get; set; }

    public string? ToTime { get; set; }

    public DateTime? ToDate { get; set; }

    public decimal CurrId { get; set; }

    public string Currency { get; set; } = null!;

    public decimal? TravelApplicationId { get; set; }

    public decimal RptLevel { get; set; }

    public byte GstApplicable { get; set; }

    public decimal Sgst { get; set; }

    public decimal Cgst { get; set; }

    public decimal Igst { get; set; }

    public string? GstNo { get; set; }

    public string? GstCompanyName { get; set; }

    public int? TravelMode { get; set; }

    public decimal? TravelAppId { get; set; }
}
