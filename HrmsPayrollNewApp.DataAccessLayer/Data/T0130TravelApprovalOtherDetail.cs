using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T0130TravelApprovalOtherDetail
{
    public decimal TravelAprOtherDetailId { get; set; }

    public decimal CmpId { get; set; }

    public decimal TravelApprovalId { get; set; }

    public decimal TravelModeId { get; set; }

    public DateTime ForDate { get; set; }

    public string? Description { get; set; }

    public decimal? Amount { get; set; }

    public byte SelfPay { get; set; }

    public DateTime? ModifyDate { get; set; }

    public DateTime? ToDate { get; set; }

    public decimal? CurrId { get; set; }

    public decimal Sgst { get; set; }

    public decimal Cgst { get; set; }

    public decimal Igst { get; set; }

    public string? GstNo { get; set; }

    public string? GstCompanyName { get; set; }

    public decimal? ModeId { get; set; }
}
