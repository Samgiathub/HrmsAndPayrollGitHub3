using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class V0110TravelAprOtherDetail
{
    public decimal TravelAppOtherDetailId { get; set; }

    public decimal CmpId { get; set; }

    public decimal TravelAppId { get; set; }

    public decimal TravelModeId { get; set; }

    public string? ForDate { get; set; }

    public string? FromTime { get; set; }

    public string? Description { get; set; }

    public decimal? Amount { get; set; }

    public string SelfPay { get; set; } = null!;

    public DateTime? ModifyDate { get; set; }

    public string TravelModeName { get; set; } = null!;

    public string? ToDate { get; set; }

    public string? ToTime { get; set; }

    public decimal CurrId { get; set; }

    public string Currency { get; set; } = null!;

    public byte GstApplicable { get; set; }

    public decimal Sgst { get; set; }

    public decimal Cgst { get; set; }

    public decimal Igst { get; set; }

    public string? GstNo { get; set; }

    public string? GstCompanyName { get; set; }

    public decimal TravelMode { get; set; }
}
